import 'package:flutter/material.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';
import 'package:sync2sing/features/curriculum/logics/timed_lyric.dart';

class LyricsSection extends StatelessWidget {
  final List<TimedLyric> lyrics;
  final Duration currentPosition;
  const LyricsSection({super.key, required this.lyrics, required this.currentPosition});

  @override
  Widget build(BuildContext context) {
    // 현재 위치에 맞는 가사 인덱스를 찾음
    int currentLyricIndex = -1; // 시작: 아무 텍스트도 색 바꾸지 x
    for (int i = 0; i < lyrics.length; i++) {
      if (currentPosition.inMilliseconds >= lyrics[i].startTime) {
        currentLyricIndex = i;
      } else {
        break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children:
          lyrics.asMap().entries.map((entry) {
            int idx = entry.key;
            TimedLyric item = entry.value;

            // 현재 가사일 경우 색상 변경
            final color = (idx == currentLyricIndex) ? AppColors.grayscale3 : AppColors.grayscale4;

            return Text(
              item.text,
              style: AppTextStyles.heading2Bold.copyWith(color: color),
              textAlign: TextAlign.center,
            );
          }).toList(),
    );
  }
}
