import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/training_common/data/services/audio_recorder_util.dart';
import '../../features/training_common/presentation/controller/audio_recorder_controller.dart';

// recordindg_song_page / music_content_widget 에 사용될 Provider -> 이름 바뀔 수도 있음
final audioRecorderProvider =
    StateNotifierProvider.autoDispose<AudioRecorderController, bool>((ref) {
      final util = AudioRecorderUtil(
        isFileSave: true,
        isPitchDetection: true,
        isRhythmDetection: false, // 추후 확장 가능
      );
      final controller = AudioRecorderController(recorderUtil: util);
      controller.init(); // Provider 생성 시 초기화
      ref.onDispose(() => controller.disposeRecorder());
      return controller; // controller 리턴 -> 위젯에서 controller 사용 가능
    });

final pitchStreamProvider = StreamProvider.autoDispose<PitchData>((ref) {
  return ref.watch(audioRecorderProvider.notifier).pitchStream!;
});
