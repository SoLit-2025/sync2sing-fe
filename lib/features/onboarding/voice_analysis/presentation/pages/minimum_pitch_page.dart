import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/features/onboarding/voice_analysis/presentation/widgets/onboarding_page_indicator.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';
import 'package:sync2sing/shared/providers/audio_pitch_no_save_provider.dart';
import 'package:sync2sing/shared/providers/vocal_pitch_metrics_provider.dart';

import '../../../../../shared/utils/mic_permission_helper.dart';

class MinimumPitchPage extends ConsumerStatefulWidget {
  const MinimumPitchPage({super.key});

  @override
  ConsumerState<MinimumPitchPage> createState() => _MinimumPitchPageState();
}

class _MinimumPitchPageState extends ConsumerState<MinimumPitchPage> {
  bool _isVoiceDetected = false;
  // '시작' 버튼 클릭 여부 -> 페이지에 처음 들어왔을 땐 무조건'시작' 버튼을 클릭할 수 있어야 함
  bool _isRecordingStarted = false;
  bool get _isMicOn => _isVoiceDetected;
  // 시작 버튼 클릭 x or 클릭 후 피치가 감지됨
  bool get _isButtonActive => !_isRecordingStarted || _isVoiceDetected;
  double? _minPitch;

  static const List<String> _notes = ['C2', 'C3', 'C4', 'C5', 'C6', 'C7'];

  Future<void> _startPitchDetect() async {
    await ref.read(audioPitchNoSaveProvider.notifier).startOrResume();
    setState(() {
      _isRecordingStarted = true;
    });
  }

  Future<void> _navigateToMaximumPitchPage() async {
    if (_isButtonActive) {
      if (_minPitch == null) {
        debugPrint("피치가 감지되지 않았습니다");
        return;
      }
      await analyzeAndStorePitchNote();
      ref.invalidate(audioPitchNoSaveProvider); // 프로바이더 삭제

      context.go(AppRoutePaths.maximumPitch);
    }
  }

  Future<void> analyzeAndStorePitchNote() async {
    // 최저 음정값 저장
    ref.read(vocalPitchMetricsProvider.notifier).setMinPitch(_minPitch!);
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final granted = await ensureMicPermission(ref); // 공통 함수 재사용

      if (!granted) {
        // 권한이 없으면 안내하고 return
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("마이크 권한이 필요합니다")));
      }
    });
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

    // 실시간 음정 탐지 관련 코드 (저장 x) / 진입과 동시에 녹음 시작.
    final isRecording = ref.watch(audioPitchNoSaveProvider);
    ref
        .watch(autoStartPitchStreamProvider)
        .when(
          data: (pitchData) {
            // 여기에서 pitchData.pitch 를 사용해서 화면 또는 로직 처리

            // pitched == false 일 때 가짜 데이터 수신: pitch=0, probability=0
            if (pitchData.pitch > 30) {
              _isVoiceDetected = true;
              if (_minPitch == null || pitchData.pitch < _minPitch!) {
                // 최저 음정 로컬 변수에 저장
                debugPrint("음정 탐지: minPitch ${pitchData.pitch}");
                setState(() => _minPitch = pitchData.pitch);
              }
              return SizedBox();
            }
          },
          loading: () => CircularProgressIndicator(),
          error: (e, _) => Text('Error: $e'),
        );

    return CupertinoPageScaffold(
      backgroundColor: AppColors.grayscale8,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 32.h),
              Center(child: OnboardingPageIndicator(currentPage: 2)),
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
                          color: AppColors.grayscale7,
                          shape: BoxShape.circle,
                        ),
                      ),
                      // 도넛 내부 원
                      Container(
                        width: innerDonutSize,
                        height: innerDonutSize,
                        decoration: BoxDecoration(
                          color: AppColors.grayscale8,
                          shape: BoxShape.circle,
                        ),
                      ),
                      // 계이름
                      ...List.generate(noteCount, (i) {
                        final angle = startAngle + (sweepAngle / (noteCount - 1)) * i;
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
                                  color: AppColors.grayscale4,
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
                        left: center + (donutRadius * 0.95) * cos(indicatorAngle) - indicatorRadius,
                        top: center + (donutRadius * 0.95) * sin(indicatorAngle) - indicatorRadius,
                        child: Container(
                          width: 20.w,
                          height: 20.w,
                          decoration: BoxDecoration(
                            color: AppColors.grayscale5,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      // 마이크 아이콘
                      Center(
                        child: Image.asset(
                          _isMicOn ? 'assets/images/mic-on.png' : 'assets/images/mic-off.png',
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
                '낼 수 있는 가장 낮은 음을\n3초 이상 유지해주세요',
                style: AppTextStyles.heading4.copyWith(
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 60.h),
              Center(
                child: CupertinoButton(
                  onPressed: isRecording ? _navigateToMaximumPitchPage : _startPitchDetect,
                  padding: EdgeInsets.zero,
                  child: Container(
                    width: 327.w,
                    height: 50.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color:
                          _isButtonActive ? AppColors.primaryPink : AppColors.primaryPinkDisabled,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      isRecording ? '확인' : '시작',
                      style: TextStyle(
                        color: AppColors.grayscale8,
                        fontSize: 17.sp,
                        fontFamily: 'Pretendard Variable',
                        fontWeight: _isButtonActive ? FontWeight.w600 : FontWeight.w400,
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
