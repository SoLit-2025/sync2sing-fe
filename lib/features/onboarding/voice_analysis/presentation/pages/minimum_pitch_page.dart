import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/features/onboarding/voice_analysis/presentation/widgets/onboarding_page_indicator.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/shared/providers/audio_pitch_no_save_provider.dart';
import 'package:sync2sing/shared/providers/vocal_pitch_metrics_provider.dart';

import '../../../../../shared/utils/mic_permission_helper.dart';
import '../../../../training_common/data/services/pitch_to_note_converter.dart';

class MinimumPitchPage extends ConsumerStatefulWidget {
  const MinimumPitchPage({super.key});

  @override
  ConsumerState<MinimumPitchPage> createState() => _MinimumPitchPageState();
}

class _MinimumPitchPageState extends ConsumerState<MinimumPitchPage> with WidgetsBindingObserver {
  bool _isVoiceDetecting = false;

  // '시작' 버튼 클릭 여부 -> 페이지에 처음 들어왔을 땐 무조건'시작' 버튼을 클릭할 수 있어야 함
  bool _isRecordingStarted = false;
  bool get _isMicOn => _isVoiceDetecting;
  // 버튼 활성화 조건: '시작' 버튼 클릭 전 or '시작' 클릭 후 음정이 탐지된 이후
  bool get _isButtonActive => !_isRecordingStarted || (_minPitch != null);
  double? _minPitch;

  double indicatorAngle = pi; // C2 위치

  double? _candidateMinPitch;
  DateTime? _candidateSince;
  static const Duration _minPitchHoldDuration = Duration(seconds: 2); // 음정 최소 유지 시간

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

      // 옵저버 등록: 앱 생명주기
      WidgetsBinding.instance.addObserver(this);
    });
  }

  @override
  void dispose() {
    // 옵저버 해제: 앱 생명주기
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

    // 실시간 음정 탐지 관련 코드 (저장 x) / 진입과 동시에 녹음 시작.
    final isRecording = ref.watch(audioPitchNoSaveProvider);
    ref
        .watch(autoStartPitchStreamProvider)
        .when(
          data: (pitchData) {
            // 여기에서 pitchData.pitch 를 사용해서 화면 또는 로직 처리

            // pitched == false 일 때 가짜 데이터 수신: pitch=0, probability=0
            if (pitchData.pitch > 30) {
              // 사용자의 음정이 탐지됨 -> 사용자의 음성이 수집됨
              final nowMidi = PitchToNoteConverter.frequencyToMidi(pitchData.pitch);

              debugPrint("음정 탐지중: fre: ${pitchData.pitch} midi: $nowMidi");
              setState(() {
                indicatorAngle =
                    pi * ((nowMidi - 36) / 60 + 1); // 음정 탐지 동그리미 각도 -> 위치 c2: 36,c7 - c2: 60
                _isVoiceDetecting = true; // 음정이 탐지됨 --> _isButtonActive = true
              });

              if (_minPitch == null || nowMidi < _minPitch!) {
                // 최저 음정 로컬 변수에 저장

                double tolerance = 2; // midi 기준, 이정도 차이는 유지 x도 ok
                if (_candidateMinPitch == null) {
                  // 후보 최초 세팅
                  _candidateMinPitch = nowMidi;
                  _candidateSince = DateTime.now();
                  debugPrint("후보 최초 세팅: $_candidateMinPitch");
                } else {
                  // 허용 오차 안에 들어오는지 검사
                  if ((nowMidi - _candidateMinPitch!).abs() <= tolerance) {
                    // 유지 시간 검사
                    final elapsed = DateTime.now().difference(_candidateSince!);
                    if (elapsed >= _minPitchHoldDuration) {
                      // 최소 유지시간 충족!
                      setState(() {
                        _minPitch = _candidateMinPitch;
                        debugPrint("minPitch 저장: $_minPitch");
                      });
                      _candidateMinPitch = null;
                      _candidateSince = null;
                    }
                  } else if (nowMidi < _candidateMinPitch!) {
                    // 더 낮은 후보면 갱신
                    _candidateMinPitch = nowMidi;
                    _candidateSince = DateTime.now();
                    debugPrint("후보 갱신: $nowMidi");
                  } else {
                    // 너무 벗어나면 후보 초기화
                    _candidateMinPitch = null;
                    _candidateSince = null;
                  }
                }
              } else {
                // pitch가 기존 minPitch보다 높으면 후보 초기화
                _candidateMinPitch = null;
                _candidateSince = null;
              }

              return SizedBox();
            } else {
              setState(() {
                _isVoiceDetecting = false;
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
                '낼 수 있는 가장 낮은 음을\n2초 이상 유지해주세요',
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
