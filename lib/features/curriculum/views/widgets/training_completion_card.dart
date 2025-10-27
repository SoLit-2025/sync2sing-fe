import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';
import 'package:sync2sing/features/shared/logics/dio_factory.dart';
import 'package:sync2sing/features/shared/logics/secure_storage.dart';

import 'package:sync2sing/config/routes/route_names.dart';


class TrainingCompletionCard extends StatelessWidget {
  final String iconPath;
  final String title;
  final String subtitle;
  final VoidCallback onConfirm;
  final int sessionId;
  final int trainingId;

  const TrainingCompletionCard({
    Key? key,
    required this.iconPath,
    required this.title,
    required this.subtitle,
    required this.onConfirm,
    required this.sessionId,
    required this.trainingId,
  }) : super(key: key);

  Future<void> _updateProgress() async {
    try {
      final dioFactory = DioFactory(SecureStorage());
      final response = await dioFactory.put(
        '/training/sessions/$sessionId/trainings/$trainingId/progress',
        data: {'progress': 100},
      );
      debugPrint(' 진행률 업데이트 성공: ${response.data}');
    } catch (e) {
      debugPrint(' 진행률 업데이트 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          children: [
            const Spacer(),
            // 완료 아이콘
            Center(
              child: Image.asset(
                iconPath,
                width: 100.w,
                height: 100.w,
              ),
            ),
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
            // 확인 버튼
            Center(
              child: SizedBox(
                width: 327.w,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () async {
                    await _updateProgress();  //  진행률 업데이트
                    if (context.mounted) {
                      context.go(AppRoutePaths.soloTrainingHome);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    '확인',
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
