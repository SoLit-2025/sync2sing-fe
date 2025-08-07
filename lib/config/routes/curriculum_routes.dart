import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/features/curriculum/views/solo_example_video_page.dart';
import 'package:sync2sing/features/curriculum/views/solo_pre_recording_song_page.dart';
import 'package:sync2sing/features/curriculum/views/solo_song_detail_page.dart';
import 'package:sync2sing/features/curriculum/views/solo_training_setting_page.dart';
import 'package:sync2sing/features/curriculum/views/song_list_page.dart';
import 'package:sync2sing/features/curriculum/views/training_generation_loading_page.dart';

final List<GoRoute> curriculumRoutes = [
  GoRoute(
    path: AppRoutePaths.soloTrainingSetting,
    name: AppRouteNames.soloTrainingSetting,
    builder: (context, state) => const SoloTrainingSettingPage(),
  ),
  GoRoute(
    path: AppRoutePaths.songList,
    name: AppRouteNames.songList,
    builder: (context, state) => const SongListPage(),
  ),
  GoRoute(
    path: AppRoutePaths.soloSongDetail,
    name: AppRouteNames.soloSongDetail,
    builder: (context, state) => const SoloSongDetailPage(),
  ),
  GoRoute(
    path: AppRoutePaths.soloExampleVideo,
    name: AppRouteNames.soloExampleVideo,
    builder: (context, state) => const SoloExampleVideoPage(),
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
