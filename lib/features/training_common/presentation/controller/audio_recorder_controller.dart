import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/audio_stream_recorder.dart';
import '../../domain/evaluated_pitch.dart';

class AudioRecorderController extends StateNotifier<bool> {
  final AudioStreamRecorder streamRecorder;
  final List<int> _pitchDiffs = [];

  AudioRecorderController({required this.streamRecorder}) : super(false);

  Stream<PitchData>? get pitchStream => streamRecorder.pitchStream;

  Future<void> init() async {
    await streamRecorder.init();
    _pitchDiffs.clear();
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

  /// 기준(원곡 음정)과 비교해 정답 여부 판단
  int evaluatePitch(int userMidi, int targetMidi) {
    final diff = (userMidi - targetMidi).abs();
    _pitchDiffs.add(diff);

    // debugPrint("정확도 비교: $userMidi  | $targetMidi | $diff");
    return diff;
  }

  /// 정확도 누적
  void onPitchEvaluated(EvaluatedPitch data) {
    debugPrint("onPitchEvaluated: pitch=${data.pitch}, diff=${data.pitchDiff}");
    _pitchDiffs.add(data.pitchDiff);
  }

  int get pitchAccuracy {
    if (_pitchDiffs.isEmpty) {
      debugPrint("pitch 정확도: pitchDiffs is empty");
      return 0;
    }
    // int type으로 계산
    return calculateTotalPitchAccuracy(_pitchDiffs, maxAllowedDiff: 8);
  }

  /// 음정 정확도 리스트(int) -> 100점 만점 정확도 환산
  /// maxAllowedDiff: 최대로 인정하는 음정 차이 (미디 기준)
  /// maxAllowedDiff 이하로 차이가 나더라도 음정이 정확히 일치하지 않으면 점수를 깎음
  int calculateTotalPitchAccuracy(List<int> pitchDiffs, {int maxAllowedDiff = 5}) {
    if (pitchDiffs.isEmpty) return 0;

    final accuracies =
        pitchDiffs.map((diff) {
          final a = (1 - (diff / maxAllowedDiff));
          return a.clamp(0, 1); // 0 미만 또는 1 초과 방지
        }).toList();

    final avgAccuracy = (accuracies.reduce((a, b) => a + b) / accuracies.length * 100).round();

    return avgAccuracy;
  }
}
