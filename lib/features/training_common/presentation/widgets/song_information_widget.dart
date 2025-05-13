import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';

class SongInformationWidget extends StatelessWidget {
  const SongInformationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("Do-Re-Mi Song", style: AppTextStyles.heading4Bold),

        Text(
          "Sound of Music",
          style: AppTextStyles.body1.copyWith(color: AppColors.neutralGray),
        ),
      ],
    );
  }
}
