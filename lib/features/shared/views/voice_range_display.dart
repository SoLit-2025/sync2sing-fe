import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';

class VoiceRangeDisplay extends StatelessWidget {
  final String pitchNoteMin;
  final String pitchNoteMax;
  final String title;

  const VoiceRangeDisplay({
    super.key,
    required this.pitchNoteMin,
    required this.pitchNoteMax,
    this.title = "노래 음역대",
  });

  static int _noteToNumber(String note) {
    if (note.isEmpty) return -1;

    final Map<String, int> noteMap = {
      'C': 0,
      'C#': 1,
      'Db': 1,
      'D': 2,
      'D#': 3,
      'Eb': 3,
      'E': 4,
      'F': 5,
      'F#': 6,
      'Gb': 6,
      'G': 7,
      'G#': 8,
      'Ab': 8,
      'A': 9,
      'A#': 10,
      'Bb': 10,
      'B': 11,
    };

    final RegExp octaveRegex = RegExp(r'\d+');
    final Match? octaveMatch = octaveRegex.firstMatch(note);
    if (octaveMatch == null) return -1;

    final int? octave = int.tryParse(octaveMatch.group(0)!);
    if (octave == null || octave < 0) return -1;

    final String noteName = note.replaceAll(octaveRegex, '');
    final int? noteValue = noteMap[noteName];
    if (noteValue == null) return -1;

    //  C0 = 0, C1 = 12)
    return (octave * 12) + noteValue;
  }

  @override
  Widget build(BuildContext context) {
    // 바의 음정 범위
    const String barMinNoteString = 'G#2';
    const String barMaxNoteString = 'C6';

    final int barMinNum = _noteToNumber(barMinNoteString); // 32
    final int barMaxNum = _noteToNumber(barMaxNoteString); // 60

    // 예외값 처리
    if (barMinNum == -1 || barMaxNum == -1 || barMaxNum <= barMinNum) {
      return const SizedBox.shrink();
    }

    // bar 차이값 구하기 -> 0 ~ 가장 오른쪽 값 구함.
    final int totalBarRangeSemitones = barMaxNum - barMinNum;

    final int songMinNum = _noteToNumber(pitchNoteMin);
    final int songMaxNum = _noteToNumber(pitchNoteMax);

    // 바에서 상대적인 위치 정하기
    double startOffsetSemitones = (songMinNum - barMinNum).toDouble().clamp(
      0.0,
      totalBarRangeSemitones.toDouble(),
    );
    double endOffsetSemitones = (songMaxNum - barMinNum).toDouble().clamp(
      0.0,
      totalBarRangeSemitones.toDouble(),
    );

    // 최대 노트가 최소 노트값보다 작은 경우
    if (endOffsetSemitones < startOffsetSemitones) {
      endOffsetSemitones = startOffsetSemitones;
    }

    final double startFactor = startOffsetSemitones / totalBarRangeSemitones; // 시작 위치 퍼센트값
    final double widthFactor =
        (endOffsetSemitones - startOffsetSemitones) / totalBarRangeSemitones; // 음정 막대 길이

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.grayscale8,
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: AppColors.grayscale6, width: 1.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.body4),
          SizedBox(
            width: 200.w,
            child: Column(
              children: [
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final double barWidth = constraints.maxWidth; // 주어진 widgth 를 모두 사용

                    // minNote / max 시작 위치
                    final double songMinNoteX = startFactor * barWidth;
                    final double songMaxNoteX = (startFactor + widthFactor) * barWidth;
                    final double minNoteLabelAdjustedX = (songMinNoteX - 5).clamp(0, songMinNoteX);
                    final double maxNoteLabelAdjustedX = songMaxNoteX - 5;

                    return SizedBox(
                      width: double.infinity,
                      height: 16.h,
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            left: minNoteLabelAdjustedX,
                            child: Text(pitchNoteMin, style: AppTextStyles.body6),
                          ),
                          Positioned(
                            left: maxNoteLabelAdjustedX.clamp(
                              minNoteLabelAdjustedX + 15,
                              barWidth - 18,
                            ),
                            child: Text(pitchNoteMax, style: AppTextStyles.body6),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: 6.h),
                // 막대 바
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final double barWidth = constraints.maxWidth;
                    return Container(
                      height: 7.h,
                      decoration: BoxDecoration(
                        color: AppColors.grayscale6,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Stack(
                        children: <Widget>[
                          // 노래 음역대 표시.
                          Positioned(
                            left: startFactor * barWidth,
                            width: widthFactor * barWidth,
                            child: Container(
                              height: 7.h,
                              decoration: BoxDecoration(
                                color: AppColors.primaryPink,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
