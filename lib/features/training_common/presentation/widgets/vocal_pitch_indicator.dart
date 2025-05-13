import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';

class VocalPitchIndicator extends StatefulWidget {
  // 사용자 음성을 받아 처리하는 부분: 추후 개발 필요
  const VocalPitchIndicator({super.key});

  @override
  State<VocalPitchIndicator> createState() => _VocalPitchIndicatorState();
}

class _VocalPitchIndicatorState extends State<VocalPitchIndicator> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(child: Text("pitch", style: AppTextStyles.body1)),
    );
  }
}
