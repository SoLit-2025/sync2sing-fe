import 'package:flutter/material.dart';
import 'package:sync2sing/features/shared/logics/analysis_type.dart';
import 'package:sync2sing/features/shared/logics/training_mode.dart';

class SongExampleVideoPage extends StatelessWidget {
  final TrainingMode trainingMode;
  final AnalysisType analysisType;
  final int songId;
  const SongExampleVideoPage({
    super.key,
    required this.trainingMode,
    required this.analysisType,
    required this.songId,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint("${trainingMode.name} | ${trainingMode.apiValue} | $songId");
    return Scaffold(
      body: Center(child: Text("SongExampleVideoPage - $trainingMode / $analysisType | $songId")),
    );
  }
}
