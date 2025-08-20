import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';
import 'package:sync2sing/features/curriculum/logics/song_detail_model.dart';
import 'package:sync2sing/features/curriculum/logics/timed_lyric.dart';
import 'package:sync2sing/features/shared/logics/analysis_type.dart';
import 'package:sync2sing/features/report/logics/vocal_analysis_submit_provider.dart';
import 'package:sync2sing/features/vocal_analysis/logics/providers/vocal_result_provider.dart';
import 'package:sync2sing/features/vocal_analysis/views/widgets/music_content_player.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/features/vocal_analysis/logics/providers/audio_recorder_provider.dart';
import 'package:sync2sing/features/shared/views/page_indicator.dart';
import 'dart:io';


class SoloRecordingSongPage extends ConsumerStatefulWidget {
  final AnalysisType analysisType; // 아마 analysisType 로 onboarding 역할 아예 대체 가능할 듯.
  final int songId;

  const SoloRecordingSongPage({
    required this.analysisType,
    required this.songId,
    super.key,
  });

  @override
  ConsumerState createState() => _SoloRecordingSongPageState();
}

class _SoloRecordingSongPageState extends ConsumerState<SoloRecordingSongPage>
    with WidgetsBindingObserver {
  Key _playerKey = UniqueKey();

  bool _isButtonEnabled = false;
  late final SongDetailModel _songDetailModel;
  final String jsonStr = '''
  {
    "status": 200,
    "message": "솔로 트레이닝 MR 곡 조회에 성공했습니다.",
    "data": {
        "id": 1,
        "title": "Golden",
        "artist": "HUNXR/X(EJAE, Audrey NUNA, REI AMI)",
        "voice_type": "SOPRANO",
        "pitch_note_min": "A3",
        "pitch_note_max": "C4",
        "lyrics": [
        {
                "line_index": 0,
                "text": "I'm done hidin'",
                "start_time": 200
            },
             {
                "line_index": 1,
                "text": "now I'm shinin'",
                "start_time": 700
            },
             {
                "line_index": 2,
                "text": "like I'm born to be",
                "start_time": 1200
            },
             {
                "line_index": 3,
                "text": "We dreamin' hard",
                "start_time": 1700
            },
            {
                "line_index": 4,
                "text": "we came so far",
                "start_time": 2000
            },
            {
                "line_index": 5,
                "text": "now I believe",
                "start_time": 2500
            }
        ],
        "album_art_url": "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
        "file_url": "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/audios/mr/27e305f9-ca07-4f53-a15a-94f1b5b0cc89.mp3"
    }
}
''';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (widget.analysisType == AnalysisType.guest) {
      // guest -> 온보딩처럼 -> 걍 가져오기
      // context.go(AppRoutePaths.onboardingRecordingSong);
      _songDetailModel = SongDetailModel(
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
        "assets/songs/audios/doremi_song_v3_mr.wav",
      );
    } else {
      Map<String, dynamic> decoded = jsonDecode(jsonStr);
      _songDetailModel = SongDetailModel.fromJson(decoded);
    }
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

  void storeVocalAnalysisSubmit(ref) {
    /// vocalAnalysisSubmitProvider 새로고침
    /// 이전 분석 결과를 초기화하고 새로운 분석 시작
    ref.refresh(vocalAnalysisSubmitProvider);

    /// 파일 경로 및 정확도 저장
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

    /// *** 저장한 것: 파일 경로 및 정확도 조회하기
    final vocalPitchData = ref.watch(vocalResultProvider);
    debugPrint(
      "파일 경로 및 정확도 저장: ${vocalPitchData.wavFilePath} | ${vocalPitchData.pitchAccuracy} | ${vocalPitchData.rhythmAccuracy}",
    );

    // ★ 실제 파일 존재 및 크기 확인
    if (vocalPitchData.wavFilePath != null) {
      final file = File(vocalPitchData.wavFilePath!);
      debugPrint('→ 실제 파일 존재: ${file.existsSync()}');
      debugPrint('→ 실제 파일 크기: ${file.lengthSync()}바이트');
    }

    // audioRecorderProvider 등록 해제
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
              (widget.analysisType == AnalysisType.guest)
                  ? const PageIndicator(currentPage: 5, pageCount: 6) // onboarding 페이지처럼 보이게.
                  : const PageIndicator(currentPage: 1, pageCount: 2),

              /// 위와 중간 사이 간격
              /// Spacer는 남은 공간을 균등하게 분배합니다
              Spacer(),

              /// 중간 콘텐츠 영역
              /// 음악 플레이어와 시각화가 들어가는 메인 영역
              Container(
                width: 327.w,
                height: 556.h,
                padding: EdgeInsets.fromLTRB(16.h, 16.h, 16.h, 20.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: AppColors.grayscale6, // 연한 회색 배경
                ),
                child: MusicContentPlayer(
                  _songDetailModel,
                  'assets/songs/datas/doremi_song_piano_v2.json', // 백엔드에 음정 박자 모델 파일 경로 추가 필요.
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
                                storeVocalAnalysisSubmit(ref);

                                context.go(
                                  AppRoutePaths
                                      .vocalAnalysisLoading, // /${widget.trainingMode}/${widget.analysisType}
                                );
                              }
                              : null,
                      // 비활성화 시 null (클릭 불가)
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
