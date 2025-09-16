import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/features/curriculum/logics/curriculum_generation_request.dart';
import 'package:sync2sing/features/curriculum/logics/song_detail_model.dart';
import 'package:sync2sing/features/curriculum/views/duet_song_detail_page.dart';
import 'package:sync2sing/features/curriculum/views/duet_training_setting_page.dart';
import 'package:sync2sing/features/curriculum/views/song_example_video_page.dart';
import 'package:sync2sing/features/curriculum/views/solo_song_detail_page.dart';
import 'package:sync2sing/features/curriculum/views/solo_training_setting_page.dart';
import 'package:sync2sing/features/curriculum/views/song_list_page.dart';
import 'package:sync2sing/features/curriculum/views/training_generation_loading_page.dart';
import 'package:sync2sing/features/curriculum/views/training_guide_page.dart';
import 'package:sync2sing/features/shared/logics/analysis_type.dart';
import 'package:sync2sing/features/shared/logics/training_mode.dart';
import 'package:sync2sing/features/vocal_analysis/views/pages/pitch_training_page.dart';
import 'package:sync2sing/features/vocal_analysis/views/pages/pronunciation_training_page.dart';
import 'package:sync2sing/features/vocal_analysis/views/pages/rhythm_training_page.dart';
import 'package:sync2sing/features/vocal_analysis/views/pages/solo_recording_song_page.dart';

final List<GoRoute> curriculumRoutes = [
  GoRoute(
    path: AppRoutePaths.soloTrainingSetting,
    name: AppRouteNames.soloTrainingSetting,
    builder: (context, state) => const SoloTrainingSettingPage(),
  ),
  GoRoute(
    path: AppRoutePaths.duetTrainingSetting,
    name: AppRouteNames.duetTrainingSetting,
    builder: (context, state) => const DuetTrainingSettingPage(),
  ),
  GoRoute(
    path: "${AppRoutePaths.songList}/:trainingMode",
    name: AppRouteNames.songList,
    builder: (context, state) {
      final trainingMode = TrainingMode.values.firstWhere(
        (e) => e.name == state.pathParameters['trainingMode'],
      );
      return SongListPage(trainingMode: trainingMode);
    },
  ),
  GoRoute(
    path: AppRoutePaths.soloSongDetail,
    name: AppRouteNames.soloSongDetail,
    redirect: (context, state) {
      final songDetail = state.extra;
      if (songDetail == null || songDetail is! SongDetailModel) {
        debugPrint("soloSongDetail -잘못된 extra 파라미터");
      }
      return null;
    },
    builder:
        (context, state) => SoloSongDetailPage(songDetailModel: state.extra as SongDetailModel),
  ),
  GoRoute(
    path: AppRoutePaths.duetSongDetail,
    name: AppRouteNames.duetSongDetail,
    redirect: (context, state) {
      final extraData = state.extra;

      // 타입 체크
      if (extraData is! ({SongDetailModel songDetailModel, List<DuetPart> duetParts})) {
        debugPrint("duetSongDetail - 잘못된 extra 파라미터: ${extraData.runtimeType}");
        return '/'; // /error?message=${Uri.encodeComponent("잘못된 페이지 접근입니다")}
      }

      return null; // 정상
    },
    builder: (context, state) {
      // redirect에서 이미 검증했으므로 안전하게 캐스팅
      final extraData =
          state.extra as ({SongDetailModel songDetailModel, List<DuetPart> duetParts});

      return DuetSongDetailPage(
        songDetailModel: extraData.songDetailModel,
        duetParts: extraData.duetParts,
      );
    },
  ),
  GoRoute(
    path: "${AppRoutePaths.songExampleVideo}/:trainingMode/:analysisType/:songId",
    name: AppRouteNames.songExampleVideo,
    builder: (context, state) {
      final trainingMode = TrainingMode.values.firstWhere(
        (e) => e.name == state.pathParameters['trainingMode'],
      );
      final analysisType = AnalysisType.values.firstWhere(
        (e) => e.name == state.pathParameters['analysisType'],
      );
      final songIdStr = state.pathParameters['songId'];
      final songId = int.tryParse(songIdStr!);
      return SongExampleVideoPage(
        songId: songId!,
        trainingMode: trainingMode,
        analysisType: analysisType,
      );
    },
  ),
  GoRoute(
    path: "${AppRoutePaths.soloPreRecordingSong}/:analysisType/:songId",
    name: AppRouteNames.soloPreRecordingSong,
    builder: (context, state) {
      final analysisType = AnalysisType.values.firstWhere(
        (e) => e.name == state.pathParameters['analysisType'],
      );
      final songIdStr = state.pathParameters['songId'];
      final songId = int.tryParse(songIdStr!);

      return SoloRecordingSongPage(songId: songId!, analysisType: analysisType);
    },
  ),
  GoRoute(
    path: AppRoutePaths.trainingGenerationLoading,
    name: AppRouteNames.trainingGenerationLoading,
    // builder: (context, state) => TrainingGenerationLoadingPage(),
    builder:
        (context, state) => TrainingGenerationLoadingPage(
          curriculumGenerationRequest: state.extra as CurriculumGenerationRequest,
        ), // extra로 정보 전달 시
  ),
  GoRoute(
    path: AppRoutePaths.trainingGuide,
    name: AppRouteNames.trainingGuide,
    builder: (context, state) => const TrainingGuidePage(),
  ),
  GoRoute(
    path: AppRoutePaths.pitchTraining,
    name: AppRouteNames.pitchTraining,
    builder: (context, state) => const PitchTrainingPage(),
  ),
  GoRoute(
    path: AppRoutePaths.rhythmTraining,
    name: AppRouteNames.rhythmTraining,
    builder: (context, state) => const RhythmTrainingPage(),
  ),
  GoRoute(
    path: AppRoutePaths.pronunciationTraining,
    name: AppRouteNames.pronunciationTraining,
    builder: (context, state) => const PronunciationTrainingPage(),
  ),
];
