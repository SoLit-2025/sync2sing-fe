import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';
import 'package:sync2sing/features/curriculum/logics/song_detail_model.dart';
import 'package:sync2sing/features/shared/logics/analysis_type.dart';
import 'package:sync2sing/features/shared/logics/training_mode.dart';
import 'package:sync2sing/features/onboarding/logics/watch_youtube_providers.dart';
import 'package:sync2sing/features/onboarding/views/youtube_player_widget.dart';
import 'package:sync2sing/features/shared/views/page_indicator.dart';

class SongExampleVideoPage extends ConsumerStatefulWidget {
  final TrainingMode trainingMode;
  final AnalysisType analysisType;
  final int songId;
  final int? roomId;
  const SongExampleVideoPage({
    super.key,
    required this.trainingMode,
    required this.analysisType,
    required this.songId,
    this.roomId,
  });
  @override
  ConsumerState<SongExampleVideoPage> createState() => _SongExampleVideoPageState();
}

class _SongExampleVideoPageState extends ConsumerState<SongExampleVideoPage> {
  late final Future<SongDetailModel> _songDetail;
  // final int _videoStartSec = 42;

  final Map<String, dynamic> onboardingJson = {
    "status": 200,
    "message": "솔로 트레이닝 원곡 조회에 성공했습니다.",
    "data": {
      "id": 3,
      "title": "Do-Re-Mi",
      "artist": "Richard Rodgers",
      'youtube_link': 'https://youtu.be/jyLP6XLgEYY?si=OysroAyUTirMbPCT',
      "voice_type": "SOPRANO",
      "pitch_note_min": "C4",
      "pitch_note_max": "D5",
      "lyrics": [
        {"line_index": 0, "text": "Doe(Do), a deer, a female deer", "start_time": 0},
        {"line_index": 1, "text": "Ray(Re), a drop of golden sun", "start_time": 7200},
      ],
      "album_art_url":
          "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
      "file_url":
          "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/audios/original/6875743e-3955-4067-abed-da1911a6aae1.mp3",
    },
  };

  final Map<String, dynamic> soloJson = {
    "status": 200,
    "message": "솔로 트레이닝 원곡 조회에 성공했습니다.",
    "data": {
      "id": 3,
      "title": "소다팝",
      "artist": " 사자보이즈",
      'youtube_link': 'https://www.youtube.com/watch?v=983bBbJx0Mk',
      "voice_type": "SOPRANO",
      "pitch_note_min": "C4",
      "pitch_note_max": "D5",
      "lyrics": [
        {"line_index": 0, "text": "Doe(Do), a deer, a female deer", "start_time": 0},
        {"line_index": 1, "text": "Ray(Re), a drop of golden sun", "start_time": 7200},
      ],
      "album_art_url":
          "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
      "file_url":
          "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/audios/original/6875743e-3955-4067-abed-da1911a6aae1.mp3",
    },
  };

  final Map<String, dynamic> duetJson = {
    "status": 200,
    "message": "솔로 트레이닝 원곡 조회에 성공했습니다.",
    "data": {
      "id": 3,
      "title": "Do-Re-Mi",
      "artist": "Richard Rodgers",
      'youtube_link': 'https://youtu.be/jyLP6XLgEYY?si=OysroAyUTirMbPCT',
      "voice_type": "SOPRANO",
      "pitch_note_min": "C4",
      "pitch_note_max": "D5",
      "lyrics": [
        {"line_index": 0, "text": "Doe(Do), a deer, a female deer", "start_time": 0},
        {"line_index": 1, "text": "Ray(Re), a drop of golden sun", "start_time": 7200},
      ],
      "album_art_url":
          "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
      "file_url":
          "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/audios/original/6875743e-3955-4067-abed-da1911a6aae1.mp3",
    },
  };

  Future<SongDetailModel> _fetchSongData() async {
    try {
      // final response = await DioFactory(
      //   SecureStorage(),
      // ).get('/${widget.trainingMode.apiBasePath}/songs/${widget.songId}?type=mr');
      // final responseJson = response.data;

      final responseJson = soloJson;

      debugPrint("songExamplePage - responseData: $responseJson");
      final songData = SongDetailModel.fromJson(responseJson['data']);

      return songData;
    } on DioException catch (e) {
      debugPrint("error2: ${e.response}");
      throw Exception(e.response);
    }
  }

  @override
  void initState() {
    super.initState();
    _songDetail = _fetchSongData();
  }

  @override
  Widget build(BuildContext context) {
    final bool isButtonEnabled = ref.watch(isOnboardingRecordingStartButtonEnabledProvider);

    return Scaffold(
      body: SafeArea(
        child: Container(
          alignment: Alignment(0.0, -1.0),
          margin: EdgeInsets.fromLTRB(0, 12.h, 0, 40.h), // 상하 여백
          child: SizedBox(
            width: 327.w,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                (widget.analysisType == AnalysisType.guest)
                    ? PageIndicator(currentPage: 4, pageCount: 6)
                    : PageIndicator(currentPage: 0, pageCount: 2), // 상단 페이지네이션 위젯
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 32.h, 0, 20.h),
                        width: 327.w,
                        alignment: Alignment(-1.0, -1.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              // 텍스트 필드 (글씨 안내)
                              padding: EdgeInsets.symmetric(vertical: 4.h),
                              child: Text(
                                switch (widget.analysisType) {
                                  AnalysisType.guest => "마지막 과정이에요",
                                  AnalysisType.pre => "훈련 전 진단을 시작합니다",
                                  AnalysisType.post => "훈련 후 진단을 시작합니다",
                                },
                                textAlign: TextAlign.left,
                                style: AppTextStyles.heading3Bold,
                              ),
                            ),

                            Text(
                              "아래 음원을 듣고 \n후렴구를 똑같이 따라 불러주세요",
                              textAlign: TextAlign.left,
                              style: AppTextStyles.heading4,
                            ),
                          ],
                        ),
                      ),
                      // 유튜브 영상
                      FutureBuilder(
                        future: _songDetail,
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.hasError) {
                            final errorString = snapshot.error.toString();
                            debugPrint("결과: ${snapshot.error.toString()}");

                            try {
                              final Map<String, dynamic> errorJson = jsonDecode(
                                errorString.replaceFirst('Exception: ', '').trim(),
                              );

                              return Text(errorJson['message']);
                            } catch (e) {
                              return Text('알 수 없는 오류가 발생했습니다.');
                            }
                          } else if (snapshot.hasData == false) {
                            // api 응답 대기 중
                            return SizedBox.shrink();
                          } else {
                            // api 응답 완료:),
                            SongDetailModel songDetail = snapshot.data;
                            debugPrint("songDetailModel: ${songDetail.youtubeLink}");
                            return Container(
                              width: 327.w,
                              margin: EdgeInsets.symmetric(vertical: 20.h),
                              child: YoutubePlayerWidget(
                                youtubeLink: songDetail.youtubeLink, // 도레미송 공식 가사 비디오
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),

                // 시작하기 버튼
                Container(
                  width: double.infinity,
                  height: 50.w,
                  margin: EdgeInsets.only(top: 32.h),
                  alignment: Alignment(0.0, 0.0),
                  child: CupertinoButton(
                    color: AppColors.primaryPink,
                    disabledColor: AppColors.primaryPinkDisabled, // 비활성화 색
                    borderRadius: BorderRadius.circular(10.r),
                    padding: EdgeInsets.all(0),
                    onPressed:
                        isButtonEnabled
                            ? () async {
                              SongDetailModel song;
                              await _songDetail.then((value) {
                                song = value;
                                if (mounted) {
                                  ref.invalidate(watchedDurationProvider);
                                  if (widget.trainingMode == TrainingMode.solo) {
                                    context.go(
                                      "${AppRoutePaths.soloPreRecordingSong}/${widget.analysisType.name}/${widget.songId}",
                                      extra: song.id,
                                    );
                                  } else {
                                    context.go(
                                      "${AppRoutePaths.duetRecordingSong}/${widget.analysisType.name}/${widget.songId}?roomId=${widget.roomId ?? ""}",
                                      extra: song.id,
                                    );
                                  }
                                }
                              });
                            }
                            : null,
                    minSize: 0.0,
                    child: Center(
                      child: Text(
                        "시작하기",
                        style:
                            isButtonEnabled
                                ? AppTextStyles.body1BoldWhite
                                : AppTextStyles.body1White,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
