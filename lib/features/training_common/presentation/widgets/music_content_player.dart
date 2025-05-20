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
import 'package:sync2sing/shared/providers/audio_stream_recorder_notifier.dart';
import 'package:sync2sing/shared/providers/mic_permission_provider.dart';

class MusicContentPlayer extends ConsumerStatefulWidget {
  const MusicContentPlayer({super.key});

  @override
  ConsumerState<MusicContentPlayer> createState() => _MusicContentPlayerState();
}

class _MusicContentPlayerState extends ConsumerState<MusicContentPlayer> {
  @override
  Widget build(BuildContext context) {
    final isRecording = ref.watch(audioStreamRecorderProvider);
    final recorder = ref.read(audioStreamRecorderProvider.notifier);

    return Column(
      children: [
        SongInformationWidget(),
        LyricsSection(),
        Container(
          height: 155,
          color: Colors.grey.shade300,
          child: VocalPitchIndicator(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _KeyMinusButton(textContent: "Key -"),
            isRecording
                ? _PauseButton(
                  onPressed: () async {
                    await recorder.pause();
                  },
                )
                : _PlayButton(
                  onPressed: () async {
                    final granted = await ensureMicPermission(ref);
                    if (!granted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text("마이크 권한이 필요합니다.")));
                      return;
                    }

                    await recorder.startOrResume();
                  },
                ),
            _KeyPlusButton(textContent: "Key +"),
          ],
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
