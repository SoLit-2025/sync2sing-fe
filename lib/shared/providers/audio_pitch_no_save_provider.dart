import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/training_common/data/services/audio_stream_recorder.dart';
import '../../features/training_common/presentation/controller/audio_recorder_controller.dart';

// max/min_pitch, voice_analysis 에 사용될 Provider 이름 변경 가능성 높음

final audioPitchNoSaveProvider =
    StateNotifierProvider.autoDispose<AudioRecorderController, bool>((ref) {
      final util = AudioStreamRecorder(
        isFileSave: false,
        isPitchDetection: true,
        isRhythmDetection: false,
      );
      final controller = AudioRecorderController(streamRecorder: util);
      controller.init().then((_) => controller.startOrResume()); // 자동 녹음 시작
      ref.onDispose(() => controller.disposeRecorder());
      return controller; // controller 리턴 -> 위젯에서 controller 사용 가능
    });

final autoStartPitchStreamProvider = StreamProvider.autoDispose<PitchData>((
  ref,
) async* {
  final controller = ref.watch(audioPitchNoSaveProvider.notifier);

  // pitchStream이 null이 아니게 될 때까지 기다림
  while (controller.pitchStream == null) {
    await Future.delayed(Duration(milliseconds: 50));
  }

  yield* controller.pitchStream!;
});
