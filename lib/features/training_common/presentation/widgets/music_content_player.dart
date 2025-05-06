import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';
import 'package:sync2sing/features/training_common/presentation/widgets/lyrics_display_widget.dart';
import 'package:sync2sing/features/training_common/presentation/widgets/song_information_widget.dart';
import 'package:sync2sing/features/training_common/presentation/widgets/vocal_pitch_indicator.dart';

class MusicContentPlayer extends StatelessWidget {
  const MusicContentPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
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
            color: AppColors.neutralGhost,
          ),
          child: VocalPitchIndicator(),
        ),
        SizedBox(height: 20.h),
        SizedBox(
          width: double.infinity,
          height: 42.w,
          child: Row(
            // 키 조절 버튼 및 재생/멈춤 버튼
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _KeyMinusButton(textContent: "Key -"),
              _playButton(),
              _KeyPlusButton(textContent: "Key +"),
            ],
          ),
        ),
      ],
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
        color: AppColors.neutralLightGray,
        child: Text(
          textContent,
          textAlign: TextAlign.center,
          style:
              isEnabled()
                  ? AppTextStyles.body1Bold.copyWith(
                    color: AppColors.neutralGray,
                  )
                  : AppTextStyles.body1.copyWith(color: AppColors.neutralGray),
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

class _playButton extends StatelessWidget {
  const _playButton({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      minSize: 0.0,
      padding: EdgeInsets.all(0),
      child: ImageIcon(
        AssetImage("assets/images/play.png"),
        color: AppColors.neutralGray,
        size: 20.w,
      ),
      onPressed: () {
        // TODO 재생
      },
    );
  }
}

class _pauseButton extends StatelessWidget {
  const _pauseButton({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      minSize: 0.0,
      padding: EdgeInsets.all(0),
      child: ImageIcon(
        AssetImage("assets/images/pause.png"),
        color: AppColors.neutralGray,
        size: 20.w,
      ),
      onPressed: () {},
      // TODO 멈춤 기능
    );
  }
}
