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

    debugPrint('[4/4] 요청 전송');
    final response = await dioFactory.post('/training/vocal-analysis', data: formData);

    // 8. 응답 데이터 직접 반환
    final jsonResult = response.data;
    // final Map<String, dynamic> jsonResult = {
    //   "status": 201,
    //   "message": "듀엣 음원 병합에 성공했습니다.",
    //   "data": {
    //     "room_id": 4,
    //     "recording_phase": "POST",
    //     "merged_audio_url":
    //     "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/audios/merged/c035284c-15dc-455b-b283-ac615efbee03.mp3",
    //     "vocal_analysis_report_response": {
    //       "report_id": 26,
    //       "analysis_type": "POST",
    //       "title": "2025-09-06 Do-Re-Mi Duet Dong",
    //       "song": {
    //         "song_id": 5,
    //         "title": "Do-Re-Mi Duet Dong",
    //         "artist": "Richard Rodgers",
    //         "voice_type": "SOPRANO",
    //         "pitch_note_min": "C4",
    //         "pitch_note_max": "D5",
    //         "album_cover_url":
    //         "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/984ebad3-38bd-4984-a3b3-9c5ca93170e2.jpg",
    //       },
    //       "pitch_score": 65,
    //       "beat_score": 90,
    //       "pronunciation_score": 6,
    //       "overall_review_title": "음정과 발음 조화로 성장할 기회",
    //       "overall_review_content":
    //       "음정은 적당히 안정적이고 박자가 잘 맞추어지고 있어요. 그러나 발음이 매우 부족해서 노래의 전달력이 떨어질 수 있어요. 태그 분석으로 볼 때 립트릴은 확률이 높아 발성 연습에 도움이 될 수 있지만, 발음 연습이 필요해 보여요. 이를 통해 더 자연스럽고 명확한 표현이 가능해질 거예요.",
    //       "created_at": "2025-09-06T04:48:16.77498159",
    //       "feedback_title": "발음 집중 연습으로 조화 향상하기",
    //       "feedback_content":
    //       "발음 점수가 낮아 전달력 향상이 필요해요. 발음 연습으로 혀와 입 근육 강화, 10분씩 하루 3회, 일주일 지속해보세요. 립트릴 연습도 병행하면 발성 안정과 함께 자연스러운 발음이 늘어날 거예요. 박자와 음정도 유지하며 꾸준히 연습하면 전체 조화가 더 좋아질 거예요.",
    //     },
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
          // 듀엣 + post -> 무조건 병합 시도.
          final mergeResponse = await dioFactory.post(
            '/duet-training/rooms/${params.roomId}/merge-audios',
          );
          mergeJson = mergeResponse.data['data'];

          // final Map<String, dynamic> mergeResponse = {
          //   "status": 201,
          //   "message": "듀엣 음원 병합에 성공했습니다.",
          //   "data": {
          //     "room_id": 4,
          //     "recording_phase": "POST",
          //     "merged_audio_url":
          //         "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/audios/merged/c035284c-15dc-455b-b283-ac615efbee03.mp3",
          //     "vocal_analysis_report_response": {
          //       "report_id": 26,
          //       "analysis_type": "POST",
          //       "title": "2025-09-06 Do-Re-Mi Duet Dong",
          //       "song": {
          //         "song_id": 5,
          //         "title": "Do-Re-Mi Duet Dong",
          //         "artist": "Richard Rodgers",
          //         "voice_type": "SOPRANO",
          //         "pitch_note_min": "C4",
          //         "pitch_note_max": "D5",
          //         "album_cover_url":
          //             "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/984ebad3-38bd-4984-a3b3-9c5ca93170e2.jpg",
          //       },
          //       "pitch_score": 65,
          //       "beat_score": 90,
          //       "pronunciation_score": 6,
          //       "overall_review_title": "음정과 발음 조화로 성장할 기회",
          //       "overall_review_content":
          //           "음정은 적당히 안정적이고 박자가 잘 맞추어지고 있어요. 그러나 발음이 매우 부족해서 노래의 전달력이 떨어질 수 있어요. 태그 분석으로 볼 때 립트릴은 확률이 높아 발성 연습에 도움이 될 수 있지만, 발음 연습이 필요해 보여요. 이를 통해 더 자연스럽고 명확한 표현이 가능해질 거예요.",
          //       "created_at": "2025-09-06T04:48:16.77498159",
          //       "feedback_title": "발음 집중 연습으로 조화 향상하기",
          //       "feedback_content":
          //           "발음 점수가 낮아 전달력 향상이 필요해요. 발음 연습으로 혀와 입 근육 강화, 10분씩 하루 3회, 일주일 지속해보세요. 립트릴 연습도 병행하면 발성 안정과 함께 자연스러운 발음이 늘어날 거예요. 박자와 음정도 유지하며 꾸준히 연습하면 전체 조화가 더 좋아질 거예요.",
          //     },
          //   },
          // };
          mergeJson = mergeResponse.data['data'];
          debugPrint('mergeJson: $mergeJson');
          // 위에서 오류가 나지 않으면 방 삭제. (이것도 애매..)
          await dioFactory.delete('/duet-training/rooms/${params.roomId}');
        }
      } catch (e) {
        mergeJson = null;
      }
      return {'reportJson': jsonResult['data'] as Map<String, dynamic>, 'mergeJson': mergeJson};
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
