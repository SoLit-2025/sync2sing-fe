import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/features/onboarding/voice_analysis/presentation/widgets/onboarding_page_indicator.dart';
import 'package:go_router/go_router.dart';

class VoiceSamplePage extends StatefulWidget {
  const VoiceSamplePage({super.key});

  @override
  State<VoiceSamplePage> createState() => _VoiceSamplePageState();
}

class _VoiceSamplePageState extends State<VoiceSamplePage> {
  // 실제 구현에서는 음성 인식으로 읽기 완료 상태를 판단할 예정
  // 여기서는 임시로 버튼을 항상 활성화로 두고, 실제 구현시 읽기 완료 로직으로 변경
  bool _isSentenceRead = true;

  bool get _isButtonActive => _isSentenceRead;

  final String sampleSentence = '물에 떠내려간\n초록색 입술들을 모아\n한 겹 아름다운\n귀를 만들고';

  void _onReadSentence() {
    setState(() {
      _isSentenceRead = true;
    });
  }

  void _navigateToMinimumPitchPage() {
    if (_isButtonActive) {
      context.go('/onboarding/min_pitch');
    }
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  SizedBox(height: 32.h),
                  Center(child: OnboardingPageIndicator(currentPage: 1)),
                  SizedBox(height: 16.h),
                ],
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '아래 문장을 읽어주세요',
                      style: TextStyle(
                        color: AppColors.grayscale1,
                        fontSize: 22.sp,
                        fontFamily: 'Pretendard Variable',
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                        decoration: TextDecoration.none,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      '평소처럼 자연스럽게 읽어주시면\n목소리를 더 정확히 분석할 수 있어요',
                      style: TextStyle(
                        color: AppColors.grayscale1,
                        fontSize: 20.sp,
                        fontFamily: 'Pretendard Variable',
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                        decoration: TextDecoration.none,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 32.h),
                    Center(
                      child: Container(
                        width: 327.w,
                        height: 329.h,
                        decoration: BoxDecoration(
                          color: AppColors.grayscale6,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          sampleSentence,
                          style: TextStyle(
                            color: AppColors.grayscale3,
                            fontSize: 34.sp,
                            fontFamily: 'Pretendard Variable',
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                            decoration: TextDecoration.none,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 50.h),
                child: Center(
                  child: CupertinoButton(
                    onPressed:
                        _isButtonActive ? _navigateToMinimumPitchPage : null,
                    padding: EdgeInsets.zero,
                    child: Container(
                      width: 327.w,
                      height: 50.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color:
                            _isButtonActive
                                ? AppColors.primaryPink
                                : AppColors.primaryPinkDisabled,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        '확인',
                        style: TextStyle(
                          color: AppColors.grayscale8,
                          fontSize: 17.sp,
                          fontFamily: 'Pretendard Variable',
                          fontWeight:
                              _isButtonActive
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                          height: 1.4,
                          decoration: TextDecoration.none,
                        ),
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
