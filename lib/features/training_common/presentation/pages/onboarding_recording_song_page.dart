import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';
import 'package:sync2sing/features/training_common/presentation/widgets/music_content_player.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/shared/providers/vocal_analysis_submit_provider.dart';
import 'package:sync2sing/shared/widgets/page_indicator.dart';

class OnboardingRecordingSongPage extends StatelessWidget {
  const OnboardingRecordingSongPage({super.key});

  bool isVocalAnalysisButtonEnabled() {
    // 보컬 분석 버튼 활성화 조건
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          width: double.infinity, // 수평 중앙 정렬
          padding: EdgeInsets.fromLTRB(0, 12.h, 0, 40.h), // 상하 여백
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 상단 페이지 인디케이터
              const PageIndicator(currentPage: 5, pageCount: 6),

              Spacer(), // 위와 중간 사이 간격
              // 중간 콘텐츠 영역
              Container(
                width: 327.w,
                padding: EdgeInsets.fromLTRB(16.h, 16.h, 16.h, 20.h),
                constraints: BoxConstraints(minHeight: 300.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: const Color(0xFFECECEC),
                ),
                child: MusicContentPlayer(),
              ),

              Spacer(), // 중간과 버튼 사이 간격
              // 하단 버튼
              Container(
                // margin: EdgeInsets.only(bottom: 10.h),
                width: 327.w,
                height: 50.w,
                child: Consumer(
                  builder: (context, ref, child) {
                    return CupertinoButton(
                      color: AppColors.primaryPink,
                      disabledColor: AppColors.primaryPinkDisabled,
                      borderRadius: BorderRadius.circular(10.w),
                      onPressed:
                          isVocalAnalysisButtonEnabled()
                              ? () {
                                ref.refresh(vocalAnalysisSubmitProvider);
                                context.pushNamed(
                                  AppRouteNames.analysisLoading,
                                );
                              }
                              : null,
                      child: Text(
                        "보컬 분석 리포트 생성하기",
                        style:
                            isVocalAnalysisButtonEnabled()
                                ? AppTextStyles.body1BoldWhite
                                : AppTextStyles.body1White,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
