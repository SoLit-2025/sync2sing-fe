import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';

class SongInformationWidget extends StatelessWidget {
  final String title;
  final String artist;
  const SongInformationWidget({super.key, required this.title, required this.artist});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: AppTextStyles.heading4Bold),
        Text(
          artist,
          style: AppTextStyles.body1.copyWith(color: AppColors.grayscale3),
          softWrap: false, // 여러 줄 x, 한 줄로 제한
          overflow: TextOverflow.ellipsis, // 텍스트가 너비 초과하면 ... 로 표시
          maxLines: 1,
        ),
      ],
    );
  }
}
