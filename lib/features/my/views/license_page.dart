import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';

class LicensePage extends StatelessWidget {
  const LicensePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grayscale8,
      appBar: AppBar(
        backgroundColor: AppColors.grayscale8,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Image.asset(
            'assets/images/left_arrow_icon.png',
            width: 14.w,
            height: 24.h,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.arrow_back, color: AppColors.grayscale2),
          ),
        ),
        title: Text(
            '라이센스 정보',
            style: AppTextStyles.heading4Bold.copyWith(color: AppColors.grayscale1)
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            Text(
              'flutter_sound',
              style: AppTextStyles.heading4Bold.copyWith(color: AppColors.grayscale1),
            ),
            SizedBox(height: 8.h),
            Text(
              'License: Mozilla Public License, Version 2.0 (MPL 2.0)',
              style: AppTextStyles.body3.copyWith(color: AppColors.grayscale2),
            ),
            SizedBox(height: 4.h),
            Text(
              'Copyright © 2025 Canardoux',
              style: AppTextStyles.body3.copyWith(color: AppColors.grayscale2),
            ),
            SizedBox(height: 12.h),
            Text(
              '원본 소스: https://github.com/canardoux/flutter_sound\n\n'
                  '본 앱에서는 이 소스를 수정하지 않고 사용했습니다.\n\n'
                  'MPL 2.0 전문: https://mozilla.org/MPL/2.0/',
              style: AppTextStyles.body4.copyWith(color: AppColors.grayscale2, height: 1.5),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}
