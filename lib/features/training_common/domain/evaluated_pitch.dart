class EvaluatedPitch {
  final double pitch;
  final bool isCorrect;
  static const int tolerance = 5; // 맞는 것으로 인정하는 음정 범위 (차)

  EvaluatedPitch({required this.pitch, required this.isCorrect});
}
