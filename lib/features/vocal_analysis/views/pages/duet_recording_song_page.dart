import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';
import 'package:sync2sing/features/curriculum/logics/duet_song_model.dart';
import 'package:sync2sing/features/curriculum/logics/song_detail_model.dart';
import 'package:sync2sing/features/curriculum/logics/timed_lyric.dart';
import 'package:sync2sing/features/shared/logics/analysis_type.dart';
import 'package:sync2sing/features/vocal_analysis/logics/providers/vocal_result_provider.dart';
import 'package:sync2sing/features/vocal_analysis/views/widgets/music_content_player.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/features/vocal_analysis/logics/providers/audio_recorder_provider.dart';
import 'package:sync2sing/features/shared/views/page_indicator.dart';
import 'dart:io';

class DuetRecordingSongPage extends ConsumerStatefulWidget {
  final AnalysisType analysisType; // 아마 analysisType 로 onboarding 역할 아예 대체 가능할 듯.
  final int songId;
  final int? roomId;
  final int partNumber;

  const DuetRecordingSongPage({
    required this.analysisType,
    required this.songId,
    required this.partNumber,
    this.roomId,
    super.key,
  });

  @override
  ConsumerState createState() => _DuetRecordingSongPageState();
}

class _DuetRecordingSongPageState extends ConsumerState<DuetRecordingSongPage>
    with WidgetsBindingObserver {
  Key _playerKey = UniqueKey();

  bool _isButtonEnabled = false;
  late final SongDetailModel _songDetailModel;
  late final String _pitchJsonPath;
  final double timeOffset = -3.79;

  final SongDetailModel _roseSong = DuetSongModel(
    28,
    "APT.",
    "로제, Bruno Mars",
    'https://www.youtube.com/watch?v=8Ebqe2Dbzls',
    "ALTO",
    "D4",
    "D#5",
    [
      TimedLyric(0, "(전주중)", 0),
      TimedLyric(1, "Don't you want me like I want you baby", 3352),
      TimedLyric(2, "Don't you need me like I need you now", 6828),
      TimedLyric(3, "Sleep tomorrow but tonight go crazy", 9967),
      TimedLyric(4, "All you gotta do is just meet me at the", 13249),
      TimedLyric(5, "아파트 아파트", 16468),
      TimedLyric(6, "아파트 아파트", 18080),
      TimedLyric(7, "아파트 아파트", 19936),
      TimedLyric(8, "Just meet me at the", 20936),
      TimedLyric(9, "아파트 아파트", 22886),
      TimedLyric(10, "아파트 아파트", 24500),
      TimedLyric(11, "아파트 아파트", 26146),
      TimedLyric(12, "Uh, uh huh uh huh", 27475),
      TimedLyric(13, "아파트 아파트", 29388),
      TimedLyric(14, "아파트 아파트", 30938),
      TimedLyric(15, "아파트 아파트", 32615),
      TimedLyric(16, "Just meet me at the", 34139),
      TimedLyric(17, "아파트 아파트", 35952),
      TimedLyric(18, "아파트 아파트", 37348),
      TimedLyric(19, "아파트 아파트", 39001),
      TimedLyric(20, "Uh, uh huh uh huh", 40901),
    ],
    "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/06802146-3055-4f82-bf52-fc653ce63791.jpg",
    'assets/songs/audios/apt_mr_v1.wav',
    duetParts: [
      DuetPart(
        partNumber: 0,
        partName: "로제",
        voiceType: "ALTO",
        pitchNoteMin: "D4",
        pitchNoteMax: "D#5",
      ),
      DuetPart(
        partNumber: 0,
        partName: "Bruno Mars",
        voiceType: "TENOR",
        pitchNoteMin: "D4",
        pitchNoteMax: "A#4",
      ),
    ],
    pitchJsonPath: 'assets/songs/datas/apt_rose_pitch_bar_v1.json',
  );

  final SongDetailModel _brunoSong = DuetSongModel(
    26,
    "APT.",
    "로제, Bruno Mars",
    'https://www.youtube.com/watch?v=8Ebqe2Dbzls',
    "ALTO",
    "D4",
    "D#5",
    [
      TimedLyric(0, "(전주중)", 0),
      TimedLyric(1, "Don't you want me like I want you baby", 3352),
      TimedLyric(2, "Don't you need me like I need you now", 6828),
      TimedLyric(3, "Sleep tomorrow but tonight go crazy", 9967),
      TimedLyric(4, "All you gotta do is just meet me at the", 13249),
      TimedLyric(5, "아파트 아파트", 16468),
      TimedLyric(6, "아파트 아파트", 18080),
      TimedLyric(7, "아파트 아파트", 19936),
      TimedLyric(8, "Uh, uh huh uh huh", 20936),
      TimedLyric(9, "아파트 아파트", 22886),
      TimedLyric(10, "아파트 아파트", 24500),
      TimedLyric(11, "아파트 아파트", 26146),
      TimedLyric(12, "Just meet me at the", 27475),
      TimedLyric(13, "아파트 아파트", 29388),
      TimedLyric(14, "아파트 아파트", 30938),
      TimedLyric(15, "아파트 아파트", 32615),
      TimedLyric(16, "Just meet me at the", 34139),
      TimedLyric(17, "아파트 아파트", 35952),
      TimedLyric(18, "아파트 아파트", 37348),
      TimedLyric(19, "아파트 아파트", 39001),
      TimedLyric(20, "Uh, uh huh uh huh", 40901),
    ],
    "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/06802146-3055-4f82-bf52-fc653ce63791.jpg",
    'assets/songs/audios/apt_mr_v1.wav',
    duetParts: [
      DuetPart(
        partNumber: 0,
        partName: "로제",
        voiceType: "ALTO",
        pitchNoteMin: "D4",
        pitchNoteMax: "D#5",
      ),
      DuetPart(
        partNumber: 0,
        partName: "Bruno Mars",
        voiceType: "TENOR",
        pitchNoteMin: "D4",
        pitchNoteMax: "A#4",
      ),
    ],
    pitchJsonPath: 'assets/songs/datas/apt_bruno_pitch_bar_v1.json',
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    debugPrint("duet recording song page: ${widget.analysisType.name}");

    _songDetailModel = (widget.partNumber == 0) ? _roseSong : _brunoSong;
    // (widget.partNumber != 3)
    //     ? SongDetailModel(
    //       2,
    //       "Do-Re-Mi Song",
    //       "Richard Rodgers",
    //       'https://youtu.be/jyLP6XLgEYY?si=OysroAyUTirMbPCT',
    //       "SOPRANO",
    //       "C4",
    //       "D5",
    //       [
    //         TimedLyric(0, "(전주중)", 0),
    //         TimedLyric(1, "Doe - a deer,", 2300),
    //         TimedLyric(2, "a female deer", 4000),
    //         TimedLyric(3, "Ray - a drop of golden sun", 6000),
    //         TimedLyric(4, "Me, a name I call myself", 10000),
    //       ],
    //       "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
    //       "assets/songs/audios/doremi_song_v3_mr.wav",
    //       pitchJsonPath: 'assets/songs/datas/doremi_song_v3_mr.json',
    //     )
    //     : _roseSong;
    _pitchJsonPath = _songDetailModel.pitchJsonPath!;
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
                  _pitchJsonPath,
                  onChildBoolChanged,
                  timeOffset: timeOffset,
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
                      padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),

                      /// 버튼 클릭 시 동작
                      /// 활성화 조건을 만족하면 분석 로딩 페이지로 이동
                      onPressed:
                          _isButtonEnabled
                              ? () async {
                                // 데이터 저장
                                await storeVocalAnalysisSubmit(ref);
                                if (!context.mounted) return; // 반드시 위 함수가 실행된 후에 페이지를 이동하도록 함
                                debugPrint("recordingSongPage - roomId: ${widget.roomId}");
                                context.go(
                                  "${AppRoutePaths.vocalAnalysisLoading}/duet/${widget.analysisType.name}?roomId=${widget.roomId}",
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
