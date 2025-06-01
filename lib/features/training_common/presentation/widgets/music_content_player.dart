import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';
import 'package:sync2sing/features/training_common/presentation/widgets/lyrics_display_widget.dart';
import 'package:sync2sing/features/training_common/presentation/widgets/song_information_widget.dart';
import 'package:sync2sing/features/training_common/presentation/widgets/pitch_and_rhythm_bar.dart';
import 'package:sync2sing/shared/providers/audio_position_provider.dart';
import '../../../../shared/providers/audio_recorder_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

// 음악 재생 및 녹음 기능
class MusicContentPlayer extends ConsumerStatefulWidget {
  const MusicContentPlayer({super.key});

  @override
  ConsumerState<MusicContentPlayer> createState() => _MusicContentPlayerState();
}

class _MusicContentPlayerState extends ConsumerState<MusicContentPlayer> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  StreamSubscription<Duration>? _positionSubscription;
  Duration _totalDuration = const Duration(seconds: 104); // MR 길이
  List<PitchNoteBar> _notes = [];

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
    _loadPitchBars();
  }

  // MR 파일 로드 및 재생 위치 Provider 연동
  Future<void> _setupAudioPlayer() async {
    _audioPlayer = AudioPlayer();
    try {
      await _audioPlayer.setAsset('assets/songs/audios/do_re_mi_song_mr_only_no_intro_104sec.wav');
      print('MR setAsset 성공');
    } catch (e) {
      print('MR setAsset 실패: $e');
      return; // setAsset 실패 시 이후 코드 실행 방지
    }
    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        setState(() {
          _totalDuration = duration;
        });
      }
    });
    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      print('AUDIO POSITION: $position');
      ref.read(audioPositionProvider.notifier).state = position;
    });
    _audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        setState(() => _isPlaying = false);
        _audioPlayer.seek(Duration.zero);
        ref.read(audioRecorderProvider.notifier).pause();
      }
    });
  }

  // 음정/박자 데이터 JSON 로드
  Future<void> _loadPitchBars() async {
    final String jsonString = await rootBundle.loadString('assets/songs/datas/do_re_mi_song.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    setState(() {
      _notes = jsonData.map((item) => PitchNoteBar(
        start: (item['start'] as num).toDouble(),
        end: (item['end'] as num).toDouble(),
        pitch: item['pitch'] as int,
        rhythm: item['rhythm'] as String,
      )).toList();
    });
  }

  // MR 재생과 녹음 동시 시작/정지
  Future<void> _togglePlayAndRecord() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      ref.read(audioRecorderProvider.notifier).pause();
      setState(() => _isPlaying = false);
    } else {
      try {
        await _audioPlayer.play();
        print('MR play() 성공');
        ref.read(audioRecorderProvider.notifier).startOrResume();
        setState(() => _isPlaying = true);
      } catch (e) {
        print('MR play() 실패: $e');
        // play 실패 시 녹음 시작/상태 변경 안 함
      }
      ref.read(audioRecorderProvider.notifier).startOrResume();
      setState(() => _isPlaying = true);
    }
  }

  void _decreaseKey() {
    // TODO: 음정을 반음 낮추는 기능 구현
    print('키 내리기 기능 실행');
  }

  void _increaseKey() {
    // TODO: 음정을 반음 올리는 기능 구현
    print('키 올리기 기능 실행');
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRecording = ref.watch(audioRecorderProvider);
    final currentPosition = ref.watch(audioPositionProvider);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SongInformationWidget(),
        LyricsSection(),
        Container(
          height: 155.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadiusDirectional.circular(10.r),
            color: AppColors.grayscale7,
          ),
          child: _notes.isEmpty
              ? Center(child: CircularProgressIndicator())
              : PitchAndRhythmBar(
            notes: _notes,
            totalDuration: _totalDuration,
            currentPosition: currentPosition,
          ),
        ),
        SizedBox(height: 20.h),
        SizedBox(
          width: double.infinity,
          height: 42.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _KeyControlButton(
                textContent: "Key -",
                onPressed: _decreaseKey,
              ),
              (isRecording || _isPlaying)
                  ? _PauseButton(
                onPressed: _togglePlayAndRecord,
              )
                  : _PlayButton(
                onPressed: _togglePlayAndRecord,
              ),
              _KeyControlButton(
                textContent: "Key +",
                onPressed: _increaseKey,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 재생 버튼 위젯
class _PlayButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _PlayButton({required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.all(0),
      onPressed: onPressed,
      minimumSize: Size(0.0, 0.0),
      child: ImageIcon(
        AssetImage("assets/images/play.png"),
        color: AppColors.grayscale3,
        size: 20.w,
      ),
    );
  }
}

/// 일시정지 버튼 위젯
class _PauseButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _PauseButton({required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.all(0),
      onPressed: onPressed,
      minimumSize: Size(0.0, 0.0),
      child: ImageIcon(
        AssetImage("assets/images/pause.png"),
        color: AppColors.grayscale3,
        size: 20.w,
      ),
    );
  }
}

/// 키 조절 버튼 위젯 (Key +, Key -)
class _KeyControlButton extends StatelessWidget {
  final String textContent;
  final VoidCallback onPressed;
  const _KeyControlButton({
    required this.textContent,
    required this.onPressed,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 98.w,
      height: 42.h,
      child: CupertinoButton(
        padding: EdgeInsets.all(0),
        onPressed: onPressed,
        borderRadius: BorderRadius.circular(10.r),
        color: AppColors.grayscale5,
        minimumSize: Size(0.0, 0.0),
        child: Text(
          textContent,
          textAlign: TextAlign.center,
          style: AppTextStyles.body1Bold.copyWith(
            color: AppColors.grayscale3,
          ),
        ),
      ),
    );
  }
}
