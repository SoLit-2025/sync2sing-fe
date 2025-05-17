import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';
import 'package:sync2sing/features/training_common/presentation/widgets/lyrics_display_widget.dart';
import 'package:sync2sing/features/training_common/presentation/widgets/song_information_widget.dart';
import 'package:sync2sing/features/training_common/presentation/widgets/vocal_pitch_indicator.dart';
// import 'package:sync2sing/shared/providers/audio_stream_recorder_provider.dart';
import 'package:sync2sing/shared/providers/mic_permission_provider.dart';
import 'package:sync2sing/shared/utils/audio_stream_recorder.dart';

class MusicContentPlayer extends ConsumerStatefulWidget {
  const MusicContentPlayer({super.key});

  @override
  ConsumerState<MusicContentPlayer> createState() => _MusicContentPlayerState();
}

class _MusicContentPlayerState extends ConsumerState<MusicContentPlayer> {
  bool _isRecording = false;
  String? recordedFilePath;
  final AudioStreamRecorder _audioRecorder = AudioStreamRecorder();

  // final audioRecorderProvider =
  //     StateNotifierProvider<AudioRecorderController, AudioState>(
  //       (ref) => AudioRecorderController(),
  //     );

  @override
  void initState() {
    super.initState();
    _audioRecorder.init();
    // Future.microtask(() {
    //   // ref.read(audioStreamRecorderProvider.notifier).init();
    // });
    print("flutter jhj : initState");
  }

  @override
  void dispose() {
    // print("flutter jhj : dispose");
    if (_audioRecorder.isRecording) {
      // 문제: 중지 버튼을 누르지 않고 바로 '보컬 분석 리포트 생성' 버튼을 눌러야 함. --> 수정 필요
      _audioRecorder.stopRecording();
      _audioRecorder.saveToFile(fileName: "guest_recording_file");
      // print("flutter jhj :- saveTofile");
    }
    super.dispose();
  }

  void _onPlayPressed() async {
    final granted = await ensureMicPermission(ref); // 권한 확인

    if (!granted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("마이크 권한이 필요합니다.")));
      return;
    } else {
      print("jhj - 퍼미션 허락 받음");
    }

    await _audioRecorder.startRecording(); // 녹음 시작

    setState(() {
      _isRecording = true;
    });
  }

  void _onPausePressed() {
    _audioRecorder.stopRecording();
    setState(() {
      _isRecording = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // final isRecording = ref.watch(audioStreamRecorderProvider);
    // final recorderNotifier = ref.read(audioStreamRecorderProvider.notifier);

    return Column(
      // 기존 레이아웃 그대로 유지
      children: [
        SongInformationWidget(),
        SizedBox(height: 10.h),
        LyricsSection(),
        SizedBox(height: 15.h),
        Container(
          width: double.infinity,
          height: 155.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadiusDirectional.circular(10.r),
            color: AppColors.grayscale7,
          ),
          child: VocalPitchIndicator(),
        ),
        SizedBox(height: 20.h),
        SizedBox(
          width: double.infinity,
          height: 42.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _KeyMinusButton(textContent: "Key -"),
              _isRecording
                  ? _PauseButton(onPressed: _onPausePressed)
                  : _PlayButton(onPressed: _onPlayPressed),
              _KeyPlusButton(textContent: "Key +"),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlayButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _PlayButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      minSize: 0.0,
      padding: EdgeInsets.all(0),
      child: ImageIcon(
        AssetImage("assets/images/play.png"),
        color: AppColors.grayscale3,
        size: 20.w,
      ),
      onPressed: onPressed,
    );
  }
}

class _PauseButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _PauseButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      minSize: 0.0,
      padding: EdgeInsets.all(0),
      child: ImageIcon(
        AssetImage("assets/images/pause.png"),
        color: AppColors.grayscale3,
        size: 20.w,
      ),
      onPressed: onPressed,
    );
  }
}

class _KeyControlButton extends StatelessWidget {
  final String textContent;

  const _KeyControlButton({super.key, required this.textContent});

  bool isEnabled() {
    // TODO 버튼 활성화 조건
    return true;
  }

  void performAction() {}

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 98.w,
      height: 42.h,
      child: CupertinoButton(
        minSize: 0.0,
        padding: EdgeInsets.all(0),
        onPressed: (isEnabled()) ? performAction : null,
        borderRadius: BorderRadius.circular(10.r),
        color: AppColors.grayscale5,
        child: Text(
          textContent,
          textAlign: TextAlign.center,
          style:
              isEnabled()
                  ? AppTextStyles.body1Bold.copyWith(
                    color: AppColors.grayscale3,
                  )
                  : AppTextStyles.body1.copyWith(color: AppColors.grayscale3),
        ),
      ),
    );
  }
}

class _KeyMinusButton extends _KeyControlButton {
  _KeyMinusButton({required super.textContent});

  @override
  void performAction() {
    // TODO: 키 내리기
    super.performAction();
  }
}

class _KeyPlusButton extends _KeyControlButton {
  _KeyPlusButton({required super.textContent});

  @override
  void performAction() {
    // TODO: 키 올리기
    super.performAction();
  }
}

Future<bool> ensureMicPermission(WidgetRef ref) async {
  final notifier = ref.read(micPermissionProvider.notifier);

  await notifier.checkPermission();
  if (!notifier.isGranted) {
    await notifier.requestPermission();
  }

  return notifier.isGranted;
}
