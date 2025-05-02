import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    ScreenUtil.init(context, designSize: const Size(390, 844));
    return Scaffold(
      resizeToAvoidBottomInset: false,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 10.h),
            alignment: Alignment(0.0, -1.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                PageIndicator(currentPage: 5, pageCount: 6), // 페이지네이션
                // 음악 플레이어 컨테이너
                Container(
                  width: 327.w,
                  margin: EdgeInsets.only(top: 30.h),
                  padding: EdgeInsets.fromLTRB(0, 15.h, 0, 20.h),
                  alignment: Alignment(0.0, 0.0), // 위젯을 중앙에 배치
                  constraints: BoxConstraints(minHeight: 557.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadiusDirectional.circular(10.r),
                    color: Color(0xFFECECEC),
                  ),
                  child: SizedBox(width: 295.w, child: MusicContentPlayer()),
                ),
                // 보컬 분석 리포트 생성 버튼
                Container(
                  margin: EdgeInsets.fromLTRB(0, 40.h, 0, 10.h),
                  width: 327.w,
                  height: 50.w,
                  child: Consumer(
                    builder: (context, ref, child) {
                      return CupertinoButton(
                        color: AppColors.primaryPink,
                        disabledColor: Color(0xFFF8D6DA),
                        borderRadius: BorderRadius.circular(10.w),
                        onPressed:
                            (isVocalAnalysisButtonEnabled())
                                ? () {
                                  ref.refresh(vocalAnalysisSubmitProvider);
                                  context.goNamed(
                                    AppRouteNames.analysisLoading,
                                  );
                                }
                                : null, // 조건을 만족하지 않으면 버튼 비활성화
                        child: Text(
                          "보컬 분석 리포트 생성하기",
                          style: TextStyle(
                            color: AppColors.neutralWhite,
                            fontSize: 17.sp,
                            fontVariations: <FontVariation>[
                              FontVariation(
                                'wght',
                                (isVocalAnalysisButtonEnabled()) ? 600 : 400,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
