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

  // 예시: 버튼 활성화 조건(실제 구현시 음성 인식 결과에 따라 변경)
  bool get _isButtonActive => _isSentenceRead;

  // 예시: 문장 텍스트
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
      backgroundColor: AppColors.neutralWhite,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 32.h),
              // 페이지네이션 - 2번째 페이지
              Center(child: OnboardingPageIndicator(currentPage: 1)),
              SizedBox(height: 40.h),
              // 메인 텍스트
              Text(
                '아래 문장을 읽어주세요',
                style: TextStyle(
                  color: AppColors.neutralBlack,
                  fontSize: 22.sp,
                  fontFamily: 'Pretendard Variable',
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 12.h),
              // 서브 텍스트
              Text(
                '평소처럼 자연스럽게 읽어주시면\n목소리를 더 정확히 분석할 수 있어요',
                style: TextStyle(
                  color: AppColors.neutralBlack,
                  fontSize: 20.sp,
                  fontFamily: 'Pretendard Variable',
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 32.h),
              // 문장 컨테이너
              Center(
                child: Container(
                  width: 327.w,
                  height: 329.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFECECEC),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    sampleSentence,
                    style: TextStyle(
                      color: AppColors.neutralGray,
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
              SizedBox(height: 60.h),

              // 확인 버튼
              Center(
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
                              : const Color(0xFFF8D6DA),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      '확인',
                      style: TextStyle(
                        color:
                            _isButtonActive
                                ? AppColors.neutralWhite
                                : AppColors.neutralWhite,
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
