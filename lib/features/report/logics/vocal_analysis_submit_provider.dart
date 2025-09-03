import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:sync2sing/features/shared/logics/analysis_type.dart';
import 'package:sync2sing/features/shared/logics/secure_storage.dart';
import 'package:sync2sing/features/vocal_analysis/logics/providers/vocal_result_provider.dart';

import 'analysis_params.dart';

// 1. 반환 타입을 Map<String, dynamic>으로 변경
final vocalAnalysisSubmitProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, AnalysisParams>((ref, params) async {
      try {
        // 1. 데이터 검증
        debugPrint('[1/7] 🛠️ 데이터 검증 시작');
        final vocalData = ref.read(vocalResultProvider);
        _validateRequestData(vocalData);

        // 2. 파일 확인
        debugPrint('[2/7] 📁 파일 검증');
        final audioFile = File(vocalData.wavFilePath!);
        _logFileDetails(audioFile);

        debugPrint('[3/7] 📡 요청 생성');
        final request = http.MultipartRequest(
            'POST',
            Uri.parse('http://13.125.152.131:8080/api/training/vocal-analysis'),
          )
          ..headers.addAll(
            (params.analysisType == AnalysisType.guest)
                ? {'User-Agent': 'Sync2Sing/1.0', 'Accept': 'application/json'}
                : {
                  'User-Agent': 'Sync2Sing/1.0',
                  'Accept': 'application/json',
                  'Authorization': 'Bearer ${await SecureStorage().readAccessToken()}',
                },
          );

        // 4. 오디오 파일 추가
        debugPrint('[4/7] 🔊 오디오 파일 추가');
        request.files.add(
          await http.MultipartFile.fromPath(
            'vocal_file',
            audioFile.path,
            contentType: MediaType('audio', 'wav'),
          ),
        );

        // 5. JSON 데이터 추가
        debugPrint('[5/7] 📦 JSON 데이터 추가');
        final jsonData = jsonEncode({
          'training_mode': params.trainingMode.apiValue,
          'analysis_type': params.analysisType.name.toUpperCase(),
          'pitch_accuracy': vocalData.pitchAccuracy,
          'beat_accuracy': vocalData.rhythmAccuracy,
        });

        request.files.add(
          http.MultipartFile.fromString(
            'data',
            jsonData,
            contentType: MediaType('application', 'json'),
          ),
        );

        // 6. 요청 상세 로깅
        debugPrint('[6/7] 🔍 요청 상세 정보');
        _logRequestDetails(request);

        // 7. 요청 전송 및 응답 처리
        debugPrint('[7/7] 🚀 요청 전송 시작');
        final response = await request.send().timeout(
          const Duration(seconds: 120),
          onTimeout: () => throw TimeoutException('서버 응답 시간 초과 (120초)'),
        );

        final responseBody = await response.stream.bytesToString();
        debugPrint('[응답 수신] 상태 코드: ${response.statusCode}');
        debugPrint('[응답 수신] responseBody: $responseBody');

        // 8. 응답 데이터 직접 반환
        final jsonResult = jsonDecode(responseBody);
        if (jsonResult['status'] == 201) {
          return jsonResult['data'] as Map<String, dynamic>;
        }
        throw Exception('API 요청 실패: ${jsonResult['message']}');
      } on TimeoutException catch (e, stack) {
        debugPrint('⏰ [타임아웃] ${e.message}\n${stack.toString().split('\n').take(3).join('\n')}');
        rethrow;
      } on SocketException catch (e) {
        debugPrint('📡 [네트워크 오류] ${e.message}');
        rethrow;
      } on HttpException catch (e) {
        debugPrint('🔐 [HTTP 오류] ${e.message}');
        rethrow;
      } catch (e, stack) {
        debugPrint(
          '❗ [알 수 없는 오류] ${e.toString()}\n${stack.toString().split('\n').take(5).join('\n')}',
        );
        rethrow;
      }
    });

// 헬퍼 함수들
void _validateRequestData(dynamic data) {
  if (data.wavFilePath == null || data.pitchAccuracy == null || data.rhythmAccuracy == null) {
    throw StateError('''
❌ 필수 데이터 누락:
- 파일 경로: ${data.wavFilePath}
- 음정 정확도: ${data.pitchAccuracy}
- 박자 정확도: ${data.rhythmAccuracy}''');
  }
}

void _logFileDetails(File file) {
  debugPrint('''
📂 파일 정보:
├─ 경로: ${file.path}
├─ 존재: ${file.existsSync()}
└─ 크기: ${(file.existsSync() ? (file.lengthSync() / 1024).toStringAsFixed(2) : 'N/A')} KB''');
}

void _logRequestDetails(http.MultipartRequest request) {
  debugPrint('''
📨 요청 상세:
├─ URL: ${request.method} ${request.url}
├─ 헤더: ${request.headers}
└─ 파일 파트: ${request.files.map((f) => '${f.field} (${f.filename})').join(', ')}''');
}
