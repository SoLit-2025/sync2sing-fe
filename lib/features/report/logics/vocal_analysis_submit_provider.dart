import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import 'package:sync2sing/features/shared/logics/analysis_type.dart';
import 'package:sync2sing/features/shared/logics/dio_factory.dart';
import 'package:sync2sing/features/shared/logics/secure_storage.dart';
import 'package:sync2sing/features/vocal_analysis/logics/providers/vocal_result_provider.dart';

import 'analysis_params.dart';

// 1. 반환 타입을 Map<String, dynamic>으로 변경
final vocalAnalysisSubmitProvider = FutureProvider.autoDispose.family<
  Map<String, dynamic>,
  AnalysisParams
>((ref, params) async {
  try {
    // 1. 데이터 검증
    debugPrint('[1/4] 데이터 검증 시작');
    final vocalData = ref.read(vocalResultProvider);
    _validateRequestData(vocalData);

    // 2. 파일 확인
    debugPrint('[2/4]  파일 검증');
    final audioFile = File(vocalData.wavFilePath!);
    _logFileDetails(audioFile);
    final fileName = vocalData.wavFilePath?.split('/').last;

    debugPrint('[3/4] 요청 바디 만들기');
    final DioFactory dioFactory = DioFactory(SecureStorage(), contentType: 'multipart/form-data');
    FormData formData = FormData.fromMap({
      "data": MultipartFile.fromString(
        jsonEncode({
          'training_mode': params.trainingMode.apiValue,
          'analysis_type': params.analysisType.name.toUpperCase(),
          'pitch_accuracy': vocalData.pitchAccuracy,
          'beat_accuracy': vocalData.rhythmAccuracy,
        }),
        contentType: MediaType('application', 'json'),
      ),
      "vocal_file": await MultipartFile.fromFile(
        audioFile.path,
        filename: fileName,
        contentType: MediaType('audio', 'wav'),
      ),
    });

    if (params.analysisType == AnalysisType.guest) {
      // 게스트 모드 -> 액세스 토큰 삭제
      await SecureStorage().deleteTokens();
    }

    debugPrint('[4/4] 요청 전송');
    final response = await dioFactory.post('/training/vocal-analysis', data: formData);

    // 8. 응답 데이터 직접 반환
    final jsonResult = response.data;
    debugPrint("보분리 결과: $jsonResult");
    if (jsonResult['status'] == 201) {
      return jsonResult['data'] as Map<String, dynamic>;
    }
    debugPrint('[응답 수신] 상태 코드: ${response.statusCode}');
    debugPrint('[응답 수신] responseBody: ${response.statusMessage}');
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
    // debugPrint('error: ${e.}')
    debugPrint('❗ [알 수 없는 오류] ${e.toString()}\n${stack.toString().split('\n').take(5).join('\n')}');
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
