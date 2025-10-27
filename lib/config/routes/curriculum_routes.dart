import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/features/curriculum/logics/curriculum_generation_request.dart';
import 'package:sync2sing/features/curriculum/logics/duet_song_model.dart';
import 'package:sync2sing/features/curriculum/logics/song_detail_model.dart';
import 'package:sync2sing/features/curriculum/views/duet_room_detail_page.dart';
import 'package:sync2sing/features/curriculum/views/duet_song_detail_page.dart';
import 'package:sync2sing/features/curriculum/views/duet_song_list_page.dart';
import 'package:sync2sing/features/curriculum/views/duet_training_setting_page.dart';
import 'package:sync2sing/features/curriculum/views/song_example_video_page.dart';
import 'package:sync2sing/features/curriculum/views/solo_song_detail_page.dart';
import 'package:sync2sing/features/curriculum/views/solo_training_setting_page.dart';
import 'package:sync2sing/features/curriculum/views/song_list_page.dart';
import 'package:sync2sing/features/curriculum/views/training_generation_loading_page.dart';
import 'package:sync2sing/features/curriculum/views/training_guide_page.dart';
import 'package:sync2sing/features/home_hub/logics/room_item.dart';
import 'package:sync2sing/features/shared/logics/analysis_type.dart';
import 'package:sync2sing/features/shared/logics/training_mode.dart';
import 'package:sync2sing/features/vocal_analysis/views/pages/duet_recording_song_page.dart';
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
    path: AppRoutePaths.songList,
    name: AppRouteNames.songList,
    builder: (context, state) {
      return SongListPage();
    },
  ),
  GoRoute(
    path: AppRoutePaths.duetSongList,
    name: AppRouteNames.duetSongList,
    builder: (context, state) => const DuetSongListPage(),
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
      final extras = state.extra;
      if (extras == null || extras is! Map<String, dynamic>) {
        debugPrint("duetSongDetail -잘못된 extra 파라미터:  ${extras.runtimeType}");
        return '/';
      }
      final song = extras['song'];
      final isSelectFirst = extras['isSelectFirst'];

      if (song == null || song is! DuetSongModel || isSelectFirst is! bool) {
        debugPrint(
          "duetSongDetail -잘못된 extra 파라미터:  ${song.runtimeType} |  ${isSelectFirst.runtimeType}",
        );
        return '/';
      }
      return null;
    },
    builder: (context, state) {
      final extras = state.extra as Map<String, dynamic>;
      final song = extras['song'] as DuetSongModel;
      final isSelectFirst = extras['isSelectFirst'] as bool;

      return DuetSongDetailPage(duetSongModel: song, isSelectFirst: isSelectFirst);
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
      final roomIdStr = state.uri.queryParameters['roomId'];
      final int? roomId = (roomIdStr != null) ? int.tryParse(roomIdStr) : null;
      final partNumStr = state.uri.queryParameters['partNumber'];
      final int? partNumber = (partNumStr != null) ? int.tryParse(partNumStr) : null;

      return SongExampleVideoPage(
        songId: songId!,
        trainingMode: trainingMode,
        analysisType: analysisType,
        roomId: roomId,
        partNumber: partNumber,
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
    path: "${AppRoutePaths.duetRecordingSong}/:analysisType/:songId",
    name: AppRouteNames.duetRecordingSong,
    builder: (context, state) {
      final analysisType = AnalysisType.values.firstWhere(
        (e) => e.name == state.pathParameters['analysisType'],
      );
      final songIdStr = state.pathParameters['songId'];
      final songId = int.tryParse(songIdStr!);
      final roomIdStr = state.uri.queryParameters['roomId'];
      final int? roomId = (roomIdStr != null) ? int.tryParse(roomIdStr) : null;
      final partNumStr = state.uri.queryParameters['partNumber'];
      final int? partNumber = (partNumStr != null) ? int.tryParse(partNumStr) : null;

      return DuetRecordingSongPage(
        songId: songId!,
        analysisType: analysisType,
        roomId: roomId,
        partNumber: partNumber ?? 0,
      );
    },
  ),
  GoRoute(
    path: AppRoutePaths.trainingGenerationLoading,
    name: AppRouteNames.trainingGenerationLoading,
    builder: (context, state) {
      return TrainingGenerationLoadingPage(
        curriculumGenerationRequest: state.extra as CurriculumGenerationRequest,
      );
    },
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

  GoRoute(
    path: AppRoutePaths.duetRoomDetail,
    name: AppRouteNames.duetRoomDetail,
    redirect: (context, state) {
      final extras = state.extra;
      if (extras == null || extras is! Map<String, dynamic>) {
        debugPrint("duetSongDetail -잘못된 extra 파라미터:  ${extras.runtimeType}");
        return '/';
      }
      final roomPosition = extras['roomPosition'];
      final room = extras['room'];

      if (roomPosition == null || roomPosition is! RoomPosition || room == null || room is! Room) {
        debugPrint(
          "duetSongDetail -잘못된 extra 파라미터:  ${roomPosition.runtimeType} |  ${room.runtimeType}",
        );
        return '/';
      }
      return null;
    },
    builder: (context, state) {
      final extras = state.extra as Map<String, dynamic>;
      final roomPosition = extras['roomPosition'] as RoomPosition;
      final room = extras['room'] as Room;

      return DuetRoomDetailPage(roomPosition: roomPosition, room: room);
    },
  ),
];
