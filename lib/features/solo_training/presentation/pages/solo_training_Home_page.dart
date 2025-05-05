import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';

class SoloTrainingHomePage extends StatelessWidget {
  const SoloTrainingHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("SoloTrainingHomePage", style: AppTextStyles.display1),
      ),
    );
  }
}
