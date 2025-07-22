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
import 'package:sync2sing/shared/providers/evaluated_pitch_stream_provider.dart';
import 'package:sync2sing/shared/providers/mic_permission_provider.dart';
import 'package:sync2sing/shared/providers/audio_recorder_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

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
  ConsumerState createState() => _MusicContentPlayerState();
}

class _MusicContentPlayerState extends ConsumerState<MusicContentPlayer>
    with WidgetsBindingObserver {
  late AudioPlayer _audioPlayer; // MR 재생
  bool _isPlaying = false; // MR 재생여부 확인 변수
  StreamSubscription? _positionSubscription; // 음악 재생 위치 실시간 업데이트
  Duration _totalDuration = const Duration(
    seconds: 30,
  ); // MR 길이: 30초 (doremi_song_v3_mr.wav 기준으로 수정)

  List<PitchNoteBar> _notes = []; // JSON에서 불러온 음정/박자 데이터를 저장하는 리스트
  final double _songBPM = 88.0; // 도레미송 BPM(=Beats Per Minute, 분당 박자수, 노래 속도): 임시값 88 설정
  int? _userCurrentPitch; // 사용자 현재 음정
  Timer? _pitchDetectionTimer; // 일정한 간격을 두고 음정을 감지하는 도구
  Timer? _testTimer; // 테스트용 타이머 (오디오 없이 position 시뮬레이션)

  // 위젯이 처음 실행될 때 실행되는 초기화 함수
  @override
  void initState() {
    super.initState();
    _setupAudioPlayer(); // 오디오 플레이어 초기 설정
    _loadPitchBars(); // JSON에서 음정/박자 데이터 불러오기
    // permission 확인
    // 마이크 권한 요청
    Future.microtask(() async {
      final granted = await ensureMicPermission(ref);
      if (!granted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("마이크 권한이 필요합니다")));
      }
    });

    // 앱 생명주기 옵저버: 등록
    WidgetsBinding.instance.addObserver(this);
  }

  Future<bool> ensureMicPermission(WidgetRef ref) async {
    final notifier = ref.read(micPermissionProvider.notifier);
    await notifier.checkPermission();
    if (!notifier.isGranted) {
      await notifier.requestPermission();
    }
    return notifier.isGranted;
  }

  // 오디오 플레이어 초기 설정 함수
  Future _setupAudioPlayer() async {
    _audioPlayer = AudioPlayer();
    try {
      // MR 불러오기
      await _audioPlayer.setAsset('assets/songs/audios/doremi_song_v3_mr.wav');
      debugPrint('MR 불러오기 성공');
    } catch (e) {
      debugPrint('MR 불러오기 실패: $e');
      // 더미 duration 설정
      setState(() => _totalDuration = const Duration(seconds: 30));
      debugPrint('더미 duration 설정 완료');
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

  // JSON에서 음정/박자 데이터를 불러오는 함수
  Future _loadPitchBars() async {
    try {
      // JSON 파일에서 음정/박자 데이터 불러오기
      final String jsonString = await rootBundle.loadString(
        'assets/songs/datas/doremi_song_piano_v2.json',
      );
      debugPrint('JSON 파일 로딩 성공, 길이: ${jsonString.length}');

      final List jsonData = json.decode(jsonString);
      debugPrint('JSON 파싱 성공, 데이터 개수: ${jsonData.length}');

      // MR과 음정 막대의 시간차 세부 조정을 위한 값
      const double TIME_OFFSET = 0.7;

      // JSON 데이터를 PitchNoteBar 객체 리스트로 변환 (시간 조정 포함)
      List<PitchNoteBar> rawNotes =
          jsonData.map((item) {
            final adjustedStart = ((item['start'] as num).toDouble() - TIME_OFFSET).clamp(
              0.0,
              double.infinity,
            );
            final adjustedEnd = ((item['end'] as num).toDouble() - TIME_OFFSET).clamp(
              0.0,
              double.infinity,
            );

            return PitchNoteBar(
              start: adjustedStart,
              end: adjustedEnd,
              pitch: item['pitch'] as int,
              duration: (item['duration'] as num).toDouble(),
            );
          }).toList();

      // 병합 로직 주석 처리 (doremi_song_piano_v2.json은 정확한 raw data이므로 병합 불필요)
      // List<PitchNoteBar> mergedNotes = _mergeSimilarNotes(rawNotes);

      setState(() {
        _notes = rawNotes; // 병합 없이 raw 데이터 사용
      });

      // 음정 데이터 출력
      debugPrint('음정 데이터 로드 완료 (${rawNotes.length}개):');
      for (int i = 0; i < rawNotes.length; i++) {
        debugPrint('[$i] ${rawNotes[i]}');
      }
    } catch (e) {
      debugPrint('음정 데이터 불러오기 실패: $e');
    }
  }

  // 비슷한 음정의 연속된 막대들을 하나의 긴 막대로 합치는 함수
  /*
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
          duration: nextNote.end - currentNote.start,
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
  */

  // 테스트용 타이머 시작 (오디오 없이 position 시뮬레이션)
  void _startTestTimer() {
    Duration currentPos = Duration.zero;
    _testTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      currentPos = currentPos + Duration(milliseconds: 100);
      ref.read(audioPositionProvider.notifier).state = currentPos;

      debugPrint('🎵 테스트 타이머 - 현재 위치: ${currentPos.inMilliseconds}ms');

      // 30초 후 자동 정지
      if (currentPos.inSeconds >= 30) {
        timer.cancel();
        setState(() => _isPlaying = false);
        debugPrint('테스트 재생 완료');
      }
    });
  }

  // MR 재생과 녹음을 동시에 시작/정지하는 함수
  Future _togglePlayAndRecord() async {
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

        // 오디오 재생 실패해도 테스트 타이머 시작
        _startTestTimer();
        setState(() => _isPlaying = true);
        debugPrint('오디오 없이 테스트 모드 시작');
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

    // 앱 생명주기 옵저버: 해제
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    debugPrint('MusicContentPlayer 리소스 정리 완료');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      // 앱에서 나간 경우: 만약 일시정지 x 상태라면 녹음기 종료: 다시 들어오면 위젯 재시작(부모 클래스에서).
      if (_isPlaying) {
        _audioPlayer.pause();
        ref.read(audioRecorderProvider.notifier).stop();
        setState(() {
          _isPlaying = false;
        });
        debugPrint('MR 일시정지 + 녹음 정지');
      }
    }
  }

  // UI 구성 함수
  @override
  Widget build(BuildContext context) {
    final isRecording = ref.watch(audioRecorderProvider);
    final currentPosition = ref.watch(audioPositionProvider);
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
        }
        return SizedBox();
      },
      loading: () => SizedBox(),
      error: (e, _) {
        // debugPrint("flutter: pitchStream 에러: $e");
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
                    notes: _notes, // 병합 안 된 raw 음정 데이터
                    totalDuration: _totalDuration * 0.2, // MR 전체 길이
                    // *0.1: 막대 길이 늘어남, 음정 막대가 움직이는 속도 높아짐
                    currentPosition: currentPosition, // 현재 재생 위치
                    bpm: _songBPM, // 도레미송의 BPM (임시 설정값: 88)
                    userCurrentPitch: _userCurrentPitch, // 사용자 현재 음정 (실시간 매칭용)
                    onRhythmEvaluated:
                        ref.read(audioRecorderProvider.notifier).evaluateRhythm, // 박자 채점 콜백
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
