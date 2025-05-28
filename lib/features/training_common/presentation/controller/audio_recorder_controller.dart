import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/audio_stream_recorder.dart';

class AudioRecorderController extends StateNotifier<bool> {
  final AudioStreamRecorder streamRecorder;

  AudioRecorderController({required this.streamRecorder}) : super(false);

  Future<void> init() async {
    await streamRecorder.init();
  }

  Future<void> startOrResume() async {
    await streamRecorder.startOrResumeRecorder();
    state = true;
  }

  Future<void> pause() async {
    await streamRecorder.pauseRecorder();
    state = false;
  }

  Future<void> stop() async {
    await streamRecorder.stopRecorder();
    state = false;
  }

  Future<void> disposeRecorder() async {
    await streamRecorder.dispose();
  }

  Stream<PitchData>? get pitchStream => streamRecorder.pitchStream;
}
