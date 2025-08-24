import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';
import 'package:sync2sing/features/curriculum/logics/song_detail_model.dart';
import 'package:sync2sing/features/curriculum/logics/timed_lyric.dart';
import 'package:sync2sing/features/vocal_analysis/logics/providers/vocal_result_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/features/vocal_analysis/logics/providers/audio_recorder_provider.dart';
import 'package:sync2sing/features/shared/views/page_indicator.dart';
import 'dart:io';

import '../widgets/music_content_player.dart';

/// 온보딩 과정의 녹음 페이지
///
/// 이 페이지의 역할:
/// 1. 사용자에게 도레미송을 들려주고 따라 부르도록 안내
/// 2. MusicContentPlayer를 통해 음정/박자 시각화 제공
/// 3. 녹음 완료 후 보컬 분석 리포트 생성으로 이동
///
/// 페이지 구성:
/// - 상단: 페이지 인디케이터 (현재 5/6 단계)
/// - 중간: 음악 플레이어 및 시각화 영역
/// - 하단: 보컬 분석 리포트 생성 버튼
class OnboardingRecordingSongPage extends ConsumerStatefulWidget {
  const OnboardingRecordingSongPage({super.key});

  @override
  ConsumerState createState() => _OnboardingRecordingSongPageState();
}

class _OnboardingRecordingSongPageState extends ConsumerState<OnboardingRecordingSongPage>
    with WidgetsBindingObserver {
  Key _playerKey = UniqueKey();
  bool _isButtonEnabled = false;
  late final SongDetailModel _songDetailModel = SongDetailModel(
    1,
    "Do-Re-Mi Song",
    "Richard Rodgers",
    "SOPRANO",
    "C4",
    "D5",
    [
      TimedLyric(0, "(전주중)", 0),
      TimedLyric(1, "Doe - a deer,", 2300),
      TimedLyric(2, "a female deer", 4000),
      TimedLyric(3, "Ray - a drop of golden sun", 6000),
    ],
    "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
    "assets/songs/audios/doremi_song_v3_mr.wav", // 백엔드에 저장된 파일과 음정 박자 파일 불일치 -> asset 사용. 다만 길이 조정 필요 (음악 끝나기 전까지 다음버튼 클릭 불가)
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 앱을 다시 들어왔고/ 만약 녹음기가 꺼져있다 (녹음 중지를 하지 않고 나간 경우)
    if (state == AppLifecycleState.resumed && ref.read(audioRecorderProvider.notifier).isStopped) {
      setState(() {
        _playerKey = UniqueKey(); // MusicContentPlayer를 완전히 새로고침
      });
    }
  }

  // 하위 위젯에서 bool 값을 전달할 콜백 함수
  void onChildBoolChanged(bool value) {
    setState(() {
      _isButtonEnabled = value;
    });
  }

  Future<void> storeVocalAnalysisSubmit(ref) async {
    /// 파일 경로 및 정확도 저장
    /// *** ref 를 dispose() 에서 사용할 수 없어서 여기서 저장하게 로직을 작성하였습니다. -> 나중에 리팩토링될 수 있음.
    final controller = ref.read(audioRecorderProvider.notifier);
    final pitchAccuracy = controller.pitchAccuracy;

    debugPrint('🎯 pitch 정확도: $pitchAccuracy');

    // VocalResult Provider에 파일 경로 / 음정 및 박자 정확도 저장
    ref
        .read(vocalResultProvider.notifier)
        .setWavFilePath(ref.read(audioRecorderProvider.notifier).getWavFilePath()); // 음성 파일 경로
    ref.read(vocalResultProvider.notifier).setPitchAccuracy(pitchAccuracy);
    ref.read(vocalResultProvider.notifier).setRhythmAccuracy(controller.rhythmAccuracy);

    controller.printRhythmAccuracyDetailStatistics();

    await controller.stop();

    /// *** 저장한 것: 파일 경로 및 정확도 조회하기
    final vocalPitchData = ref.watch(vocalResultProvider);
    debugPrint(
      "파일 경로 및 정확도 저장: ${vocalPitchData.wavFilePath} | ${vocalPitchData.pitchAccuracy} | ${vocalPitchData.rhythmAccuracy}",
    );
    //
    // ★ 실제 파일 존재 및 크기 확인
    if (vocalPitchData.wavFilePath != null) {
      final file = File(vocalPitchData.wavFilePath!);
      debugPrint('→ 실제 파일 존재: ${file.existsSync()}');
      debugPrint('→ 실제 파일 크기: ${file.lengthSync()}바이트');
    }

    ref.invalidate(audioRecorderProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// 키보드가 올라와도 화면 크기가 변하지 않도록 설정
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          width: double.infinity, // 수평 중앙 정렬
          padding: EdgeInsets.fromLTRB(0, 12.h, 0, 40.h), // 상하 여백
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// 상단 페이지 인디케이터
              /// 현재 진행 상황을 사용자에게 시각적으로 표시
              /// 5/6 단계: 거의 마지막 단계임을 알려줍니다
              const PageIndicator(currentPage: 5, pageCount: 6),

              /// 위와 중간 사이 간격
              /// Spacer는 남은 공간을 균등하게 분배합니다
              Spacer(),

              /// 중간 콘텐츠 영역
              /// 음악 플레이어와 시각화가 들어가는 메인 영역
              Container(
                width: 327.w,
                height: 556.h,
                padding: EdgeInsets.fromLTRB(16.h, 16.h, 16.h, 20.h),
                // constraints: BoxConstraints(minHeight: 300.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: AppColors.grayscale6,
                ),

                /// MusicContentPlayer: 음악 재생, 녹음, 시각화를 담당하는 핵심 위젯
                /// 이 위젯에서 모든 음악 관련 기능이 처리됩니다
                // child: MusicContentPlayer(key: _playerKey),
                child: MusicContentPlayer(
                  _songDetailModel,
                  'assets/songs/datas/doremi_song_piano_v2.json',
                  onChildBoolChanged,
                  key: _playerKey,
                ),
              ),

              /// 중간과 버튼 사이 간격
              Spacer(),

              /// 하단 버튼
              /// 보컬 분석 리포트 생성 버튼
              SizedBox(
                width: 327.w,
                height: 50.w,
                child: Consumer(
                  builder: (context, ref, child) {
                    return CupertinoButton(
                      /// 버튼 색상 설정
                      /// 활성화 시: 분홍색, 비활성화 시: 연한 분홍색
                      color: AppColors.primaryPink,
                      disabledColor: AppColors.primaryPinkDisabled,
                      borderRadius: BorderRadius.circular(10.w),

                      /// 버튼 클릭 시 동작
                      /// 활성화 조건을 만족하면 분석 로딩 페이지로 이동
                      onPressed:
                          _isButtonEnabled
                              ? () async {
                                // 데이터 저장
                                await storeVocalAnalysisSubmit(ref);
                                if (!context.mounted) return; // 반드시 위 함수가 실행된 후에 페이지를 이동하도록 함

                                context.go("${AppRoutePaths.vocalAnalysisLoading}/solo/guest");
                              }
                              : null,
                      // 비활성화 시 null (클릭 불가)
                      /// 버튼 텍스트
                      /// 활성화 상태에 따라 텍스트 스타일이 달라집니다
                      child: Text(
                        "보컬 분석 리포트 생성하기",
                        style:
                            _isButtonEnabled
                                ? AppTextStyles
                                    .body1BoldWhite // 활성화: 굵은 흰색
                                : AppTextStyles.body1White, // 비활성화: 일반 흰색
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
