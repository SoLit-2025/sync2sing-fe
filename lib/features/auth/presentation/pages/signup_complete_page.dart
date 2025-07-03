import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';
import 'package:sync2sing/config/theme/app_colors.dart';

class SignupCompletePage extends StatelessWidget {
  const SignupCompletePage({super.key});

  void _goToLogin(BuildContext context) {
    context.go(AppRoutePaths.login);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.grayscale8,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 상단: 로고, 메인/서브 텍스트
              Column(
                children: [
                  SizedBox(height: 120.h),
                  Center(
                    child: Image.asset(
                      'assets/images/sync2sing_logo_v1.png',
                      width: 85.w,
                      height: 85.w,
                    ),
                  ),
                  SizedBox(height: 40.h),
                  Text(
                    '회원가입 완료',
                    style: AppTextStyles.heading2Bold.copyWith(
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    '지금부터 보컬 분석 리포트를\n저장할 수 있어요.\n맞춤형 보컬 트레이닝을 시작해보세요',
                    style: AppTextStyles.body1.copyWith(
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              // 하단: 로그인 버튼 (CupertinoTheme으로 감싸서 색상 지정)
              Padding(
                padding: EdgeInsets.only(bottom: 48.h),
                child: SizedBox(
                  width: 327.w,
                  height: 50.h,
                  child: CupertinoTheme(
                    data: CupertinoTheme.of(
                      context,
                    ).copyWith(primaryColor: AppColors.primaryPink),
                    child: CupertinoButton.filled(
                      borderRadius: BorderRadius.circular(10.r),
                      padding: EdgeInsets.zero,
                      onPressed: () => _goToLogin(context),
                      child: Text(
                        '로그인 하러 가기',
                        style: AppTextStyles.body1White,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
