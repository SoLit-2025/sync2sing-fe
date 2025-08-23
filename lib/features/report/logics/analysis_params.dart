import 'package:sync2sing/features/shared/logics/analysis_type.dart';
import 'package:sync2sing/features/shared/logics/training_mode.dart';

class AnalysisParams {
  final TrainingMode trainingMode;
  final AnalysisType analysisType;

  AnalysisParams({required this.trainingMode, required this.analysisType});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AnalysisParams &&
        other.trainingMode == trainingMode &&
        other.analysisType == analysisType;
  }

  @override
  int get hashCode => trainingMode.hashCode ^ analysisType.hashCode;
}
