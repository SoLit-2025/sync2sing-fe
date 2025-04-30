import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/features/training_common/presentation/widgets/onboarding_page_indicator.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/features/training_common/presentation/widgets/youtube_player_widget.dart';

class OnboardingRecordingGuidePage extends StatelessWidget {
  const OnboardingRecordingGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(390, 844));

    return Scaffold(
      resizeToAvoidBottomInset: false,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            alignment: Alignment(0.0, -1.0),
            margin: EdgeInsets.symmetric(vertical: 10.h),
            child: SizedBox(
              width: 327.w,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  OnboardingPageIndicator(currentPage: 4),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 30.h, 0, 20.h),
                    width: 327.w,
                    alignment: Alignment(-1.0, -1.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 5.h),
                          child: Text(
                            "마지막 과정이에요",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 22.w,
                              color: AppColors.neutralBlack,
                              fontVariations: <FontVariation>[
                                FontVariation('wght', 600),
                              ],
                              height: 1.4,
                            ),
                          ),
                        ),

                        Text(
                          "아래 음원을 듣고 \n후렴구를 똑같이 따라 불러주세요",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 20.w,
                            color: AppColors.neutralBlack,
                            fontVariations: <FontVariation>[
                              FontVariation('wght', 400),
                            ],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 329.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      color: AppColors.neutralGhost,
                    ),
                    child: Center(child: YoutubePlayerWidget()),
                  ),
                  Container(
                    width: double.infinity,
                    height: 50.w,
                    margin: EdgeInsets.fromLTRB(0, 30.h, 0, 10.h),
                    child: Center(
                      child: CupertinoButton(
                        color: AppColors.primaryPink,
                        disabledColor: Color(0xFFF8D6DA),
                        minSize: 0.0,
                        padding: EdgeInsets.all(0),
                        child: Center(
                          child: Text(
                            "시작하기",
                            style: TextStyle(
                              fontSize: 17.w,
                              color: AppColors.neutralWhite,
                              fontVariations: <FontVariation>[
                                FontVariation('wght', 600),
                              ],
                              // height: 1.4,
                            ),
                          ),
                        ),
                        onPressed: () {
                          context.pushNamed(
                            AppRouteNames.onboardingRecordingSong,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
