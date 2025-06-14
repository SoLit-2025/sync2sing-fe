// lib/shared/providers/vocal_analysis_submit_provider.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:sync2sing/shared/providers/vocal_result_provider.dart';

final vocalAnalysisSubmitProvider = FutureProvider.autoDispose<void>((
  ref,
) async {
  final stopwatch = Stopwatch()..start();

  try {
    // 1. 데이터 검증
    debugPrint('[1/7] 🛠️ 데이터 검증 시작');
    final vocalData = ref.watch(vocalResultProvider);
    _validateRequestData(vocalData);

    // 2. 파일 확인
    debugPrint('[2/7] 📁 파일 검증');
    final audioFile = File(vocalData.wavFilePath!);
    _logFileDetails(audioFile);

    // 3. 요청 객체 생성
    debugPrint('[3/7] 📡 요청 생성');
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://15.164.212.116:8080/api/training/vocal-analysis'),
    );

    // 4. 오디오 파일 추가
    debugPrint('[4/7] 🔊 오디오 파일 추가');
    final audioPart = await http.MultipartFile.fromPath(
      'vocal_file',
      audioFile.path,
      contentType: MediaType('audio', 'wav'),
    );
    request.files.add(audioPart);

    // 5. JSON 데이터 추가
    debugPrint('[5/7] 📦 JSON 데이터 추가');
    final jsonData = jsonEncode({
      'training_mode': 'SOLO',
      'analysis_type': 'GUEST',
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

    // 7. 요청 전송
    debugPrint('[7/7] 🚀 요청 전송 시작');
    final response = await request.send().timeout(
      const Duration(seconds: 10000000000),
      onTimeout: () {
        throw TimeoutException('서버 응답 시간 초과 (30초)');
      },
    );

    // 8. 응답 처리
    final responseBody = await response.stream.bytesToString();
    debugPrint(
      '''
✅ [응답 성공] 
▷ 상태 코드: ${response.statusCode}
▷ 소요 시간: ${stopwatch.elapsedMilliseconds}ms
▷ 본문 길이: ${responseBody.length} 바이트
▷ 본문 내용: ${responseBody.length > 500 ? responseBody.substring(0, 500) + '...' : responseBody}''',
    );

    ref.read(vocalResultProvider.notifier).updateAnalysisResult(responseBody);
  } on TimeoutException catch (e, stack) {
    debugPrint('''
⏰ [타임아웃] 
▷ 메시지: ${e.message}
▷ 스택: ${stack.toString().split('\n').take(3).join('\n')}''');
    rethrow;
  } on SocketException catch (e) {
    debugPrint('''
📡 [네트워크 오류] 
▷ 유형: ${e.runtimeType}
▷ 메시지: ${e.message}
▷ OS 코드: ${e.osError?.errorCode}
▷ OS 메시지: ${e.osError?.message}''');
    rethrow;
  } catch (e, stack) {
    debugPrint('''
❗ [알 수 없는 오류] 
▷ 유형: ${e.runtimeType}
▷ 메시지: ${e.toString()}
▷ 스택: ${stack.toString().split('\n').take(5).join('\n')}''');
    rethrow;
  }
});

// -- 헬퍼 함수들 --
void _validateRequestData(dynamic data) {
  if (data.wavFilePath == null ||
      data.pitchAccuracy == null ||
      data.rhythmAccuracy == null) {
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
└─ 크기: ${(file.lengthSync() / 1024).toStringAsFixed(2)} KB''');
}

void _logRequestDetails(http.MultipartRequest request) {
  debugPrint(
    '''
📨 요청 상세:
├─ URL: ${request.method} ${request.url}
├─ 헤더:
${request.headers.entries.map((e) => '│  ├─ ${e.key}: ${e.value}').join('\n')}
└─ 본체:
${request.files.map((f) => '''
   ├─ [파일 파트]
   │  ├─ 필드명: ${f.field}
   │  ├─ 파일명: ${f.filename}
   │  ├─ 타입: ${f.contentType}
   │  └─ 크기: ${f.length} 바이트''').join('\n')}
${request.fields.entries.map((e) => '   ├─ [필드 파트] ${e.key}: ${e.value}').join('\n')}''',
  );
}
