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
    final pitchAsyncValue = ref.watch(pitchStreamProvider);

    return Container(
      child: Center(child: Text("pitch", style: AppTextStyles.body1)),
    );
  }
}
