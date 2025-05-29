import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';
import 'package:sync2sing/features/training_common/presentation/widgets/lyrics_display_widget.dart';
import 'package:sync2sing/features/training_common/presentation/widgets/song_information_widget.dart';
import 'package:sync2sing/features/training_common/presentation/widgets/vocal_pitch_indicator.dart';
import 'package:sync2sing/shared/providers/mic_permission_provider.dart';

import '../../../../shared/providers/audio_recorder_provider.dart';

class MusicContentPlayer extends ConsumerStatefulWidget {
  const MusicContentPlayer({super.key});

  @override
  ConsumerState<MusicContentPlayer> createState() => _MusicContentPlayerState();
}

class _MusicContentPlayerState extends ConsumerState<MusicContentPlayer> {
  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final granted = await ensureMicPermission(ref);
    if (!granted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("마이크 권한이 필요합니다.")));
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRecording = ref.watch(audioRecorderProvider);
    final recorderController = ref.read(audioRecorderProvider.notifier);
    final pitchAsync = ref.watch(pitchStreamProvider);

    pitchAsync.when(
      data: (pitchData) {
        print("flutter: Widget 수신 pitch: ${pitchData.pitch} Hz");
        return SizedBox();
      },
      loading: () => SizedBox(),
      error: (e, _) {
        print("flutter: pitchStream 에러: $e");
        return SizedBox();
      },
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SongInformationWidget(),
        // SizedBox(height: 10.h),
        LyricsSection(),
        // SizedBox(height: 15.h),
        Container(
          height: 155.h,
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
              (isRecording)
                  ? _PauseButton(
                    onPressed: () async {
                      // await pauseRecorder();
                      await recorderController.pause();
                    },
                  )
                  : _PlayButton(
                    onPressed: () async {
                      // await startOrResumeRecorder();
                      recorderController.startOrResume();
                    },
                  ),
              _KeyPlusButton(textContent: "Key +"),
            ],
          ),
        ),
      ],
      // ),
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
