// 원고과의 음정 정확도 차이 저장 -> 추후 리팩토링 필요 (저장되는 pitch는 frequency / 정확도 차이는 midi 값 기준 )
class EvaluatedPitch {
  final double pitch;
  final int pitchDiff;

  EvaluatedPitch({required this.pitch, required this.pitchDiff});
}
