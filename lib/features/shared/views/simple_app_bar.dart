import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';

class SimpleAppBar extends StatelessWidget {
  final String? text;
  const SimpleAppBar({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56.h,
      child: Row(
        children: [
          SizedBox(width: 18.w),
          GestureDetector(
            onTap: () => context.pop(),
            child: Image.asset(
              'assets/images/left_arrow_icon.png',
              width: 14.w,
              height: 24.h,
              fit: BoxFit.contain,
            ),
          ),
          Expanded(
            child: Text(
              text ?? '',
              style: AppTextStyles.heading4Bold.copyWith(color: AppColors.grayscale1),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 14.w),
        ],
      ),
    );
  }
}
