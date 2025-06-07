import 'dart:async';
import 'dart:convert';
import 'dart:math';
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

import '../../domain/evaluated_pitch.dart';

// 음악 재생 및 녹음 기능을 담당하는 위젯
// 기능
// 1. 도레미송 MR 재생/일시정지
// 2. 사용자 음성 녹음 (MR 재생과 동시 진행)
// 3. 음정/박자 막대 표시
// 4. 사용자 음정 감지: 사용자가 정확한 음정으로 부르는지 확인
// 5. MR 키 조절: 추후 구현 예정
// 6. BPM 기반 막대 이동속도 조절
class MusicContentPlayer extends ConsumerStatefulWidget {
  const MusicContentPlayer({super.key});

  @override
  ConsumerState<MusicContentPlayer> createState() => _MusicContentPlayerState();
}

class _MusicContentPlayerState extends ConsumerState<MusicContentPlayer> {
  // MR 재생
  late AudioPlayer _audioPlayer;

  // MR 재생여부 확인 변수
  bool _isPlaying = false;

  // 음악 재생 위치 실시간 업데이트
  StreamSubscription<Duration>? _positionSubscription;

  // MR 길이: 104초
  Duration _totalDuration = const Duration(seconds: 104); // 104

  // JSON에서 불러온 음정/박자 데이터를 저장하는 리스트
  List<PitchNoteBar> _notes = [];

  final double _songBPM = 88.0; // 도레미송 BPM(=Beats Per Minute, 분당 박자수, 노래 속도): 임시값 140 설정
  int? _userCurrentPitch; // 사용자 현재 음정
  Timer? _pitchDetectionTimer; // 일정한 간격을 두고 음정을 감지하는 도구

  bool _hasListened = false;

  // 위젯이 처음 실행될 때 실행되는 초기화 함수
  @override
  void initState() {
    super.initState();
    _setupAudioPlayer(); // 오디오 플레이어 초기 설정
    _loadPitchBars(); // JSON에서 음정/박자 데이터 불러오기
  }

  // 오디오 플레이어 초기 설정 함수
  Future<void> _setupAudioPlayer() async {
    _audioPlayer = AudioPlayer();

    try {
      // MR 불러오기
      await _audioPlayer.setAsset('assets/songs/audios/do_re_mi_song_mr_only_no_intro_104sec.wav');
      debugPrint('MR 불러오기 성공');
    } catch (e) {
      debugPrint('MR 불러오기 실패: $e');
      return; // 파일 불러오기 실패 시 이후 코드 실행 X
    }

    // MR 재생시간 계산하기
    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        setState(() => _totalDuration = duration);
        debugPrint('MR 재생시간: ${duration.inSeconds}초');
      }
    });

    // MR 재생 위치가 바뀔 때마다 실시간으로 Provider에 값을 전달
    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      ref.read(audioPositionProvider.notifier).state = position;
    });

    // MR 재생이 끝나면 자동으로 처음으로 돌아간 뒤 일시정지
    _audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        setState(() => _isPlaying = false);
        _audioPlayer.seek(Duration.zero); // 처음으로 돌아가기
        ref.read(audioRecorderProvider.notifier).pause(); // 녹음 정지
        debugPrint('MR 재생 완료, 처음으로 돌아감');
      }
    });
  }

  // 주파수를 MIDI 넘버로 변환하는 함수
  int _frequencyToMidi(double frequency) {
    // A4 = 440Hz = MIDI 69를 기준으로 계산
    double midiDouble = 12 * (log(frequency / 440) / log(2)) + 69;

    // 반올림하여 정수로 변환 (MIDI는 정수값만 사용)
    return midiDouble.round();
  }

  // JSON에서 음정/박자 데이터를 불러온 뒤 정규화(=비슷한 음정을 가진 데이터를 하나의 긴 막대로 병합)를 요청하는 함수
  Future<void> _loadPitchBars() async {
    try {
      // JSON 파일에서 음정/박자 데이터 불러오기
      final String jsonString = await rootBundle.loadString(
        'assets/songs/datas/do_re_mi_song.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);

      // JSON 데이터를 PitchNoteBar 객체 리스트로 변환
      List<PitchNoteBar> rawNotes =
          jsonData
              .map(
                (item) => PitchNoteBar(
                  start: (item['start'] as num).toDouble(),
                  end: (item['end'] as num).toDouble(),
                  pitch: item['pitch'] as int,
                  rhythm: item['rhythm'] as String,
                ),
              )
              .toList();

      // 비슷한 음정을 가진 막대를 하나의 긴 막대로 병합
      List<PitchNoteBar> mergedNotes = _mergeSimilarNotes(rawNotes);

      // debugPrint("$")

      setState(() {
        _notes = mergedNotes;
      });

      // 🔽 추가할 디버그 출력
      debugPrint('병합된 음정 데이터 (${mergedNotes.length}개):');
      for (int i = 0; i < mergedNotes.length; i++) {
        debugPrint('[$i] ${mergedNotes[i]}');
      }
    } catch (e) {
      debugPrint('음정 데이터 불러오기 실패: $e');
    }
  }

  // 비슷한 음정의 연속된 막대들을 하나의 긴 막대로 합치는 함수
  List<PitchNoteBar> _mergeSimilarNotes(List<PitchNoteBar> originalNotes) {
    if (originalNotes.isEmpty) return [];

    List<PitchNoteBar> mergedNotes = [];
    PitchNoteBar currentNote = originalNotes.first;

    for (int i = 1; i < originalNotes.length; i++) {
      final nextNote = originalNotes[i];

      // 음정 차이 3: 약 2옥타브 차이까지 하나의 막대로 취급
      // 시간 간격 0.5초: 5초 이내의 간격이면 하나의 막대로 취급
      bool shouldMerge =
          (nextNote.pitch - currentNote.pitch).abs() <= 3 &&
          nextNote.start - currentNote.end <= 0.5;

      if (shouldMerge) {
        // 현재 막대를 연장 (끝 시간을 다음 막대의 끝 시간으로 업데이트)
        currentNote = PitchNoteBar(
          start: currentNote.start,
          end: nextNote.end,
          pitch: currentNote.pitch, // 첫 번째 음정 유지
          rhythm: currentNote.rhythm,
        );
      } else {
        // 현재 막대를 완성하고 새 막대 시작
        mergedNotes.add(currentNote);
        currentNote = nextNote;
      }
    }

    // 마지막 막대 추가
    mergedNotes.add(currentNote);

    // 너무 짧은 막대들은 시각적으로 의미가 없으므로 제거: 2.0초 미만
    return mergedNotes.where((note) => note.end - note.start >= 0.5).toList();
  }

  // MR 재생과 녹음을 동시에 시작/정지하는 함수
  Future<void> _togglePlayAndRecord() async {
    if (_isPlaying) {
      // 현재 재생 중이면 일시정지

      _audioPlayer.pause();
      await ref.read(audioRecorderProvider.notifier).pause();
      setState(() => _isPlaying = false);
      debugPrint('MR 일시정지 + 녹음 정지');
    } else {
      // 현재 일시정지 상태면 재생 + 녹음 시작
      try {
        _audioPlayer.play();
        await ref.read(audioRecorderProvider.notifier).startOrResume();
        setState(() => _isPlaying = true);
        debugPrint('MR 재생 + 녹음 시작');
      } catch (e) {
        debugPrint('MR 재생 실패: $e');
        // play 실패 시 녹음 시작/상태 변경 X
      }
    }
  }

  // 키 내리기 기능: 추후 구현 예정
  void _decreaseKey() => debugPrint('키 내리기 기능 실행');

  // 키 올리기 기능: 추후 구현 예정
  void _increaseKey() => debugPrint('키 올리기 기능 실행');

  @override
  void dispose() {
    _positionSubscription?.cancel(); // 재생 위치 스트림 구독 해제
    _pitchDetectionTimer?.cancel(); // 음정 감지 타이머 해제
    _audioPlayer.dispose(); // 오디오 플레이어 해제
    super.dispose();
    debugPrint('MusicContentPlayer 리소스 정리 완료');
  }

  // UI 구성 함수
  @override
  Widget build(BuildContext context) {
    if (!_hasListened) {
      _hasListened = true; // 단 한 번만 실행
      ref.listen<AsyncValue<EvaluatedPitch>>(evaluatedPitchStreamProvider, (prev, next) {
        next.whenData((evaluatedPitch) {
          final controller = ref.read(audioRecorderProvider.notifier);
          controller.onPitchEvaluated(evaluatedPitch); //  실시간으로 음정 비교 -> bool list에 더함
        });
      });
    }

    final isRecording = ref.watch(audioRecorderProvider);
    final currentPosition = ref.watch(audioPositionProvider);
    // final pitchAsync = ref.watch(pitchStreamProvider);
    final pitchAsync = ref.watch(evaluatedPitchStreamProvider);
    pitchAsync.when(
      data: (pitchData) {
        if (isRecording) {
          setState(() {
            if (pitchData.pitch < 30) {
              // 음정이 탐지되지 않은 경우로, 가짜 데이터 넘겨받음 --> 현재 음정: null
              _userCurrentPitch = null;
            } else {
              // 음정이 탐지된 경우, 현재 음정 업데이트
              _userCurrentPitch = _frequencyToMidi(pitchData.pitch);
            }
          });
          return SizedBox();
        }
      },
      loading: () => SizedBox(),
      error: (e, _) {
        // debugPrint("flutter: pitchStream 에러: $e");
        // return SizedBox();
      },
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 곡 정보 표시
        SongInformationWidget(),

        // 가사 표시
        LyricsSection(),

        // 음정/박자 막대 표시
        Container(
          height: 155.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadiusDirectional.circular(10.r),
            color: AppColors.grayscale7,
          ),
          child:
              _notes.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : PitchAndRhythmBar(
                    notes: _notes, // 병합된 음정 데이터
                    totalDuration: _totalDuration * 0.1, // MR 전체 길이
                    //  *0.1: 막대 길이 늘어남, 음정 막대가 움직이는 속도 높아짐
                    currentPosition: currentPosition, // 현재 재생 위치
                    bpm: _songBPM, // 도레미송의 BPM (임시 설정값: 140)
                    userCurrentPitch: _userCurrentPitch, // 사용자 현재 음정 (실시간 매칭용)
                  ),
        ),

        SizedBox(height: 20.h),

        // 키 조절, 재생/일시정지 버튼 표시
        SizedBox(
          width: double.infinity,
          height: 42.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _KeyControlButton(textContent: "Key -", onPressed: _decreaseKey),
              // 재생/일시정지 버튼: 상태에 따라 다른 버튼 표시
              (isRecording || _isPlaying)
                  ? _PauseButton(onPressed: _togglePlayAndRecord)
                  : _PlayButton(onPressed: _togglePlayAndRecord),
              _KeyControlButton(textContent: "Key +", onPressed: _increaseKey),
            ],
          ),
        ),
      ],
    );
  }
}

// 재생 버튼 위젯
class _PlayButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _PlayButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      minSize: 0.0,
      child: ImageIcon(
        AssetImage("assets/images/play.png"),
        color: AppColors.grayscale3,
        size: 20.w,
      ),
    );
  }
}

// 일시정지 버튼 위젯
class _PauseButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _PauseButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      minSize: 0.0,
      child: ImageIcon(
        AssetImage("assets/images/pause.png"),
        color: AppColors.grayscale3,
        size: 20.w,
      ),
    );
  }
}

// 키 조절 버튼 위젯: 추후 구현 예정
class _KeyControlButton extends StatelessWidget {
  final String textContent;
  final VoidCallback onPressed;
  const _KeyControlButton({required this.textContent, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 98.w,
      height: 42.h,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        borderRadius: BorderRadius.circular(10.r),
        color: AppColors.grayscale5,
        minSize: 0.0,
        child: Text(
          textContent,
          textAlign: TextAlign.center,
          style: AppTextStyles.body1Bold.copyWith(color: AppColors.grayscale3),
        ),
      ),
    );
  }
}
