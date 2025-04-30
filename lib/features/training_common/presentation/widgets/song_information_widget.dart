import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync2sing/config/theme/app_colors.dart';

class SongInformationWidget extends StatelessWidget {
  const SongInformationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Do-Re-Mi Song",
          style: TextStyle(
            fontSize: 20.w,
            color: AppColors.neutralBlack,
            fontVariations: <FontVariation>[FontVariation('wght', 600)],
            height: 1.4,
          ),
        ),

        Text(
          "Sound of Music",
          style: TextStyle(
            fontSize: 17.w,
            color: AppColors.neutralGray,
            fontVariations: <FontVariation>[FontVariation('wght', 400)],
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
