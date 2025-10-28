import 'package:flutter/material.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class TrainingIntroCard extends StatelessWidget {
  final String iconPath;
  final String title;
  final String subtitle;
  final VoidCallback onStart;

  const TrainingIntroCard({
    Key? key,
    required this.iconPath,
    required this.title,
    required this.subtitle,
    required this.onStart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            // 뒤로가기 버튼
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
            ),
            const Spacer(),
            // 아이콘
            Center(
              child: Image.asset(
                  iconPath,
                  width: 100.w,
                  height: 100.h,
              ),
            ),
            SizedBox(height: 40.h),
            // 제목
            Center(
              child: Text(
                title,
                style: AppTextStyles.heading2Bold,
              ),
            ),
            SizedBox(height: 16.h),
            // 부제목
            Center(
              child: Text(
                subtitle,
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.grayscale2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
            // 시작하기 버튼
            Center(
              child: SizedBox(
                width: 327.w,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: onStart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    '시작하기',
                    style: AppTextStyles.body1BoldWhite,
                  ),
                ),
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
