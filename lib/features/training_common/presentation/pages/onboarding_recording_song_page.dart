import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/features/training_common/presentation/widgets/onboarding_page_indicator.dart';
import 'package:sync2sing/features/training_common/presentation/widgets/music_content_player.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/shared/providers/vocal_analysis_submit_provider.dart';

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
            margin: EdgeInsets.symmetric(vertical: 10.w),
            alignment: Alignment(0.0, -1.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                OnboardingPageIndicator(currentPage: 5), // 페이지네이션
                // 음악 플레이어 컨테이너
                Container(
                  width: 327.w,
                  margin: EdgeInsets.only(top: 30.w),
                  padding: EdgeInsets.symmetric(vertical: 10.w),
                  alignment: Alignment(0.0, 0.0), // 위젯을 중앙에 배치
                  constraints: BoxConstraints(minHeight: 557.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadiusDirectional.circular(10.w),
                    color: Color(0xFFECECEC),
                  ),
                  child: SizedBox(width: 295.w, child: MusicContentPlayer()),
                ),

                // 보컬 분석 리포트 생성 버튼
                Container(
                  margin: EdgeInsets.fromLTRB(0, 30.w, 0, 10.w),
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
                          "보컬 분석 시작하기",
                          style: TextStyle(
                            color: AppColors.neutralWhite,
                            fontSize: 17.w,
                            fontVariations: <FontVariation>[
                              FontVariation('wght', 600),
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

class DisabledButton extends StatelessWidget {
  final String textContent;
  const DisabledButton({super.key, required this.textContent});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.w),
      width: 327.w,
      height: 50.w,
      child: CupertinoButton(
        disabledColor: Color(0xFFF8D6DA),
        borderRadius: BorderRadius.circular(10.w),
        onPressed: null,
        child: Text(
          textContent,
          style: TextStyle(
            color: AppColors.neutralWhite,
            fontSize: 17.w,
            fontVariations: <FontVariation>[FontVariation('wght', 400)],
          ),
        ),
      ),
    );
  }

  bool enableCondition(bool boolean) {
    return boolean;
  }
}
