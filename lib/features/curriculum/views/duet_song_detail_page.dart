import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';
import 'package:sync2sing/features/curriculum/logics/duet_song_model.dart';
import 'package:sync2sing/features/curriculum/logics/selected_song_provider.dart';
import 'package:sync2sing/features/curriculum/logics/song_detail_model.dart';
import 'package:sync2sing/features/curriculum/logics/timed_lyric.dart';
import 'package:sync2sing/features/home_hub/views/duet_song_section.dart';
import 'package:sync2sing/features/shared/views/simple_app_bar.dart';
import 'package:sync2sing/features/shared/views/voice_range_display.dart';

class DuetSongDetailPage extends ConsumerStatefulWidget {
  final DuetSongModel duetSongModel;
  final bool isSelectFirst;

  const DuetSongDetailPage({super.key, required this.duetSongModel, this.isSelectFirst = true});

  @override
  ConsumerState<DuetSongDetailPage> createState() => _DuetSongDetailPageState();
}

class _DuetSongDetailPageState extends ConsumerState<DuetSongDetailPage> {
  late bool isSelectFirstPart;

  @override
  void initState() {
    super.initState();
    isSelectFirstPart = widget.isSelectFirst;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SimpleAppBar(),
            Expanded(
              child: SizedBox(
                width: 327.w,
                child: Column(
                  children: [
                    _buildSongInfo(widget.duetSongModel),
                    SizedBox(height: 32.h),
                    Expanded(
                      child: _buildLyricsField(
                        widget.duetSongModel.lyrics,
                        isSelectFirstPart
                            ? widget.duetSongModel.duetParts.first.partNumber
                            : widget.duetSongModel.duetParts.last.partNumber,
                      ),
                    ),

                    SizedBox(height: 32.h),
                    SizedBox(
                      width: 327.w,
                      height: 50.h,
                      child: CupertinoButton(
                        color: AppColors.primaryPink,
                        disabledColor: AppColors.primaryPinkDisabled,
                        borderRadius: BorderRadius.circular(10.w),
                        padding: EdgeInsets.zero,

                        onPressed: () {
                          final DuetPart selectedDuetPart =
                              (isSelectFirstPart)
                                  ? widget.duetSongModel.duetParts.first
                                  : widget.duetSongModel.duetParts.last;
                          ref
                              .read(selectedDuetSongProvider.notifier)
                              .selectedDuetSong(
                                id: widget.duetSongModel.id,
                                title: widget.duetSongModel.title,
                                artist: widget.duetSongModel.artist,
                                albumArtUrl: widget.duetSongModel.albumArtUrl,
                                voiceType: selectedDuetPart.voiceType,
                                partNumber: selectedDuetPart.partNumber,
                                partName: selectedDuetPart.partName,
                              );
                          context.pop();
                          context.pop();
                        },
                        child: Text(
                          "파트 선택하기",
                          style: AppTextStyles.body1BoldWhite, // 활성화: 굵은 흰색
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongInfo(DuetSongModel song) {
    final String totalPitchMin =
        (VoiceRangeDisplay.noteToNumber(song.duetParts.first.pitchNoteMin) <
                VoiceRangeDisplay.noteToNumber(song.duetParts.last.pitchNoteMin))
            ? song.duetParts.first.pitchNoteMin
            : song.duetParts.last.pitchNoteMin;
    final String totalPitchMax =
        (VoiceRangeDisplay.noteToNumber(song.duetParts.first.pitchNoteMax) >
                VoiceRangeDisplay.noteToNumber(song.duetParts.last.pitchNoteMax))
            ? song.duetParts.first.pitchNoteMax
            : song.duetParts.last.pitchNoteMax;

    return Column(
      children: [
        DuetSongSection(
          id: song.id,
          title: song.title,
          albumArtUrl: song.albumArtUrl,
          artist: song.artist,
          voiceType: song.duetParts.first.voiceType,
          isSelectedHost: isSelectFirstPart,
          partName: SongDetailModel.convertVoiceTypeEng2Kor(song.duetParts.last.voiceType),
          fileUrl: song.fileUrl,
        ),
        SizedBox(height: 16.h),

        VoiceRangeDisplay(
          pitchNoteMin: totalPitchMin,
          pitchNoteMax: totalPitchMax,
          themeColor: VoiceRangeColor.gray,
        ),

        SizedBox(height: 16.h),
        GestureDetector(
          onTap: () {
            setState(() {
              isSelectFirstPart = true;
            });
          },
          child: VoiceRangeDisplay(
            pitchNoteMin: song.duetParts.first.pitchNoteMin,
            pitchNoteMax: song.duetParts.first.pitchNoteMax,
            title: song.duetParts.first.partName,
            themeColor: isSelectFirstPart ? VoiceRangeColor.pink : VoiceRangeColor.gray,
          ),
        ),
        SizedBox(height: 16.h),
        GestureDetector(
          onTap: () {
            setState(() {
              isSelectFirstPart = false;
            });
          },
          child: VoiceRangeDisplay(
            pitchNoteMin: song.duetParts.last.pitchNoteMin,
            pitchNoteMax: song.duetParts.last.pitchNoteMax,
            title: song.duetParts.last.partName,
            themeColor: isSelectFirstPart ? VoiceRangeColor.gray : VoiceRangeColor.pink,
          ),
        ),
      ],
    );
  }

  Widget _buildLyricsField(List<TimedLyric> lyrics, int selectedNumber) {
    return Container(
      width: double.infinity,
      height: 400.h,
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 19.w),
      decoration: BoxDecoration(
        color: AppColors.grayscale7,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: ListView.builder(
        itemCount: lyrics.length,
        itemBuilder: (context, index) {
          final lyric = lyrics[index];
          return Text(
            lyric.text,
            style: AppTextStyles.heading4Bold.copyWith(
              color:
                  lyric.partNumber == selectedNumber ? AppColors.primaryPink : AppColors.grayscale3,
            ),
            textAlign: lyric.partNumber == 0 ? TextAlign.left : TextAlign.right,
          );
        },
      ),
    );
  }
}
