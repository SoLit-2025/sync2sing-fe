import 'package:sync2sing/features/shared/logics/analysis_type.dart';
import 'package:sync2sing/features/shared/logics/training_mode.dart';

class AnalysisParams {
  final TrainingMode trainingMode;
  final AnalysisType analysisType;
  final int? roomId;

  AnalysisParams({required this.trainingMode, required this.analysisType, this.roomId});

  // riverpod family 사용을 위한 함수 추가:
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true; // 메모리 상에서 동일한 인스턴스이면

    return other is AnalysisParams &&
        other.trainingMode == trainingMode &&
        other.analysisType == analysisType &&
        other.roomId == roomId;
  }

  @override
  int get hashCode => Object.hash(trainingMode, analysisType, roomId);
}
