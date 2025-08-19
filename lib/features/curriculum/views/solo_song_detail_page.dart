import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';

import '../logics/selected_song_provider.dart';
import '../logics/song_detail_model.dart';

class SoloSongDetailPage extends StatelessWidget {
  final SongDetailModel songDetailModel;
  SoloSongDetailPage({super.key, required this.songDetailModel});

  final AudioPlayer _audioPlayer = AudioPlayer();
  final ValueNotifier<bool> isPlaying = ValueNotifier(false); // 노래가 재생되고 있는지 여부

  void _playMusic() {
    _audioPlayer.play();
  }

  void _pauseMusic() {
    _audioPlayer.pause();
    _audioPlayer.playerState;
  }

  @override
  Widget build(BuildContext context) {
    _audioPlayer.setUrl(songDetailModel.fileUrl);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.grayscale8,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Image.asset(
            'assets/images/left_arrow_icon.png',
            width: 14.w,
            height: 24.h,
            errorBuilder:
                (context, error, stackTrace) =>
                    Icon(CupertinoIcons.chevron_back, color: AppColors.grayscale4),
          ),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter, // container 상단 중앙 정렬
        child: Container(
          width: 327.w,
          alignment: Alignment.topLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _songOverview(), // 상단 노래 제목, 앨범 커버 등이 있는 블럭
              SizedBox(height: 10.h),
              VoiceRangeDisplay(
                pitchNoteMax: songDetailModel.pitchNoteMax,
                pitchNoteMin: songDetailModel.pitchNoteMin,
              ),
              SizedBox(height: 20.h),
              // 가사 영역
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 18.h),
                  alignment: Alignment.topCenter,
                  decoration: BoxDecoration(
                    color: AppColors.grayscale7,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Column(
                    // 가사: 텍스트 리스트 형태로 만들기.
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children:
                        songDetailModel.lyrics.map((item) {
                          return Text(
                            item.text,
                            style: AppTextStyles.heading4Bold.copyWith(color: AppColors.grayscale3),
                          );
                        }).toList(),
                  ),
                ),
              ),
              SizedBox(height: 30.h),
              _chooseButton(context),
              SizedBox(height: 36.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _songOverview() {
    return SizedBox(
      height: 100.h,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 앨범 커버 이미지 + 노래 재생 버튼
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5.r),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.white.withValues(alpha: 0.5),
                    BlendMode.srcATop,
                  ),
                  child:
                      songDetailModel.albumArtUrl.startsWith("assets")
                          ? Image.asset(
                            songDetailModel.albumArtUrl,
                            width: 80.w,
                            fit: BoxFit.contain,
                          )
                          : Image.network(
                            songDetailModel.albumArtUrl,
                            width: 80.w,
                            fit: BoxFit.contain,
                          ),
                ),
              ),

              // 재생 버튼
              StreamBuilder<PlayerState>(
                // 실시간 상태 반영.
                stream: _audioPlayer.playerStateStream,
                builder: (context, snapshot) {
                  final state = snapshot.data;
                  final isEnded =
                      state?.processingState == ProcessingState.completed; // 음원이 다 재생되었는지 여부
                  final playing = state?.playing ?? false; // 노래 재생되고 있는지 여부

                  // 음원이 끝났으면 isPlaying을 false로
                  if (isEnded) {
                    isPlaying.value = false;
                    _audioPlayer.pause();
                    _audioPlayer.setUrl(songDetailModel.fileUrl); // 다시 재생 시 음원 듣기 가능
                  } else {
                    isPlaying.value = playing;
                  }
                  return ValueListenableBuilder<bool>(
                    valueListenable: isPlaying,
                    builder: (context, isPlayingVal, _) {
                      return GestureDetector(
                        onTap: isPlayingVal ? _pauseMusic : _playMusic,
                        child: Image.asset(
                          isPlayingVal ? "assets/images/pause.png" : "assets/images/play.png",
                          color: AppColors.primaryPink,
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
          SizedBox(width: 10.w),
          // 노래 정보 영역
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(songDetailModel.title, style: AppTextStyles.body1Bold),
                Text(
                  songDetailModel.artist,
                  style: AppTextStyles.body2.copyWith(color: AppColors.grayscale3),
                  softWrap: false, // 텍스트 줄 제한
                  overflow: TextOverflow.ellipsis, // 말줄임표 (...)
                  maxLines: 1,
                ),
                Container(
                  width: 60.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: AppColors.grayscale3,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Center(
                    child: Text(
                      songDetailModel.getVoiceTypeKorean(),
                      style: AppTextStyles.body6.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chooseButton(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return Container(
          width: double.infinity,
          height: 50.w,
          alignment: Alignment(0.0, 0.0),
          child: CupertinoButton(
            color: AppColors.primaryPink,
            borderRadius: BorderRadius.circular(10.r),
            padding: EdgeInsets.all(0),
            onPressed: () {
              ref
                  .read(selectedSongProvider.notifier)
                  .selectSong(
                    id: songDetailModel.id,
                    title: songDetailModel.title,
                    artist: songDetailModel.artist,
                    albumArtUrl: songDetailModel.albumArtUrl,
                    voiceType: songDetailModel.voiceType,
                  );
              context.go(AppRoutePaths.soloTrainingSetting);
            },
            minSize: 0.0,
            child: Center(child: Text("선택하기", style: AppTextStyles.body1BoldWhite)),
          ),
        );
      },
    );
  }
}

class VoiceRangeDisplay extends StatelessWidget {
  final String pitchNoteMin;
  final String pitchNoteMax;

  const VoiceRangeDisplay({super.key, required this.pitchNoteMin, required this.pitchNoteMax});

  static int _noteToNumber(String note) {
    if (note.isEmpty) return -1;

    final Map<String, int> noteMap = {
      'C': 0,
      'C#': 1,
      'Db': 1,
      'D': 2,
      'D#': 3,
      'Eb': 3,
      'E': 4,
      'F': 5,
      'F#': 6,
      'Gb': 6,
      'G': 7,
      'G#': 8,
      'Ab': 8,
      'A': 9,
      'A#': 10,
      'Bb': 10,
      'B': 11,
    };

    final RegExp octaveRegex = RegExp(r'\d+');
    final Match? octaveMatch = octaveRegex.firstMatch(note);
    if (octaveMatch == null) return -1;

    final int? octave = int.tryParse(octaveMatch.group(0)!);
    if (octave == null || octave < 0) return -1;

    final String noteName = note.replaceAll(octaveRegex, '');
    final int? noteValue = noteMap[noteName];
    if (noteValue == null) return -1;

    //  C0 = 0, C1 = 12)
    return (octave * 12) + noteValue;
  }

  @override
  Widget build(BuildContext context) {
    // 바의 음정 범위
    const String barMinNoteString = 'G#2';
    const String barMaxNoteString = 'C5';

    final int barMinNum = _noteToNumber(barMinNoteString); // 32
    final int barMaxNum = _noteToNumber(barMaxNoteString); // 60

    // 예외값 처리
    if (barMinNum == -1 || barMaxNum == -1 || barMaxNum <= barMinNum) {
      return const SizedBox.shrink();
    }

    // bar 차이값 구하기 -> 0 ~ 가장 오른쪽 값 구함.
    final int totalBarRangeSemitones = barMaxNum - barMinNum;

    final int songMinNum = _noteToNumber(pitchNoteMin);
    final int songMaxNum = _noteToNumber(pitchNoteMax);

    // 바에서 상대적인 위치 정하기
    double startOffsetSemitones = (songMinNum - barMinNum).toDouble().clamp(
      0.0,
      totalBarRangeSemitones.toDouble(),
    );
    double endOffsetSemitones = (songMaxNum - barMinNum).toDouble().clamp(
      0.0,
      totalBarRangeSemitones.toDouble(),
    );

    // 최대 노트가 최소 노트값보다 작은 경우
    if (endOffsetSemitones < startOffsetSemitones) {
      endOffsetSemitones = startOffsetSemitones;
    }

    final double startFactor = startOffsetSemitones / totalBarRangeSemitones; // 시작 위치 퍼센트값
    final double widthFactor =
        (endOffsetSemitones - startOffsetSemitones) / totalBarRangeSemitones; // 음정 막대 길이

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.grayscale8,
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: AppColors.grayscale6, width: 1.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("노래 음역대", style: AppTextStyles.body4),
          SizedBox(
            width: 200.w,
            child: Column(
              children: [
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final double barWidth = constraints.maxWidth; // 주어진 widgth 를 모두 사용

                    // minNote / max 시작 위치
                    final double songMinNoteX = startFactor * barWidth;
                    final double songMaxNoteX = (startFactor + widthFactor) * barWidth;
                    final double minNoteLabelAdjustedX = (songMinNoteX - 5).clamp(0, songMinNoteX);
                    final double maxNoteLabelAdjustedX = songMaxNoteX - 5;

                    return SizedBox(
                      width: double.infinity,
                      height: 16.h,
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            left: minNoteLabelAdjustedX,
                            child: Text(pitchNoteMin, style: AppTextStyles.body6),
                          ),
                          Positioned(
                            left: maxNoteLabelAdjustedX.clamp(
                              minNoteLabelAdjustedX + 15,
                              barWidth - 15,
                            ),
                            child: Text(pitchNoteMax, style: AppTextStyles.body6),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: 6.h),
                // 막대 바
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final double barWidth = constraints.maxWidth;
                    return Container(
                      height: 7.h,
                      decoration: BoxDecoration(
                        color: AppColors.grayscale6,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Stack(
                        children: <Widget>[
                          // 노래 음역대 표시.
                          Positioned(
                            left: startFactor * barWidth,
                            width: widthFactor * barWidth,
                            child: Container(
                              height: 7.h,
                              decoration: BoxDecoration(
                                color: AppColors.primaryPink,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
