import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/training_common/data/services/audio_recorder_util.dart';
import '../../features/training_common/presentation/controller/audio_recorder_controller.dart';

// max/min_pitch, voice_analysis 에 사용될 Provider

final audioRecorderProvider2 =
    StateNotifierProvider.autoDispose<AudioRecorderController, bool>((ref) {
      final util = AudioRecorderUtil(
        isFileSave: false,
        isPitchDetection: true,
        enableRhythmDetection: false,
      );
      final controller = AudioRecorderController(recorderUtil: util);
      controller.init(); // Provider 생성 시 초기화
      ref.onDispose(() => controller.disposeRecorder());
      return controller;
    });
