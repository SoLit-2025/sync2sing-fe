import 'package:sync2sing/features/shared/logics/training_mode.dart';

import 'training_grade.dart';

class CurriculumGenerationRequest {
  // 커리큘럼 생성 api request body 용 객체.
  final TrainingMode trainingMode;
  final TrainingGrade pitch;
  final TrainingGrade rhythm;
  final TrainingGrade pronunciation;
  final int trainingDays;

  CurriculumGenerationRequest({
    required this.trainingMode,
    required this.pitch,
    required this.rhythm,
    required this.pronunciation,
    required this.trainingDays,
  });

  factory CurriculumGenerationRequest.fromJson(Map<String, dynamic> json) {
    return CurriculumGenerationRequest(
      trainingMode: json['training_mode'],
      pitch: json['pitch'],
      rhythm: json['rhythm'],
      pronunciation: json['pronunciation'],
      trainingDays: json['training_days'],
    );
  }

  Map<String, dynamic> toUpperJson() {
    // 대문자 형태로 변환해 json으로 만듦.
    return {
      "training_mode": trainingMode.name.toUpperCase(),
      "pitch": pitch.name.toUpperCase(),
      "rhythm": rhythm.name.toUpperCase(),
      "pronunciation": pronunciation.name.toUpperCase(),
      "training_days": trainingDays,
    };
  }
}
