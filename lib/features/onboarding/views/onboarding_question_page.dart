import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/config/theme/app_colors.dart';

class OnboardingQuestionPage extends StatelessWidget {
  const OnboardingQuestionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        final screenHeight = MediaQuery.of(context).size.height;

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.18),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/sync2sing_logo_v1.png',
                        width: 100.w,
                        height: 100.h,
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        'Sync2Sing이 처음이신가요?',
                        style: TextStyle(
                          color: AppColors.grayscale1,
                          fontSize: 20.sp,
                          fontFamily: 'Pretendard Variable',
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const Expanded(child: SizedBox()),
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 버튼 A (네, 처음이에요)
                        SizedBox(
                          width: 327.w,
                          height: 50.h,
                          child: ElevatedButton(
                            onPressed: () {
                              // todo: 회원가입 페이지로 이동
                              context.goNamed(AppRouteNames.audioEnvironment);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.grayscale6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              '네, 처음이에요',
                              style: TextStyle(
                                color: AppColors.grayscale1,
                                fontSize: 17.sp,
                                fontFamily: 'Pretendard Variable',
                                fontWeight: FontWeight.w400,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        // 버튼 B (아뇨, 계정이 있어요)
                        SizedBox(
                          width: 327.w,
                          height: 50.h,
                          child: ElevatedButton(
                            onPressed: () {
                              // todo: 로그인 페이지로 이동
                              context.goNamed(AppRouteNames.login);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.grayscale6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              '아뇨, 계정이 있어요',
                              style: TextStyle(
                                color: AppColors.grayscale1,
                                fontSize: 17.sp,
                                fontFamily: 'Pretendard Variable',
                                fontWeight: FontWeight.w400,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.19),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
