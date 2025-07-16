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

class _MaximumPitchPageState extends ConsumerState<MaximumPitchPage> with WidgetsBindingObserver {
  bool _isVoiceDetecting = false;
  bool _isRecordingStarted = false; // '시작' 버튼을 눌러서 음성 녹음을 시작했는지 여부
  bool get _isMicOn => _isVoiceDetecting; // 음성이 수집 중이면 -> micOn 이미지 보여주기
  // 버튼 활성화 조건: '시작' 버튼 클릭 전 or '시작' 클릭 후 최대음정이 저장된 이후
  bool get _isButtonActive => !_isRecordingStarted || (_maxPitch != null);
  double? _maxPitch;
  double indicatorAngle = pi; // 음정 탐지 동그라미 위치: 최초 -> C2

  double? _candidateMaxPitch;
  DateTime? _candidateSince;
  static const Duration _maxPitchHoldDuration = Duration(seconds: 2); // 음정 최소 유지시간

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

      await analyzeAndStorePitchNote();
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
    voiceTypeProfile.setMaxNote(PitchToNoteConverter.midiToNote(pitchStats.maxPitch!));
    voiceTypeProfile.setMinNote(PitchToNoteConverter.midiToNote(pitchStats.minPitch!));

    // 사용자 음역대 변환, 저장.
    String voiceType = determineVoiceType(
      vocalPitchMetrics.minPitch!,
      vocalPitchMetrics.maxPitch!,
      vocalPitchMetrics.averagePitch!,
    );
    voiceTypeProfile.setVoiceType(voiceType);

    /// *** voiceType + 최고/최저 음정 노트  조회하기
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

      // 앱 생명주기 관찰 옵저버 등록
      WidgetsBinding.instance.addObserver(this);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 앱에서 나가면 recorder 일시정지 / 다시 들어오면 recorder 이어가기 (resume)
    if (state == AppLifecycleState.paused) {
      ref.read(audioPitchNoSaveProvider.notifier).pause();
    } else if (state == AppLifecycleState.resumed) {
      ref.read(audioPitchNoSaveProvider.notifier).startOrResume();
    }
    super.didChangeAppLifecycleState(state);
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

            // controller에서 pitched == false 이면 가짜 데이터: pitch=0, probabily=0 인 데이터를 줌 -> 거르기
            if (pitchData.pitch > 30) {
              // 사용자의 음정이 탐지됨 -> 사용자의 음성이 수집됨
              final nowMidi = PitchToNoteConverter.frequencyToMidi(pitchData.pitch);
              debugPrint("음정 탐지중: fre - ${pitchData.pitch} midi $nowMidi");

              setState(() {
                indicatorAngle =
                    pi * ((nowMidi - 36) / 60 + 1); // 음정탐지 동그라미 위치 바꾸기 36: C2, 60: C7-C2 (midi 기준)
                _isVoiceDetecting = true; // 음정이 탐지됨 -> 사용자의 음성이 수집됨 -> minOn
              });
              if (_maxPitch == null || nowMidi > _maxPitch!) {
                // 최저 음정 로컬 변수에 저장
                double tolerance = 2; // midi 기준, 이정도 차이는 유지 x도 ok
                if (_candidateMaxPitch == null) {
                  // 후보 최초 세팅
                  _candidateMaxPitch = nowMidi;
                  _candidateSince = DateTime.now();
                  debugPrint("후보 최초 세팅: $_candidateMaxPitch");
                } else {
                  // 허용 오차 안에 들어오는지 검사
                  if ((nowMidi - _candidateMaxPitch!).abs() <= tolerance) {
                    // 유지 시간 검사
                    final elapsed = DateTime.now().difference(_candidateSince!);
                    if (elapsed >= _maxPitchHoldDuration) {
                      // 최소 유지시간 충족!
                      setState(() {
                        _maxPitch = _candidateMaxPitch;
                        debugPrint("maxPitch 저장: $_maxPitch");
                      });
                      _candidateMaxPitch = null;
                      _candidateSince = null;
                    }
                  } else if (nowMidi > _candidateMaxPitch!) {
                    // 더 높은 후보면 갱신
                    _candidateMaxPitch = nowMidi;
                    _candidateSince = DateTime.now();
                    debugPrint("후보 갱신: $nowMidi");
                  } else {
                    // 너무 벗어나면 후보 초기화
                    _candidateMaxPitch = null;
                    _candidateSince = null;
                  }
                }
              } else {
                // pitch가 기존 maxPitch보다 낮으면 후보 초기화
                _candidateMaxPitch = null;
                _candidateSince = null;
              }

              return SizedBox();
            } else {
              setState(() {
                _isVoiceDetecting = false; // 음정이 탐지됨 --> _isButtonActive = true
              });
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
                '낼 수 있는 가장 높은 음을\n2초 이상 유지해주세요',
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
