import 'package:flutter/material.dart';
import 'package:sync2sing/config/theme/app_colors.dart';

/// 🎼 하나의 막대가 언제 시작하고 끝나는지, 음정과 박자 정보를 저장하는 데이터 클래스
///
/// 각 필드의 의미:
/// - start: 막대의 시작 시간(초) 예: 1.5초
/// - end: 막대의 끝 시간(초) 예: 2.3초
/// - pitch: 음정(MIDI 넘버) 예: 60=C4(도), 62=D4(레)
/// - rhythm: 박자 정보 예: 'quarter'(4분음표)
///
/// 사용 예시:
/// PitchNoteBar(start: 1.0, end: 2.5, pitch: 60, rhythm: 'quarter')
/// → 1초부터 2.5초까지 1.5초 동안 C4(도) 음정이 지속되는 막대
class PitchNoteBar {
  final double start;
  final double end;
  final int pitch;
  final String rhythm;

  PitchNoteBar({
    required this.start,
    required this.end,
    required this.pitch,
    required this.rhythm,
  });

  @override
  String toString() =>
      'PitchNoteBar(start: $start, end: $end, pitch: $pitch, rhythm: $rhythm)';
}

/// 🎵 음정/박자 막대 시각화 위젯 (파라미터화)
///
/// 이 위젯은 노래방의 퍼펙트 스코어처럼 음정을 막대 형태로 시각화합니다.
///
/// 새로 추가된 핵심 기능:
/// - 실시간 사용자 음정 감지
/// - 왼쪽 가장자리 막대와 사용자 음정 매칭
/// - 매칭 성공 시 막대 색상 변경 (grayscale3 → grayscale1)
///
/// 외부에서 전달받는 데이터:
/// - notes: 표시할 막대들의 리스트 (JSON에서 로드한 음정 데이터)
/// - totalDuration: 노래 전체 길이 (MR 파일의 실제 길이)
/// - currentPosition: 현재 재생 위치 (실시간으로 변화)
/// - bpm: 노래의 템포(분당 박자 수) (막대 이동 속도 조정용)
/// - userCurrentPitch: 사용자가 현재 부르고 있는 음정 (실시간 매칭용)
class PitchAndRhythmBar extends StatelessWidget {
  final List<PitchNoteBar> notes;
  final Duration totalDuration;
  final Duration currentPosition;
  final double bpm;
  final int? userCurrentPitch; // 사용자 현재 음정 파라미터 (새로 추가!)

  const PitchAndRhythmBar({
    super.key,
    required this.notes,
    required this.totalDuration,
    required this.currentPosition,
    this.bpm = 120.0, // 기본값: 120 BPM
    this.userCurrentPitch, // 사용자 음정 (null이면 음성 없음)
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 155, // music_content_player.dart의 Container height와 일치
      alignment: Alignment.center,
      child: CustomPaint(
        painter: PitchAndRhythmBarPainter(
          notes: notes,
          currentPosition: currentPosition,
          totalDuration: totalDuration,
          bpm: bpm,
          userCurrentPitch: userCurrentPitch, // 사용자 음정 전달
        ),
        size: const Size(double.infinity, 155), // 높이를 155로 통일
      ),
    );
  }
}

/// 🎨 막대 시각화 및 이동을 담당하는 클래스
///
/// 주요 기능:
/// 1. 각 막대의 위치, 길이, 색상, 모서리 둥글기 설정
/// 2. 현재 재생 위치에 맞게 막대들을 오른쪽에서 왼쪽으로 이동
/// 3. BPM에 따른 올바른 동적 속도 조정 (재생 위치와 분리)
/// 4. 음정에 따른 Y축 위치 계산 (높은 음정 = 위쪽, 낮은 음정 = 아래쪽)
/// 5. 🎯 실시간 음정 매칭 및 색상 변경 (새로 추가!)
///
/// 핵심 로직:
/// - 왼쪽 가장자리에 닿는 막대를 감지
/// - 사용자 음정과 기준 음정을 비교
/// - 매칭 성공 시 막대 색상을 밝게 변경
class PitchAndRhythmBarPainter extends CustomPainter {
  final List<PitchNoteBar> notes;
  final Duration currentPosition;
  final Duration totalDuration;
  final double bpm;
  final int? userCurrentPitch; // 사용자 현재 음정

  PitchAndRhythmBarPainter({
    required this.notes,
    required this.currentPosition,
    required this.totalDuration,
    required this.bpm,
    required this.userCurrentPitch,
  });

  @override
  void paint(Canvas canvas, Size size) {
    /// ⏱️ 시간 관련 계산
    /// - totalSeconds: 노래 전체 길이(초)
    /// - progressSeconds: 현재 재생된 시간(초)
    final totalSeconds = totalDuration.inMilliseconds / 1000.0;
    final progressSeconds = currentPosition.inMilliseconds / 1000.0;

    /// 🥁 BPM 기반 속도 조정 (수정된 올바른 방식!)
    ///
    /// 문제였던 기존 방식: BPM을 재생 위치에 직접 곱해서 동기화 깨짐
    /// 개선된 방식: 재생 위치 동기화와 BPM 시각 효과를 분리
    ///
    /// 1. 기본 이동: 재생 위치에 정확히 동기화
    /// 2. BPM 효과: 시각적 속도감만 조정
    final baseBPM = 120.0; // 기준 BPM
    final bpmSpeedMultiplier = bpm / baseBPM; // 🔧 수정: bmp → bpm

    // 기본 이동 거리 (재생 위치와 정확히 동기화)
    final baseShiftX = (progressSeconds / totalSeconds) * size.width;

    // BPM에 따른 추가 시각적 효과 (막대가 더 빠르게 흘러가는 느낌)
    // 효과 강도 100: 이 값을 조정하여 BPM 효과의 강도를 변경 가능
    final bpmEffect = progressSeconds * (bpmSpeedMultiplier - 1.0) * 100; // 🔧 수정: bmpSpeedMultiplier → bpmSpeedMultiplier

    /// 최종 이동 거리 = 기본 동기화 + BPM 시각 효과
    final shiftX = baseShiftX + bpmEffect;

    /// 📊 음정 범위 계산 (실제 데이터 기반으로 Y축 위치 결정)
    /// 막대가 없으면 그리기 중단
    if (notes.isEmpty) return;

    /// 모든 막대의 음정 중 최고음과 최저음을 찾기
    /// 이를 통해 Y축 위치를 상대적으로 계산할 수 있습니다
    ///
    /// 예시:
    /// - 최저음: MIDI 48 (C3, 낮은 도)
    /// - 최고음: MIDI 72 (C5, 높은 도)
    /// - 범위: 24 (2옥타브)
    final pitches = notes.map((note) => note.pitch).toList();
    final minPitch = pitches.reduce((a, b) => a < b ? a : b); // 최저음
    final maxPitch = pitches.reduce((a, b) => a > b ? a : b); // 최고음
    final pitchRange = maxPitch - minPitch; // 음정 범위

    /// 📐 Y좌표를 위젯 크기(155)에 맞게 정규화하는 함수
    ///
    /// 동작 원리:
    /// 1. 높은 음정일수록 위쪽, 낮은 음정일수록 아래쪽에 배치
    /// 2. 모든 막대가 155px 높이 내에서만 그려지도록 보장
    /// 3. 상하 10% 여백을 두고 80% 영역에 배치
    ///
    /// 예시:
    /// - 최고음: 화면 상단 10% 지점 (15.5px)
    /// - 최저음: 화면 하단 10% 지점 (139.5px)
    /// - 중간음: 화면 중앙 (77.5px)
    ///
    /// 계산 과정:
    /// 1. (pitch - minPitch) / pitchRange → 0~1로 정규화
    /// 2. (1.0 - normalized) → 높은 음정일수록 0에 가까워짐
    /// 3. * 0.8 + 0.1 → 상하 10% 여백 확보
    double normalizeY(int pitch) {
      if (pitchRange == 0) return size.height / 2; // 모든 음정이 같으면 중앙

      // 0~1로 정규화 (0: 최저음정, 1: 최고음정)
      final normalized = (pitch - minPitch) / pitchRange;

      // 상하 10% 여백을 두고 80% 영역에 배치
      // (1.0 - normalized): 높은 음정일수록 위쪽(0에 가까움)
      return size.height * (1.0 - normalized) * 0.8 + size.height * 0.1;
    }

    /// 🎼 각 막대를 순회하며 그리기
    for (final bar in notes) {
      /// 📍 막대의 시작/끝 X좌표 계산 (시간에 따라 이동)
      /// - startX: 막대의 왼쪽 끝 위치
      /// - endX: 막대의 오른쪽 끝 위치
      /// - shiftX를 빼서 왼쪽으로 이동하는 효과 구현
      ///
      /// 예시:
      /// - bar.start = 10초, bar.end = 12초 (2초 길이 막대)
      /// - totalSeconds = 100초, size.width = 1000px
      /// - startX = (10/100) * 1000 - shiftX = 100 - shiftX
      /// - endX = (12/100) * 1000 - shiftX = 120 - shiftX
      final startX = (bar.start / totalSeconds) * size.width - shiftX;
      final endX = (bar.end / totalSeconds) * size.width - shiftX;

      /// ⚡ 화면 밖에 있는 막대는 그리지 않음 (성능 최적화)
      /// 보이지 않는 막대를 그리는 것은 자원 낭비이므로 건너뜁니다
      if (endX < 0 || startX > size.width) continue;

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

      /// 🎯 핵심 기능: 음정 매칭 판별
      ///
      /// 동작 원리:
      /// 1. 막대가 왼쪽 가장자리에 닿았는지 확인 (isAtLeftEdge)
      /// 2. 사용자가 현재 노래를 부르고 있는지 확인 (userCurrentPitch != null)
      /// 3. 사용자 음정과 기준 음정의 차이 계산
      /// 4. 허용 오차 범위(±2 semitone) 내에 있으면 매칭 성공
      ///
      /// 예시:
      /// - 기준 음정: 60 (C4, 도)
      /// - 사용자 음정: 61 (C#4, 도#)
      /// - 차이: |61 - 60| = 1 ≤ 2 → 매칭 성공! ✅
      ///
      /// - 기준 음정: 60 (C4, 도)
      /// - 사용자 음정: 65 (F4, 파)
      /// - 차이: |65 - 60| = 5 > 2 → 매칭 실패 ❌
      ///
      /// 허용 오차 ±2 semitone인 이유:
      /// - 1 semitone = 반음 (도→도#, 레→레# 등)
      /// - ±2 semitone = 약간의 음정 오차 허용 (너무 엄격하지 않게)
      /// - 일반인도 쉽게 성공할 수 있는 적당한 난이도
      bool isPitchMatched = false;
      if (isAtLeftEdge && userCurrentPitch != null) {
        int pitchDifference = (userCurrentPitch! - bar.pitch).abs();
        isPitchMatched = pitchDifference <= 2; // ±2 semitone 허용 오차
      }

      /// 🎨 색상 결정 로직
      ///
      /// 조건별 색상:
      /// 1. 왼쪽 가장자리 + 음정 매칭 성공 → grayscale1 (밝은 회색, 성공 표시)
      /// 2. 그 외 모든 경우 → grayscale3 (기본 회색)
      ///
      /// 이렇게 하면 사용자가 정확한 음정으로 노래할 때만 막대가 밝아집니다!
      ///
      /// 시각적 효과:
      /// - 평소: 회색 막대들이 흘러감
      /// - 정확한 음정으로 노래할 때: 해당 막대만 밝은 회색으로 변함
      /// - 즉시 피드백으로 사용자가 자신의 음정 정확도를 실시간으로 확인 가능
      final paint = Paint()
        ..color = (isAtLeftEdge && isPitchMatched)
            ? AppColors.grayscale1  // 매칭 성공 시 밝은 색
            : AppColors.grayscale3  // 기본 색
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.0;

      /// 📐 음정에 따른 Y좌표 계산 (정규화된 값)
      /// 높은 음정은 위쪽, 낮은 음정은 아래쪽에 배치됩니다
      final y = normalizeY(bar.pitch);

      /// 🎨 막대 그리기 (두께 16px: 위아래 8px씩)
      ///
      /// Rect.fromLTRB 파라미터:
      /// - Left: 막대의 왼쪽 끝 (화면 밖으로 나가지 않도록 제한)
      /// - Top: 막대의 위쪽 (위젯 영역 내로 제한)
      /// - Right: 막대의 오른쪽 끝 (화면 밖으로 나가지 않도록 제한)
      /// - Bottom: 막대의 아래쪽 (위젯 영역 내로 제한)
      ///
      /// clamp 함수의 역할:
      /// - startX.clamp(0, size.width): X좌표가 0~width 범위를 벗어나지 않도록 제한
      /// - (y - 8).clamp(0, size.height): Y좌표가 0~height 범위를 벗어나지 않도록 제한
      ///
      /// 막대 두께 16px (y-8 ~ y+8):
      /// - 기존 12px에서 16px로 증가하여 시각적 가독성 향상
      /// - 모바일 환경에서도 충분히 보이는 크기
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTRB(
          startX.clamp(0, size.width),           // 왼쪽 끝
          (y - 8).clamp(0, size.height),         // 위쪽 (중앙에서 8px 위)
          endX.clamp(0, size.width),             // 오른쪽 끝
          (y + 8).clamp(0, size.height),         // 아래쪽 (중앙에서 8px 아래)
        ),
        const Radius.circular(4), // 모서리 둥글기 (4px 반지름)
      );
      canvas.drawRRect(rect, paint);
    }
  }

  /// 🔄 재생 위치나 사용자 음정이 바뀔 때마다 항상 다시 그리도록 설정
  ///
  /// 이렇게 해야 다음 효과들이 실시간으로 나타납니다:
  /// 1. 막대가 오른쪽에서 왼쪽으로 이동하는 애니메이션
  /// 2. 사용자 음정 매칭에 따른 막대 색상 변화
  /// 3. BPM에 따른 동적 속도 조정
  ///
  /// shouldRepaint가 false를 반환하면:
  /// - 막대가 움직이지 않음
  /// - 색상 변화가 나타나지 않음
  /// - 정적인 이미지로만 표시됨
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
