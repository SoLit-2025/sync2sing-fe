import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';

import '../../../../shared/providers/audio_recorder_provider.dart';

class VocalPitchIndicator extends ConsumerStatefulWidget {
  // 사용자 음성을 받아 처리하는 부분: 추후 개발 필요
  const VocalPitchIndicator({super.key});

  @override
  ConsumerState<VocalPitchIndicator> createState() =>
      _VocalPitchIndicatorState();
}

class _VocalPitchIndicatorState extends ConsumerState<VocalPitchIndicator> {
  @override
  Widget build(BuildContext context) {
    double _currentPitch = 0;
    final pitchAsync = ref.watch(pitchStreamProvider);
    pitchAsync.when(
      data: (pitchData) {
        setState(() {
          _currentPitch = pitchData.pitch;
        });
        return SizedBox();
      },
      loading: () => SizedBox(),
      error: (e, _) {
        print("flutter: pitchStream 에러: $e");
        return SizedBox();
      },
    );

    return Container(
      child: Center(
        child: Text(_currentPitch.toString(), style: AppTextStyles.body1),
      ),
    );
  }
}
