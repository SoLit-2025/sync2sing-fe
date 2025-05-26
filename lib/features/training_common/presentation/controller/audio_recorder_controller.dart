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

// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// import '../../data/services/audio_recorder_util.dart';
//
// class RecorderState {
//   final bool isRecording;
//   final double? currentPitch;
//
//   RecorderState({required this.isRecording, this.currentPitch});
//
//   RecorderState copyWith({bool? isRecording, double? currentPitch}) {
//     return RecorderState(
//       isRecording: isRecording ?? this.isRecording,
//       currentPitch: currentPitch ?? this.currentPitch,
//     );
//   }
// }
//
// class AudioRecorderController extends StateNotifier<RecorderState> {
//   final AudioRecorderUtil _util;
//
//   AudioRecorderController(this._util)
//     : super(RecorderState(isRecording: false)) {
//     _util.pitchStream.listen((pitch) {
//       state = state.copyWith(currentPitch: pitch);
//     });
//   }
//
//   Future<void> startOrResume() async {
//     await _util.startRecorder();
//     state = state.copyWith(isRecording: true);
//   }
//
//   Future<void> pause() async {
//     await _util.pauseRecorder();
//     state = state.copyWith(isRecording: false);
//   }
//
//   Future<void> stop() async {
//     await _util.stopRecorder();
//     state = state.copyWith(isRecording: false);
//   }
//
//   @override
//   void dispose() {
//     _util.dispose();
//     super.dispose();
//   }
// }
