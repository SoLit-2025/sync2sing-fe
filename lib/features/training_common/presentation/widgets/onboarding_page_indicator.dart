import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync2sing/config/theme/app_colors.dart';

class OnboardingPageIndicator extends StatelessWidget {
  // 페이지네이션 (화면 상단 페이지 위치 동그라미) 위젯
  final double currentPage;
  static const int _pageCount = 6;
  const OnboardingPageIndicator({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return DotsIndicator(
      dotsCount: _pageCount,
      position: currentPage,

      decorator: DotsDecorator(
        color: AppColors.neutralLightGray, // Inactive color
        activeColor: AppColors.neutralGray,
        size: Size.square(10.w),
        activeSize: Size.square(10.w),
        spacing: EdgeInsets.symmetric(horizontal: 5.w),
      ),
    );
  }
}
