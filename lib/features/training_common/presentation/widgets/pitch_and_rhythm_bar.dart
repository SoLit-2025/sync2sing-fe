import 'package:flutter/material.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/shared/providers/audio_position_provider.dart';

// 하나의 막대가 언제 시작하고 끝나는지, 음정과 박자 정보 저장
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

// 음정/박자 막대 시각화 위젯 (파라미터화)
class PitchAndRhythmBar extends StatelessWidget {
  final List<PitchNoteBar> notes;
  final Duration totalDuration;
  final Duration currentPosition;

  const PitchAndRhythmBar({
    super.key,
    required this.notes,
    required this.totalDuration,
    required this.currentPosition,
  });

  @override
  Widget build(BuildContext context) {
    // 테스트용 로그
    print('--- PitchAndRhythmBar build ---');
    print('currentPosition: $currentPosition');
    print('totalDuration: $totalDuration');
    print('notes.length: ${notes.length}');
    if (notes.isNotEmpty) {
      print('first note: ${notes.first}');
      print('last note: ${notes.last}');
    }

    return Container(
      height: 32,
      alignment: Alignment.center,
      child: CustomPaint(
        painter: PitchAndRhythmBarPainter(
          notes: notes,
          currentPosition: currentPosition,
          totalDuration: totalDuration,
        ),
        size: const Size(double.infinity, 20),
      ),
    );
  }
}

// 막대 시각화 및 이동: 각 막대의 위치, 길이, 색상, 모서리 둥글기를 설정한 뒤 현재 재생 위치에 맞게 이동
class PitchAndRhythmBarPainter extends CustomPainter {
  final List<PitchNoteBar> notes;
  final Duration currentPosition;
  final Duration totalDuration;

  PitchAndRhythmBarPainter({
    required this.notes,
    required this.currentPosition,
    required this.totalDuration,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.grayscale2
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.0;

    final totalSeconds = totalDuration.inMilliseconds / 1000.0;
    final progressSeconds = currentPosition.inMilliseconds / 1000.0;

    // 테스트용 로그
    print('--- PitchAndRhythmBarPainter paint ---');
    print('totalSeconds: $totalSeconds');
    print('progressSeconds: $progressSeconds');
    print('canvas size.width: ${size.width}, size.height: ${size.height}');

    if (totalSeconds == 0) {
      print('Warning: totalSeconds is 0. Nothing will be drawn.');
      return;
    }

    final shiftX = (progressSeconds / totalSeconds) * size.width;
    print('shiftX: $shiftX');

    for (final bar in notes) {
      final startX = (bar.start / totalSeconds) * size.width - shiftX;
      final endX = (bar.end / totalSeconds) * size.width - shiftX;

      // 테스트용 로그
      print(
          'Drawing bar: start=${bar.start}, end=${bar.end}, pitch=${bar.pitch}, startX=$startX, endX=$endX');

      if (endX < 0 || startX > size.width) {
        print('Bar out of visible range, skipping.');
        continue;
      }

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTRB(
          startX.clamp(0, size.width),
          size.height / 2 - 1,
          endX.clamp(0, size.width),
          size.height / 2 + 1,
        ),
        const Radius.circular(4),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
