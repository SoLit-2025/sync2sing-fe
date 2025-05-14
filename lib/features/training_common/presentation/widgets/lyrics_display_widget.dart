import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';

class LyricsSection extends StatefulWidget {
  const LyricsSection({super.key});

  @override
  State<LyricsSection> createState() => _LyricsSectionState();
}

class _LyricsSectionState extends State<LyricsSection> {
  @override
  Widget build(BuildContext context) {
    return Text(
      "(전주중) \nDO - a deer, \na female deer \nRE - a drop of",
      style: AppTextStyles.display1Bold.copyWith(color: AppColors.grayscale3),
      textAlign: TextAlign.left,
    );
  }
}
