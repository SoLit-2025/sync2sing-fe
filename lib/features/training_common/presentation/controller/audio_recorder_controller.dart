import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/audio_stream_recorder.dart';
import '../../domain/evaluated_pitch.dart';

class AudioRecorderController extends StateNotifier<bool> {
  final AudioStreamRecorder streamRecorder;
  final List<bool> _pitchResults = [];

  AudioRecorderController({required this.streamRecorder}) : super(false);

  Stream<PitchData>? get pitchStream => streamRecorder.pitchStream;

  Future<void> init() async {
    await streamRecorder.init();
    _pitchResults.clear();
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

  String getWavFilePath() {
    if (streamRecorder.recordingFilePath == null) {
      debugPrint("오류: 파일 경로가 없습니다.");
    }
    return streamRecorder.recordingFilePath!;
  }

  /// 기준과 비교해 정답 여부 판단
  bool evaluatePitch(int userPitch, int targetPitch) {
    // userPItch: frequency, targetPitch: MIDI
    const tolerance = EvaluatedPitch.tolerance; // midi 기준 오차 허용 범위 : 10 --> 나중에 조정하기

    debugPrint("정확도 비교: ${userPitch}  | ${targetPitch}"); //_frequencyToMidi(userPitch)
    _pitchResults.add((userPitch - targetPitch).abs() <= tolerance);
    // return (_frequencyToMidi(userPitch) - _frequencyToMidi(targetPitch)).abs() <= tolerance;
    return (userPitch - targetPitch).abs() <= tolerance;
  }

  /// 정확도 누적
  void onPitchEvaluated(EvaluatedPitch data) {
    debugPrint("onPitchEvaluated: ${data.isCorrect} | ${data.pitch}");
    _pitchResults.add(data.isCorrect);
  }

  int get pitchAccuracy {
    if (_pitchResults.isEmpty) {
      debugPrint("pitch 정확도: pitchResults is empty");
      return 0;
    }
    final correctCount = _pitchResults.where((e) => e).length;
    return ((correctCount / _pitchResults.length) * 100).round();
  }

  // // 주파수를 MIDI 넘버로 변환하는 함수
  // int _frequencyToMidi(double frequency) {
  //   // A4 = 440Hz = MIDI 69를 기준으로 계산
  //   double midiDouble = 12 * (log(frequency / 440) / log(2)) + 69;
  //
  //   // 반올림하여 정수로 변환 (MIDI는 정수값만 사용)
  //   return midiDouble.round();
  // }
}
