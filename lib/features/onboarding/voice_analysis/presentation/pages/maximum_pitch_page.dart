import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/features/onboarding/voice_analysis/presentation/widgets/onboarding_page_indicator.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/routes/route_names.dart';

class MaximumPitchPage extends StatefulWidget {
  const MaximumPitchPage({super.key});

  @override
  State<MaximumPitchPage> createState() => _MaximumPitchPageState();
}

class _MaximumPitchPageState extends State<MaximumPitchPage> {
  bool _isVoiceDetected = true;
  bool get _isMicOn => _isVoiceDetected;
  bool get _isButtonActive => _isVoiceDetected;

  static const _notes = ['C2', 'C3', 'C4', 'C5', 'C6', 'C7'];

  void _navigateToOnboardingRecordingGuidePage() {
    if (_isButtonActive) {
      context.go(AppRoutePaths.onboardingRecordingGuide);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double stackSize = 340.w;
    final double donutSize = 230.w;
    final double innerDonutSize = 175.w;
    final double noteRadius = donutSize / 2 + 30.w;
    final double center = stackSize / 2;

    final double donutRadius = donutSize / 2;
    final double indicatorRadius = 10.w;

    final double startAngle = pi;
    final double indicatorAngle = startAngle; // C2 위치
    final double endAngle = 2 * pi;
    final double sweepAngle = endAngle - startAngle;
    final int noteCount = _notes.length;

    return CupertinoPageScaffold(
      backgroundColor: AppColors.neutralWhite,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 32.h),
              Center(child: OnboardingPageIndicator(currentPage: 3)), // 4번째 페이지
              SizedBox(height: 60.h),
              Center(
                child: SizedBox(
                  width: stackSize,
                  height: stackSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 도넛 외부 원
                      Container(
                        width: donutSize,
                        height: donutSize,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          shape: BoxShape.circle,
                        ),
                      ),
                      // 도넛 내부 원
                      Container(
                        width: innerDonutSize,
                        height: innerDonutSize,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF),
                          shape: BoxShape.circle,
                        ),
                      ),
                      // 계이름
                      ...List.generate(noteCount, (i) {
                        final angle =
                            startAngle + (sweepAngle / (noteCount - 1)) * i;
                        final x = center + noteRadius * cos(angle) - 15.w;
                        final y = center + noteRadius * sin(angle) - 15.h;
                        return Positioned(
                          left: x,
                          top: y,
                          child: SizedBox(
                            width: 30.w,
                            height: 30.h,
                            child: Center(
                              child: Text(
                                _notes[i],
                                style: TextStyle(
                                  color: const Color(0xFFC0C0C0),
                                  fontSize: 17.sp,
                                  fontFamily: 'Pretendard Variable',
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                      // 음정 감지 동그라미 (C2 위치, 도넛 위에 배치)
                      Positioned(
                        left:
                            center +
                            (donutRadius * 0.95) * cos(indicatorAngle) -
                            indicatorRadius,
                        top:
                            center +
                            (donutRadius * 0.95) * sin(indicatorAngle) -
                            indicatorRadius,
                        child: Container(
                          width: 20.w,
                          height: 20.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD9D9D9),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      // 마이크 아이콘
                      Center(
                        child: Image.asset(
                          _isMicOn
                              ? 'assets/images/mic-on.png'
                              : 'assets/images/mic-off.png',
                          width: 84.w,
                          height: 84.w,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                '낼 수 있는 가장 높은 음을\n3초 이상 유지해주세요',
                style: TextStyle(
                  color: AppColors.neutralBlack,
                  fontSize: 20.sp,
                  fontFamily: 'Pretendard Variable',
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 60.h),
              Center(
                child: CupertinoButton(
                  onPressed:
                      _isButtonActive
                          ? _navigateToOnboardingRecordingGuidePage
                          : null,
                  padding: EdgeInsets.zero,
                  child: Container(
                    width: 327.w,
                    height: 50.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color:
                          _isButtonActive
                              ? AppColors.primaryPink
                              : const Color(0xFFF8D6DA),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      '확인',
                      style: TextStyle(
                        color: AppColors.neutralWhite,
                        fontSize: 17.sp,
                        fontFamily: 'Pretendard Variable',
                        fontWeight:
                            _isButtonActive ? FontWeight.w600 : FontWeight.w400,
                        height: 1.4,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 50.h),
            ],
          ),
        ),
      ),
    );
  }
}
