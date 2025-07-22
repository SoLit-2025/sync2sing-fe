import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/audio_stream_recorder.dart';
import '../../domain/evaluated_pitch.dart';

class AudioRecorderController extends StateNotifier<bool> {
  final AudioStreamRecorder streamRecorder;
  final List<int> _pitchDiffs = [];
  final List<double> _rhythmDiffs = [];
  bool get isPaused => streamRecorder.isPaused; // flutter sound의 recorder 상태 변수들
  bool get isRecording => streamRecorder.isRecording;
  bool get isStopped => streamRecorder.isStopped;

  AudioRecorderController({required this.streamRecorder}) : super(false);

  Stream<PitchData>? get pitchStream => streamRecorder.pitchStream;

  Future<void> init() async {
    await streamRecorder.init();
    _pitchDiffs.clear();
    _rhythmDiffs.clear();
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

    debugPrint("정확도 비교: $userMidi  | $targetMidi | $diff");
    return diff;
  }

  /// 음정 정확도 누적
  void onPitchEvaluated(EvaluatedPitch data) {
    debugPrint("onPitchEvaluated: pitch=${data.pitch}, diff=${data.pitchDiff}");
    _pitchDiffs.add(data.pitchDiff);
  }

  int get pitchAccuracy {
    if (_pitchDiffs.isEmpty) {
      debugPrint("pitch 정확도: pitchDiffs is empty");
      return 0;
    }
    return calculateTotalPitchAccuracy(_pitchDiffs, maxAllowedDiff: 8);
  }

  /// 음정 정확도 리스트(int) -> 100점 만점 정확도 환산
  /// maxAllowedDiff: 최대로 인정하는 음정 차이. 이 이상 차이나면 0점.
  int calculateTotalPitchAccuracy(List<int> pitchDiffs, {int maxAllowedDiff = 8}) {
    int tolerance = 1; // 이정도 차이까지는 감점 x
    if (pitchDiffs.isEmpty) return 0;

    final accuracies =
        pitchDiffs.map((diff) {
          if (diff <= tolerance) {
            return 1;
          }
          final a = (1 - (diff / maxAllowedDiff));
          return a.clamp(0, 1); // 0 미만 또는 1 초과 방지
        }).toList();

    final avgAccuracy = (accuracies.reduce((a, b) => a + b) / accuracies.length * 100).round();

    return avgAccuracy;
  }

  // 박자 정확도 관련
  // 박자 정확도 평가 함수
  void evaluateRhythm(double expectedTime, double actualTime) {
    final diff = (actualTime - expectedTime).abs();
    _rhythmDiffs.add(diff);

    /*
    // 🎯 박자 정확도 상세 로그
    String accuracyLevel;
    if (diff <= 0.1) {
      accuracyLevel = "🎯 완벽";
    } else if (diff <= 0.3) {
      accuracyLevel = "✅ 좋음";
    } else if (diff <= 0.5) {
      accuracyLevel = "⚠️ 보통";
    } else {
      accuracyLevel = "❌ 부정확";
    }

    debugPrint("🎵 [박자 채점] $accuracyLevel");
    debugPrint("   📍 예상: ${expectedTime.toStringAsFixed(3)}초");
    debugPrint("   ⏰ 실제: ${actualTime.toStringAsFixed(3)}초");
    debugPrint("   📊 차이: ${diff.toStringAsFixed(3)}초");
    debugPrint("   📈 누적 데이터: ${_rhythmDiffs.length}개");
    debugPrint("   ════════════════════════════════");
     */
  }

  // 박자 정확도 계산 (100점 만점)
  int get rhythmAccuracy {
    if (_rhythmDiffs.isEmpty) {
      debugPrint("rhythm 정확도: rhythmDiffs is empty");
      return 0;
    }
    return _calculateTotalRhythmAccuracy(_rhythmDiffs, maxAllowedDiff: 0.5); // 0.5초 허용
  }

  // 박자 정확도 리스트 -> 100점 만점 정확도 환산
  int _calculateTotalRhythmAccuracy(List<double> rhythmDiffs, {double maxAllowedDiff = 0.5}) {
    if (rhythmDiffs.isEmpty) return 0;

    final accuracies =
        rhythmDiffs.map((diff) {
          final accuracy = (1 - (diff / maxAllowedDiff));
          return accuracy.clamp(0, 1); // 0 미만 또는 1 초과 방지
        }).toList();

    final avgAccuracy = (accuracies.reduce((a, b) => a + b) / accuracies.length * 100).round();
    return avgAccuracy;
  }
  // 박자 채점 결과 누적

  // rhythm debugPrint 찍기
  void printRhythmAccuracyDetailStatistics() {
    // 박자 채점 결과 상세 통계
    debugPrint("🎵 ════════ 최종 박자 채점 결과 ════════");
    debugPrint("   🎯 최종 점수: $rhythmAccuracy점");
    debugPrint("   📊 총 채점 횟수: ${_rhythmDiffs.length}회");

    if (_rhythmDiffs.isNotEmpty) {
      final avgDiff = _rhythmDiffs.reduce((a, b) => a + b) / _rhythmDiffs.length;
      final minDiff = _rhythmDiffs.reduce((a, b) => a < b ? a : b);
      final maxDiff = _rhythmDiffs.reduce((a, b) => a > b ? a : b);

      debugPrint("   📈 평균 오차: ${avgDiff.toStringAsFixed(3)}초");
      debugPrint("   🎯 최소 오차: ${minDiff.toStringAsFixed(3)}초");
      debugPrint("   ⚠️ 최대 오차: ${maxDiff.toStringAsFixed(3)}초");

      // 정확도 분포 계산
      int perfect = _rhythmDiffs.where((diff) => diff <= 0.1).length;
      int good = _rhythmDiffs.where((diff) => diff > 0.1 && diff <= 0.3).length;
      int average = _rhythmDiffs.where((diff) => diff > 0.3 && diff <= 0.5).length;
      int poor = _rhythmDiffs.where((diff) => diff > 0.5).length;

      debugPrint("   🎯 완벽 (≤0.1초): $perfect회");
      debugPrint("   ✅ 좋음 (0.1~0.3초): $good회");
      debugPrint("   ⚠️ 보통 (0.3~0.5초): $average회");
      debugPrint("   ❌ 부정확 (>0.5초): $poor회");
    }

    debugPrint("   ════════════════════════════════════");
  }
}
