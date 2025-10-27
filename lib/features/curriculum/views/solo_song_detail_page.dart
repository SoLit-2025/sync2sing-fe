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
import 'package:sync2sing/features/shared/views/voice_range_display.dart';

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
                  child: SingleChildScrollView(
                    physics: ClampingScrollPhysics(),
                    child: Column(
                      // 가사: 텍스트 리스트 형태로 만들기.
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children:
                          songDetailModel.lyrics.map((item) {
                            return Text(
                              item.text,
                              style: AppTextStyles.heading4Bold.copyWith(
                                color: AppColors.grayscale3,
                              ),
                            );
                          }).toList(),
                    ),
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
