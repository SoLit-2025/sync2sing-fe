import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/features/curriculum/logics/song_detail_model.dart';
import 'package:sync2sing/features/curriculum/views/duet_song_detail_page.dart';
import 'package:sync2sing/features/curriculum/views/song_example_video_page.dart';
import 'package:sync2sing/features/curriculum/views/solo_pre_recording_song_page.dart';
import 'package:sync2sing/features/curriculum/views/solo_song_detail_page.dart';
import 'package:sync2sing/features/curriculum/views/solo_training_setting_page.dart';
import 'package:sync2sing/features/curriculum/views/song_list_page.dart';
import 'package:sync2sing/features/curriculum/views/training_generation_loading_page.dart';
import 'package:sync2sing/features/shared/logics/training_mode.dart';

final List<GoRoute> curriculumRoutes = [
  GoRoute(
    path: AppRoutePaths.soloTrainingSetting,
    name: AppRouteNames.soloTrainingSetting,
    builder: (context, state) => const SoloTrainingSettingPage(),
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
    path: "${AppRoutePaths.songExampleVideo}/:songId",
    name: AppRouteNames.songExampleVideo,
    builder: (context, state) {
      final songIdStr = state.pathParameters['songId'];
      final songId = int.tryParse(songIdStr!);
      return SongExampleVideoPage(songId: songId!);
    },
  ),
  GoRoute(
    path: AppRoutePaths.soloPreRecordingSong,
    name: AppRouteNames.soloPreRecordingSong,
    builder: (context, state) => const SoloPreRecordingSongPage(),
  ),
  GoRoute(
    path: AppRoutePaths.trainingGenerationLoading,
    name: AppRouteNames.trainingGenerationLoading,
    builder: (context, state) => const TrainingGenerationLoadingPage(),
  ),
];
