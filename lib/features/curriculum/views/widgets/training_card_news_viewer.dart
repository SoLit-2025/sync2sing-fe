import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/features/shared/views/page_indicator.dart';

class TrainingCardNewsViewer extends StatelessWidget {
  final List<String> imagePaths;
  final int currentIndex;

  const TrainingCardNewsViewer({
    Key? key,
    required this.imagePaths,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 기존 PageIndicator 위젯 사용
            PageIndicator(
              currentPage: currentIndex.toDouble(),
              pageCount: imagePaths.length,
            ),
            SizedBox(height: 24.h),
            // 카드뉴스 이미지
            Container(
              width: 327.w,
              height: 600.h,
              decoration: BoxDecoration(
                color: AppColors.grayscale8,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.asset(
                  imagePaths[currentIndex],
                  width: 327.w,
                  height: 600.h,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint(' 이미지 로딩 실패: ${imagePaths[currentIndex]}');
                    debugPrint('에러: $error');
                    return Container(
                      color: AppColors.grayscale6,
                      child: Center(
                        child: Icon(
                          Icons.image,
                          size: 64.r,
                          color: AppColors.grayscale4,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
