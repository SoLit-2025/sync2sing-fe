import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/features/onboarding/voice_analysis/presentation/widgets/onboarding_page_indicator.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/features/training_common/data/services/pitch_to_note_converter.dart';
import 'package:sync2sing/shared/providers/audio_pitch_no_save_provider.dart';
import 'package:sync2sing/shared/providers/vocal_pitch_metrics_provider.dart';
import 'package:sync2sing/shared/providers/voice_type_profile_provider.dart';

import '../../../../../shared/utils/mic_permission_helper.dart';
import '../../data/service/determine_voice_type.dart';

class MaximumPitchPage extends ConsumerStatefulWidget {
  const MaximumPitchPage({super.key});

  @override
  ConsumerState<MaximumPitchPage> createState() => _MaximumPitchPageState();
}

class _MaximumPitchPageState extends ConsumerState<MaximumPitchPage> {
  bool _isVoiceDetected = false;
  bool _isRecordingStarted = false; // '시작' 버튼을 눌러서 음성 녹음을 시작했는지 여부
  bool get _isMicOn => _isVoiceDetected;
  // 버튼 활성화 조건: '시작' 버튼 클릭 전 or '시작' 클릭 후 음정이 탐지된 이후
  bool get _isButtonActive => !_isRecordingStarted || _isVoiceDetected;
  double? _maxPitch;

  static const _notes = ['C2', 'C3', 'C4', 'C5', 'C6', 'C7'];

  Future<void> _startPitchDetect() async {
    await ref.read(audioPitchNoSaveProvider.notifier).startOrResume();
    setState(() {
      _isRecordingStarted = true;
    });
  }

  void _navigateToOnboardingRecordingGuidePage() async {
    if (_isButtonActive) {
      if (_maxPitch == null) {
        debugPrint("피치가 감지되지 않았습니다");
        return;
      }

      analyzeAndStorePitchNote();
      ref.invalidate(audioPitchNoSaveProvider); // 음성 녹음 관련 프로바이더 삭제: soundRecorder를 아예 삭제하기 위함
      context.go(AppRoutePaths.onboardingRecordingGuide);
    }
  }

  Future<void> analyzeAndStorePitchNote() async {
    // 최고음정 저장
    ref.read(vocalPitchMetricsProvider.notifier).setMaxPitch(_maxPitch!);
    final vocalPitchMetrics = ref.watch(vocalPitchMetricsProvider);

    // 최저/최고 노트(String) 저장
    final pitchStats = ref.read(vocalPitchMetricsProvider);
    final PitchToNoteConverter noteConverter = PitchToNoteConverter();
    final voiceTypeProfile = ref.read(voiceTypeProfileProvider.notifier);
    voiceTypeProfile.setMaxNote(noteConverter.hzToNote(pitchStats.maxPitch!));
    voiceTypeProfile.setMinNote(noteConverter.hzToNote(pitchStats.minPitch!));

    // 사용자 음역대 변환, 저장.
    String voiceType = determineVoiceType(
      vocalPitchMetrics.minPitch!,
      vocalPitchMetrics.maxPitch!,
      vocalPitchMetrics.averagePitch!,
    );
    voiceTypeProfile.setVoiceType(voiceType);

    final voiceTypeData = ref.watch(voiceTypeProfileProvider);
    debugPrint(
      "음역대 저장: ${voiceTypeData.voiceType} | ${voiceTypeData.minNote} | ${voiceTypeData.maxNote}",
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final granted = await ensureMicPermission(ref); // 공통 함수 재사용

      if (!granted) {
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

    // 음성 분석
    final isRecording = ref.watch(audioPitchNoSaveProvider);
    ref
        .watch(autoStartPitchStreamProvider)
        .when(
          data: (pitchData) {
            // 여기에서 pitchData.pitch 를 사용해서 화면 또는 로직 처리
            if (_maxPitch == null || pitchData.pitch > _maxPitch!) {
              setState(() => _maxPitch = pitchData.pitch);
            }

            setState(() {
              _isVoiceDetected = true; // 음정이 탐지됨 --> _isButtonActive = true
            });

            return SizedBox();
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
                '낼 수 있는 가장 높은 음을\n3초 이상 유지해주세요',
                style: TextStyle(
                  color: AppColors.grayscale1,
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
                      isRecording ? _navigateToOnboardingRecordingGuidePage : _startPitchDetect,
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
