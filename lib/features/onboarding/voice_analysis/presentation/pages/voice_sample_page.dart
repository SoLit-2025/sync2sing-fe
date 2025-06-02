import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/shared/providers/audio_pitch_no_save_provider.dart';
import 'package:sync2sing/shared/providers/vocal_pitch_metrics_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/features/onboarding/voice_analysis/presentation/widgets/onboarding_page_indicator.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/shared/utils/mic_permission_helper.dart';
import '../../../../../config/theme/app_text_styles.dart';

class VoiceSamplePage extends ConsumerStatefulWidget {
  const VoiceSamplePage({super.key});

  @override
  ConsumerState createState() => _VoiceSamplePageState();
}

class _VoiceSamplePageState extends ConsumerState<VoiceSamplePage> {
  // 버튼 및 타이머 상태 변수
  bool isRecording = false;
  bool canFinish = false;
  int remainingSeconds = 5;
  Timer? finishEnableTimer;

  // 탐지된 음정 리스트
  final List<double> _pitches = [];
  double? _averagePitch;

  // 낭독할 문장
  final String sampleSentence = '물에 떠내려간\n초록색 입술들을 모아\n한 겹 아름다운\n귀를 만들고';

  @override
  void initState() {
    super.initState();

    // 마이크 권한 요청
    Future.microtask(() async {
      final granted = await ensureMicPermission(ref);
      if (!granted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("마이크 권한이 필요합니다")));
      }
    });
  }

  // '읽기 시작' 버튼 클릭 시 호출: 녹음 시작 및 5초 타이머 시작
  Future<void> onStartReading() async {
    setState(() {
      isRecording = true;
      canFinish = false;
      remainingSeconds = 5;
    });
    // 녹음 시작
    await ref.read(audioPitchNoSaveProvider.notifier).startOrResume();

    // 타이머: 5초 후 '읽기 종료' 버튼 활성화
    finishEnableTimer?.cancel();
    finishEnableTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        remainingSeconds--;
        if (remainingSeconds <= 0) {
          canFinish = true;
          finishEnableTimer?.cancel();
        }
      });
    });
  }

  // '읽기 종료' 버튼 클릭 시 호출: 녹음 종료 후 변환/분석/전송
  Future<void> onFinishReading() async {
    setState(() {
      isRecording = false;
    });
    await analyzeAndStoreAverageNote();
    ref.invalidate(audioPitchNoSaveProvider); // 사용하던 프로바이더 삭제
    navigateToMinimumPitchPage();
  }

  // 평균 노트명 분석 후 임시 저장: 서버로 보내는 작업은 평균음, 최저음, 최고음 모두 분석한 뒤에 일괄 처리
  Future<void> analyzeAndStoreAverageNote() async {
    if (_pitches.isNotEmpty) {
      final total = _pitches.reduce((a, b) => a + b);
      _averagePitch = total / _pitches.length;
      ref.read(pitchStatsProvider.notifier).setAveragePitch(_averagePitch!);
      // debugPrint('🎯 평균 음정 (dispose 시 계산): $_averagePitch Hz');
    }
  }

  // 다음 페이지로 이동
  void navigateToMinimumPitchPage() {
    context.go(AppRoutePaths.minimumPitch);
  }

  @override
  void dispose() {
    finishEnableTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 버튼 텍스트 및 활성화 상태 결정:
    String buttonText;
    bool isButtonEnabled;
    final _isRecording = ref.watch(audioPitchNoSaveProvider);
    final recorderController = ref.read(audioPitchNoSaveProvider.notifier);
    final pitchAsync = ref.watch(autoStartPitchStreamProvider);

    pitchAsync.when(
      data: (pitchData) {
        _pitches.add(pitchData.pitch);
        return const SizedBox();
      },
      loading: () => const CircularProgressIndicator(),
      error: (e, _) {
        log("flutter: pitchStream 에러: $e");
        return SizedBox();
      },
    );

    if (!isRecording) {
      buttonText = '읽기 시작';
      isButtonEnabled = true;
    } else {
      if (canFinish) {
        buttonText = '읽기 종료';
        isButtonEnabled = true;
      } else {
        buttonText = '읽기 종료 (${remainingSeconds}s)';
        isButtonEnabled = false;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.grayscale8,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 32.h),
              Center(child: OnboardingPageIndicator(currentPage: 1)),
              SizedBox(height: 40.h),
              Text('아래 문장을 읽어주세요', style: AppTextStyles.heading3Bold, textAlign: TextAlign.left),
              SizedBox(height: 12.h),
              Text('평소처럼 자연스럽게 읽어주시면\n목소리를 더 정확히 분석할 수 있어요', style: AppTextStyles.heading4, textAlign: TextAlign.left),
              SizedBox(height: 32.h),
              Center(
                child: Container(
                  width: 327.w,
                  height: 329.h,
                  decoration: BoxDecoration(color: const Color(0xFFECECEC), borderRadius: BorderRadius.circular(10.r)),
                  alignment: Alignment.center,
                  child: Text(
                    sampleSentence,
                    style: AppTextStyles.heading1Bold.copyWith(color: AppColors.grayscale3),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              SizedBox(height: 60.h),
              Center(
                child: CupertinoButton(
                  onPressed:
                      !isButtonEnabled
                          ? null
                          : () async {
                            if (!isRecording) {
                              await onStartReading();
                            } else if (canFinish) {
                              await onFinishReading();
                            }
                          },
                  padding: EdgeInsets.zero,
                  child: Container(
                    width: 327.w,
                    height: 50.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isButtonEnabled ? AppColors.primaryPink : const Color(0xFFF8D6DA),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      buttonText,
                      style:
                          isButtonEnabled
                              ? AppTextStyles.body1Bold.copyWith(color: AppColors.grayscale8)
                              : AppTextStyles.body1.copyWith(color: AppColors.grayscale8),
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
