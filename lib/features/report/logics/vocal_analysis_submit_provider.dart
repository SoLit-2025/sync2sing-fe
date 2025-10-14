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
import 'package:sync2sing/features/shared/logics/training_mode.dart';
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

    debugPrint('[3/4] 요청 바디 만들기 : ${params.trainingMode.apiValue} | ${params.analysisType}');
    DioFactory dioFactory = DioFactory(SecureStorage(), contentType: 'multipart/form-data');
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
      debugPrint("remove token");
    }
    // debugPrint(
    //   "formData: ${jsonEncode({'training_mode': params.trainingMode.apiValue, 'analysis_type': params.analysisType.name.toUpperCase(), 'pitch_accuracy': vocalData.pitchAccuracy, 'beat_accuracy': vocalData.rhythmAccuracy})}",
    // );

    debugPrint('[4/4] 요청 전송');
    final response = await dioFactory.post('/training/vocal-analysis', data: formData);

    // 8. 응답 데이터 직접 반환
    final jsonResult = response.data;
    // final Map<String, dynamic> jsonResult = {
    //   'status': 201,
    //   'message': '보컬 분석 리포트 생성에 성공했습니다.',
    //   'data': {
    //     'report_id': 322,
    //     'analysis_type': 'POST',
    //     'title': '2025-10-14 Do-Re-Mi Duet Dong',
    //     'song': {
    //       'song_id': 20,
    //       'title': 'Do-Re-Mi Duet Dong',
    //       'artist': 'Richard Rodgers',
    //       'voice_type': null,
    //       'pitch_note_min': null,
    //       'pitch_note_max': null,
    //       'album_cover_url':
    //           ' https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/b3a398e3-1a45-4da7-a7a9-a588d11c8c00.jpg',
    //     },
    //     'pitch_score': 5,
    //     'beat_score': 42,
    //     'pronunciation_score': 0,
    //     'overall_review_title': '리듬과 발음 연습으로 전체 향상 기대',
    //     'overall_review_content':
    //         "박자와 발음 부분이 낮아 노래의 안정성과 선명도가 떨어질 수 있어요. 발성 태그를 보면 보컬 플라이(확률 79.5%)가 강하고, 립 트릴이 보조적이니 이를 활용하는 연습이 좋겠어요. 꾸준히 연습하면 전체 실력이 올라갈 거예요.",
    //     'created_at': '2025-10-14T12:08:16.14095454',
    //     'cause_content': '박자와 발음에 집중하는 연습 부족, 발성에서 작작은 호흡과 발성 제어 미흡 가능성이 있어요',
    //     'proposal_content': '',
    //   },
    // };
    debugPrint("보분리 결과: $jsonResult");
    Map<String, dynamic>? mergeJson;
    if (jsonResult['status'] == 201) {
      dioFactory = DioFactory(SecureStorage());
      if (params.trainingMode == TrainingMode.solo && params.analysisType == AnalysisType.post) {
        await dioFactory.delete('/solo-training/session');
      }

      try {
        if (params.analysisType == AnalysisType.post &&
            params.trainingMode == TrainingMode.duet &&
            params.roomId != null) {
          final mergeResponse = await dioFactory.post(
            '/duet-training/rooms/${params.roomId}/merge-audios',
          );
          if (mergeResponse.statusCode == 201) {
            mergeJson = mergeResponse.data['data'];
            debugPrint('reportJson: ${jsonResult}');
            debugPrint('mergeJson: ${mergeJson}');
            await dioFactory.delete('/duet-training/rooms/${params.roomId}');
          }
        }
      } catch (e) {
        mergeJson = null;
      }
      return {'reportJson': jsonResult['data'] as Map<String, dynamic>, 'mergeJson': mergeJson};
      // return jsonResult['data'] as Map<String, dynamic>;
    }
    // debugPrint('[응답 수신] 상태 코드: ${response.statusCode}');
    // debugPrint('[응답 수신] responseBody: ${response.statusMessage}');
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
  } on DioException catch (e) {
    debugPrint('[dio 오류] ${e.message} | ${e.response?.data}');
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
