import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';
import 'package:sync2sing/features/curriculum/logics/song_detail_model.dart';

class DuetSongSection extends StatefulWidget {
  final int id;
  final String title;
  final String albumArtUrl;
  final String artist;
  final String voiceType;
  final String? partName;
  final String? fileUrl;
  final bool isLeftColored;

  /// [isLeftColored]: 왼쪽 칩이 색칠되어보이는지 여부 (false: 오른쪽 위젯이 색이 더 진함)
  const DuetSongSection({
    super.key,
    this.isLeftColored = true,
    required this.id,
    required this.title,
    required this.albumArtUrl,
    required this.artist,
    required this.voiceType,
    this.partName,
    this.fileUrl,
  });
  @override
  State<DuetSongSection> createState() => _DuetSongSectionState();
}

class _DuetSongSectionState extends State<DuetSongSection> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 327.w,
      height: 80.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          (widget.fileUrl == null) // 노래 파일 있음 -> 노래 재생 가능한 위젯 (재생/중지버튼 보임)
              ? _buildAlbumArt(widget.albumArtUrl)
              : MusicPlayerCover(songFileUrl: widget.fileUrl!, albumArtUrl: widget.albumArtUrl),
          SizedBox(width: 15.w),
          Expanded(
            child: _buildSongInfoColumn(
              widget.title,
              widget.artist,
              widget.voiceType,
              widget.partName,
            ),
          ),
        ],
      ),
    );
  }

  // 앨범아트
  Widget _buildAlbumArt(String? url) {
    return Container(
      width: 80.w,
      height: 80.h,
      decoration: BoxDecoration(
        color: AppColors.primaryPinkDisabled,
        borderRadius: BorderRadius.circular(5.r),
      ),
      child:
          url != null && url.isNotEmpty
              ? ClipRRect(
                borderRadius: BorderRadius.circular(5.r),
                child: Image.network(
                  url,
                  width: 80.w,
                  height: 80.w,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildDefaultAlbumArt(),
                ),
              )
              : _buildDefaultAlbumArt(),
    );
  }

  // 기본 앨범아트
  Widget _buildDefaultAlbumArt() {
    return Center(
      child: Image.asset(
        'assets/images/default_album_art.png',
        width: 35.w,
        height: 35.h,
        fit: BoxFit.contain,
      ),
    );
  }

  // 노래 정보 = 노래 제목 + 가수 이름 + 성부 칩
  Widget _buildSongInfoColumn(String title, String artist, String voiceType, String? partName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSongInfo(title, artist),
        Row(
          children: [
            _buildVoiceTypeChip(voiceType),
            SizedBox(width: 8.w),
            if (partName != null) _buildPartNameChip(partName),
          ],
        ),
      ],
    );
  }

  // 노래 제목 & 가수 이름 로직
  Widget _buildSongInfo(String title, String artist) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          title,
          style: AppTextStyles.body1Bold.copyWith(color: AppColors.grayscale1),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          artist,
          style: AppTextStyles.body2.copyWith(color: AppColors.grayscale3),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // 성부 칩 로직
  Widget _buildVoiceTypeChip(String voiceType) {
    return Container(
      height: 20.h,
      width: 60.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: widget.isLeftColored ? AppColors.grayscale3 : AppColors.grayscale6,
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Text(
        SongDetailModel.convertVoiceTypeEng2Kor(voiceType),
        style: AppTextStyles.body6.copyWith(
          color: widget.isLeftColored ? AppColors.grayscale8 : AppColors.grayscale3,
        ),
      ),
    );
  }

  Widget _buildPartNameChip(String partName) {
    final bool isSelected = !widget.isLeftColored;
    return Container(
      height: 20.h,
      width: 70.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.grayscale3 : AppColors.grayscale6,
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Text(
        partName,
        style: AppTextStyles.body6.copyWith(
          color: isSelected ? AppColors.grayscale8 : AppColors.grayscale3,
        ),
      ),
    );
  }
}

class MusicPlayerCover extends StatefulWidget {
  final String songFileUrl;
  final String albumArtUrl;
  const MusicPlayerCover({super.key, required this.songFileUrl, required this.albumArtUrl});

  @override
  State<MusicPlayerCover> createState() => _MusicPlayerCoverState();
}

class _MusicPlayerCoverState extends State<MusicPlayerCover> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late StreamSubscription<PlayerState> _playerStateSub;
  bool isPlaying = false;
  bool isEnded = false;

  @override
  void initState() {
    super.initState();

    // 플레이어 상태 스트림 구독
    _playerStateSub = _audioPlayer.playerStateStream.listen((state) async {
      final ended = state.processingState == ProcessingState.completed;
      if (ended) {
        await _audioPlayer.pause();
        await _audioPlayer.setUrl(widget.songFileUrl);
      }
      setState(() {
        isPlaying = state.playing && !ended;
        isEnded = ended;
      });
    });
    try {
      if (!widget.songFileUrl.startsWith('assets')) {
        _audioPlayer.setUrl(widget.songFileUrl);
      } else {
        _audioPlayer.setAsset(widget.songFileUrl);
      }
    } catch (e) {
      debugPrint(e as String?);
    }
  }

  @override
  void dispose() {
    _playerStateSub.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playMusic() {
    _audioPlayer.play();
  }

  void _pauseMusic() {
    _audioPlayer.pause();
    _audioPlayer.playerState;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(5.r),
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              AppColors.grayscale8.withValues(alpha: 0.5),
              BlendMode.srcATop,
            ),
            child: _buildAlbumArt(widget.albumArtUrl),
          ),
        ),

        GestureDetector(
          onTap: isPlaying ? _pauseMusic : _playMusic,
          child: Image.asset(
            isPlaying ? "assets/images/pause.png" : "assets/images/play.png",
            color: AppColors.primaryPink,
          ),
        ),
      ],
    );
  }

  // 앨범아트
  Widget _buildAlbumArt(String? url) {
    return Container(
      width: 80.w,
      height: 80.h,
      decoration: BoxDecoration(
        color: AppColors.primaryPinkDisabled,
        borderRadius: BorderRadius.circular(5.r),
      ),
      child:
          url != null && url.isNotEmpty
              ? ClipRRect(
                borderRadius: BorderRadius.circular(5.r),
                child: Image.network(
                  url,
                  width: 80.w,
                  height: 80.w,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildDefaultAlbumArt(),
                ),
              )
              : _buildDefaultAlbumArt(),
    );
  }

  // 기본 앨범아트
  Widget _buildDefaultAlbumArt() {
    return Center(
      child: Image.asset(
        'assets/images/default_album_art.png',
        width: 35.w,
        height: 35.h,
        fit: BoxFit.contain,
      ),
    );
  }
}
