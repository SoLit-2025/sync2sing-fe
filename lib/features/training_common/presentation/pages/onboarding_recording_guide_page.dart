import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';
import 'package:sync2sing/features/training_common/presentation/widgets/youtube_player_widget.dart';
import 'package:sync2sing/shared/providers/watch_youtube_providers.dart';
import 'package:sync2sing/shared/widgets/page_indicator.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/routes/route_names.dart';

class OnboardingRecordingGuidePage extends ConsumerWidget {
  const OnboardingRecordingGuidePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool _isButtonEnabled = ref.watch(
      isOnboardingRecordingStartButtonEnabledProvider,
    );

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
                  PageIndicator(currentPage: 4, pageCount: 6), // 상단 페이지네이션 위젯
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 30.h, 0, 20.h),
                    width: 327.w,
                    alignment: Alignment(-1.0, -1.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          // 텍스트 필드 (글씨 안내)
                          padding: EdgeInsets.symmetric(vertical: 5.h),
                          child: Text(
                            "마지막 과정이에요",
                            textAlign: TextAlign.left,
                            style: AppTextStyles.heading3Bold,
                          ),
                        ),

                        Text(
                          "아래 음원을 듣고 \n후렴구를 똑같이 따라 불러주세요",
                          textAlign: TextAlign.left,
                          style: AppTextStyles.heading4,
                        ),
                      ],
                    ),
                  ),
                  // 유튜브 영상
                  Container(
                    width: 327.w,
                    margin: EdgeInsets.symmetric(vertical: 20.w),
                    child: YoutubePlayerWidget(
                      videoId: 'Qy9cj-zwbVY', // 도레미송 공식 가사 비디오
                      // do a deer 부분에서 영상 시작, 자동 재생 금지
                      flags: YoutubePlayerFlags(autoPlay: false, startAt: 42),
                    ),
                  ),
                  // 시작하기 버튼
                  Container(
                    width: double.infinity,
                    height: 50.w,
                    margin: EdgeInsets.fromLTRB(0, 30.h, 0, 30.h),
                    alignment: Alignment(0.0, 0.0),
                    child: CupertinoButton(
                      color: AppColors.primaryPink,
                      disabledColor: Color(0xFFF8D6DA), // 비활성화 색
                      borderRadius: BorderRadius.circular(10.r),
                      minSize: 0.0,
                      padding: EdgeInsets.all(0),
                      // 버튼 활성화 조건을 만족하면 onboardingRecordingSong 페이지로 이동 / 아니면 비활성화 상태
                      onPressed:
                          _isButtonEnabled
                              ? () {
                                context.goNamed(
                                  AppRouteNames.onboardingRecordingSong,
                                );
                              }
                              : null,
                      child: Center(
                        child: Text(
                          "시작하기",
                          style:
                              _isButtonEnabled
                                  ? AppTextStyles.body1BoldWhite
                                  : AppTextStyles.body1White,
                        ),
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
