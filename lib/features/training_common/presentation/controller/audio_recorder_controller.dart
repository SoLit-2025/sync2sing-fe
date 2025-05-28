import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/audio_recorder_util.dart';

class AudioRecorderController extends StateNotifier<bool> {
  final AudioRecorderUtil recorderUtil;

  AudioRecorderController({required this.recorderUtil}) : super(false);

  Future<void> init() async {
    await recorderUtil.init();
  }

  Future<void> startOrResume() async {
    await recorderUtil.startOrResumeRecorder();
    state = true;
  }

  Future<void> pause() async {
    await recorderUtil.pauseRecorder();
    state = false;
  }

  Future<void> stop() async {
    await recorderUtil.stopRecorder();
    state = false;
  }

  Future<void> disposeRecorder() async {
    await recorderUtil.dispose();
  }

  Stream<PitchData>? get pitchStream => recorderUtil.pitchStream;
}
