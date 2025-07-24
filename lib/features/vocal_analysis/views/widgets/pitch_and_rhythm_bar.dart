import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/features/vocal_analysis/logics/providers/target_pitch_provider.dart';

// 음정 막대 데이터 클래스
class PitchNoteBar {
  final double start;
  final double end;
  final int pitch;
  final double duration;

  PitchNoteBar({
    required this.start,
    required this.end,
    required this.pitch,
    required this.duration,
  });

  @override
  String toString() => 'PitchNoteBar(start: $start, end: $end, pitch: $pitch, duration: $duration)';
}

// 음정/박자 막대 위젯
class PitchAndRhythmBar extends ConsumerWidget {
  final List<PitchNoteBar> notes;
  final Duration totalDuration;
  final Duration currentPosition;
  final double bpm;
  final int? userCurrentPitch;
  final void Function(double expectedTime, double actualTime)? onRhythmEvaluated; // 박자 채점 콜백

  const PitchAndRhythmBar({
    super.key,
    required this.notes,
    required this.totalDuration,
    required this.currentPosition,
    this.bpm = 88.0,
    this.userCurrentPitch,
    this.onRhythmEvaluated,
  });

  int _calculateCurrentIndex(Duration currentPosition, double bpm) {
    final barDurationInMs = (60 * 1000) / bpm; // 한 bar가 몇 밀리초인지
    final currentTimeInMs = currentPosition.inMilliseconds;

    return (currentTimeInMs / barDurationInMs).floor();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = _calculateCurrentIndex(currentPosition, bpm);

    // 현재 기준 음 높이 설정
    if (currentIndex >= 0 && currentIndex < notes.length) {
      final currentPitch = notes[currentIndex].pitch;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(targetPitchProvider.notifier).state = currentPitch; // 현재 원곡의 음정 저장
      });
    }

    return CustomPaint(
      painter: PitchAndRhythmBarPainter(
        notes: notes,
        currentPosition: currentPosition,
        totalDuration: totalDuration,
        bpm: bpm,
        userCurrentPitch: userCurrentPitch,
        onRhythmEvaluated: onRhythmEvaluated,
      ),
      size: Size.infinite,
    );
  }
}

// 음정/박자 막대 그리기 클래스
class PitchAndRhythmBarPainter extends CustomPainter {
  final List<PitchNoteBar> notes;
  final Duration currentPosition;
  final Duration totalDuration;
  final double bpm;
  final int? userCurrentPitch;
  final void Function(double expectedTime, double actualTime)? onRhythmEvaluated;

  // 중복 로그 방지를 위한 변수들
  static int _lastLoggedNoteIndex = -1;
  static double _lastLoggedTime = -1;

  PitchAndRhythmBarPainter({
    required this.notes,
    required this.currentPosition,
    required this.totalDuration,
    required this.bpm,
    required this.userCurrentPitch,
    this.onRhythmEvaluated,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (notes.isEmpty) return;

    // 전체 시간 (초)
    final totalSeconds = totalDuration.inMilliseconds / 1000.0;
    // 현재 재생 시간 (초)
    final progressSeconds = currentPosition.inMilliseconds / 1000.0;

    // BPM 기반 이동 속도 계산
    final pixelsPerSecond = size.width / totalSeconds;
    final shiftX = progressSeconds * pixelsPerSecond;

    // 음정 범위 계산 (MIDI 번호 기준)
    final pitches = notes.map((note) => note.pitch).toList();
    final minPitch = pitches.reduce(min);
    final maxPitch = pitches.reduce(max);
    final pitchRange = maxPitch - minPitch;

    // Y축 정규화 함수 (음정을 Y 좌표로 변환)
    double normalizeY(int pitch) {
      if (pitchRange == 0) return size.height / 2;
      final normalizedPitch = (pitch - minPitch) / pitchRange;
      return size.height - (normalizedPitch * size.height * 0.8 + size.height * 0.1);
    }

    // 각 음정 막대 그리기
    for (int i = 0; i < notes.length; i++) {
      final bar = notes[i];
      final startX = (bar.start / totalSeconds) * size.width - shiftX;
      final endX = (bar.end / totalSeconds) * size.width - shiftX;

      /// 🎯 핵심 기능: 왼쪽 가장자리에 닿는 막대 감지
      ///
      /// 조건:
      /// - startX <= 0: 막대의 시작점이 화면 왼쪽 끝에 도달했거나 지나감
      /// - endX > 0: 막대의 끝점이 아직 화면에 보임
      ///
      /// 이 조건을 만족하는 막대가 "현재 사용자가 불러야 할 음정"입니다
      ///
      /// 시각적 예시:
      /// ```
      /// |←화면 왼쪽 가장자리(x=0)
      /// |  ████████  ← 이 막대가 감지됨 (startX <= 0, endX > 0)
      /// |
      /// ```
      bool isAtLeftEdge = startX <= 0 && endX > 0;

      // 음정 매칭 로직 (기존)
      bool isPitchMatched = false;
      if (isAtLeftEdge && userCurrentPitch != null) {
        int pitchDifference = (userCurrentPitch! - bar.pitch).abs();
        isPitchMatched = pitchDifference <= 3; // 허용 오차를 3으로 조정
      }

      // 🔍 디버깅: 실시간 박자 로그 (중복 방지)
      if (isAtLeftEdge &&
          (_lastLoggedNoteIndex != i || (progressSeconds - _lastLoggedTime).abs() > 0.1)) {
        debugPrint("🎵 [박자 디버깅] 막대 #$i가 왼쪽 가장자리에 도달!");
        debugPrint("   📍 예상 시간: ${bar.start.toStringAsFixed(3)}초");
        debugPrint("   ⏰ 현재 시간: ${progressSeconds.toStringAsFixed(3)}초");
        debugPrint("   📊 시간 차이: ${(progressSeconds - bar.start).toStringAsFixed(3)}초");
        debugPrint("   🎤 사용자 음정: ${userCurrentPitch ?? 'null'} (목표: ${bar.pitch})");
        debugPrint("   🎯 음정 매칭: ${isPitchMatched ? '성공' : '실패'}");
        debugPrint("   ⏱️  막대 지속시간: ${bar.duration.toStringAsFixed(3)}초");
        debugPrint("   ────────────────────────────────");

        _lastLoggedNoteIndex = i;
        _lastLoggedTime = progressSeconds;
      }

      // 박자 채점 로직 (새로 추가)
      if (isAtLeftEdge && onRhythmEvaluated != null && userCurrentPitch != null) {
        // 막대가 왼쪽 가장자리에 닿는 예상 시간
        final expectedTime = bar.start;
        // 현재 재생 시간
        final actualTime = progressSeconds;

        // 사용자가 노래하고 있을 때만 박자 평가
        onRhythmEvaluated!(expectedTime, actualTime);
      }

      // 색상 결정
      final paint =
          Paint()
            ..color =
                (isAtLeftEdge && isPitchMatched) ? AppColors.primaryPink : AppColors.grayscale3
            ..strokeCap = StrokeCap.round
            ..strokeWidth = 2.0;

      // 막대 그리기
      final y = normalizeY(bar.pitch);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTRB(
          startX.clamp(0, size.width),
          (y - 8).clamp(0, size.height),
          endX.clamp(0, size.width),
          (y + 8).clamp(0, size.height),
        ),
        const Radius.circular(4),
      );
      canvas.drawRRect(rect, paint);
    }

    // 왼쪽 가장자리 기준선 그리기 (디버깅용)
    final linePaint =
        Paint()
          ..color = AppColors.primaryPink
          ..strokeWidth = 2.0;
    canvas.drawLine(const Offset(0, 0), Offset(0, size.height), linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
