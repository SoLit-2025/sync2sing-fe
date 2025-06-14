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
        Uri.parse('http://13.125.152.131:8080/api/training/vocal-analysis'),
      )
      ..headers.addAll({
        'User-Agent': 'Sync2Sing/1.0',
        'Accept': 'application/json',
      });

    // 4. 오디오 파일 추가 (명세서에 맞게 MIME 타입 수정)
    debugPrint('[4/7] 🔊 오디오 파일 추가');
    final audioPart = await http.MultipartFile.fromPath(
      'vocal_file',
      audioFile.path,
      contentType: MediaType('audio', 'wav'), // ✅ API 명세서 준수
    );
    request.files.add(audioPart);

    // 5. JSON 데이터 추가 (멀티파트 파일로 변경)
    debugPrint('[5/7] 📦 JSON 데이터 추가');
    final jsonData = jsonEncode({
      'training_mode': 'SOLO',
      'analysis_type': 'GUEST',
      'pitch_accuracy': vocalData.pitchAccuracy,
      'beat_accuracy': vocalData.rhythmAccuracy,
    });

    // ✅ JSON을 별도의 멀티파트 섹션으로 추가
    final jsonPart = http.MultipartFile.fromString(
      'data', // API 명세서 name="data"와 일치
      jsonData,
      contentType: MediaType('application', 'json'), // Content-Type 지정
    );
    request.files.add(jsonPart);

    // 6. 요청 상세 로깅
    debugPrint('[6/7] 🔍 요청 상세 정보');
    _logRequestDetails(request);
    debugPrint('''
[디버깅: 최종 전송 데이터]
- 파일 경로: ${vocalData.wavFilePath}
- 파일 존재: ${audioFile.existsSync()}
- 파일 크기: ${audioFile.existsSync() ? audioFile.lengthSync() : 'N/A'} bytes
- pitch_accuracy: ${vocalData.pitchAccuracy} (${vocalData.pitchAccuracy.runtimeType})
- beat_accuracy: ${vocalData.rhythmAccuracy} (${vocalData.rhythmAccuracy.runtimeType})
- JSON: $jsonData
- 헤더: ${request.headers}
- 파일 파트: ${request.files.map((f) => '${f.field} (${f.filename}) [${f.contentType}]').join(', ')}
''');

    // 7. 요청 전송
    debugPrint('[7/7] 🚀 요청 전송 시작');
    final response = await request.send().timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw TimeoutException('서버 응답 시간 초과 (30초)'),
    );

    // 8. 응답 처리
    final responseBody = await response.stream.bytesToString();

    debugPrint('''
✅ [응답 수신] 
▷ 상태 코드: ${response.statusCode}
▷ 소요 시간: ${stopwatch.elapsedMilliseconds}ms
▷ 본문 길이: ${responseBody.length} 바이트
▷ 본문 내용: ${responseBody.isNotEmpty ? responseBody : '[빈 문자열]'}
''');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      debugPrint('❌ [HTTP 오류 발생] 상태코드: ${response.statusCode}');
      throw HttpException('서버 오류: ${response.statusCode}', uri: request.url);
    }

    if (responseBody.isEmpty) {
      debugPrint('❌ [서버에서 빈 응답 반환]');
      throw FormatException('서버에서 빈 응답이 반환되었습니다');
    }

    try {
      final jsonResult = jsonDecode(responseBody);
      debugPrint('[파싱된 JSON] $jsonResult');
      if (jsonResult['status'] != 201) {
        debugPrint(
          '❌ [API 실패] status: ${jsonResult['status']}, message: ${jsonResult['message']}',
        );
        throw Exception('API 요청 실패: ${jsonResult['message']}');
      }

      ref
          .read(vocalResultProvider.notifier)
          .updateAnalysisResult(jsonEncode(jsonResult['data']));
    } on FormatException catch (e) {
      debugPrint('❌ [JSON 파싱 실패] 원본 응답: $responseBody');
      rethrow;
    }
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
  } on HttpException catch (e) {
    debugPrint('''
🔐 [HTTP 오류] 
▷ 상태 코드: ${e.uri}
▷ 메시지: ${e.message}''');
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

// -- 헬퍼 함수들 (변경 없음) --
void _validateRequestData(dynamic data) {
  if (data.wavFilePath == null ||
      data.pitchAccuracy == null ||
      data.rhythmAccuracy == null) {
    debugPrint('''
❌ [필수 데이터 누락]
- 파일 경로: ${data.wavFilePath}
- 음정 정확도: ${data.pitchAccuracy}
- 박자 정확도: ${data.rhythmAccuracy}''');
    throw StateError('''
❌ 필수 데이터 누락:
- 파일 경로: ${data.wavFilePath}
- 음정 정확도: ${data.pitchAccuracy}
- 박자 정확도: ${data.rhythmAccuracy}''');
  }
}

void _logFileDetails(File file) {
  debugPrint(
    '''
📂 파일 정보:
├─ 경로: ${file.path}
├─ 존재: ${file.existsSync()}
└─ 크기: ${(file.existsSync() ? (file.lengthSync() / 1024).toStringAsFixed(2) : 'N/A')} KB''',
  );
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
   │  └─ 크기: ${f.length} 바이트''').join('\n')}''',
  );
}
