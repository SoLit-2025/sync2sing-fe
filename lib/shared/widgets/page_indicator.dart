import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync2sing/config/theme/app_colors.dart';

class PageIndicator extends StatelessWidget {
  // 페이지네이션 (화면 상단 페이지 위치 동그라미) 위젯
  final double currentPage;
  final int pageCount;

  const PageIndicator({
    super.key,
    required this.currentPage,
    required this.pageCount,
  });

  @override
  Widget build(BuildContext context) {
    return DotsIndicator(
      dotsCount: pageCount,
      position: currentPage,

      decorator: DotsDecorator(
        color: AppColors.grayscale5,
        activeColor: AppColors.grayscale3,
        size: Size.square(10.r),
        activeSize: Size.square(10.r),
        spacing: EdgeInsets.symmetric(horizontal: 5.r),
      ),
    );
  }
}
