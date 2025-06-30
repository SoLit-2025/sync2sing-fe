import 'dart:math';

class _VocalRange {
  final String name;
  final int min;
  final int max;

  const _VocalRange({required this.name, required this.min, required this.max});
}

// 최대/최소/ 평균 음정 (주파수)을 토대로 VoiceType을 결정
String determineVoiceType(double lowestHz, double highestHz, double averageHz) {
  // 주파수를 MIDI 값으로 변환하는 함수
  double frequencyToMidi(double freq) {
    if (freq <= 0) return 0; // 주파수 오류 방지
    return 69 + 12 * (log(freq / 440) / ln2);
  }

  // MIDI 값 반올림 (소수점 음표 처리)
  int midiNote(double freq) => frequencyToMidi(freq).round();

  // 성부별 MIDI 범위
  const vocalRanges = [
    _VocalRange(name: 'Bass', min: 40, max: 64),
    _VocalRange(name: 'Baritone', min: 43, max: 67),
    _VocalRange(name: 'Tenor', min: 48, max: 72),
    _VocalRange(name: 'Alto', min: 53, max: 77),
    _VocalRange(name: 'Mezzo-Soprano', min: 57, max: 81),
    _VocalRange(name: 'Soprano', min: 60, max: 84),
  ];

  final lowestMidi = midiNote(lowestHz);
  final highestMidi = midiNote(highestHz);
  final avgMidi = midiNote(averageHz);

  // [1단계] 최저/최고 음을 완전히 포함하는 성부 검사
  final fullyContained =
      vocalRanges.where((vt) => lowestMidi >= vt.min && highestMidi <= vt.max).toList();

  // 최저/최고 음정 안에 포함되는 음역대가 하나라면 바로 그것을 반환
  if (fullyContained.length == 1) {
    return fullyContained.first.name;
  }

  // [2단계] 평균 음정이 포함되는 성부 검사
  final avgContained = vocalRanges.where((vt) => avgMidi >= vt.min && avgMidi <= vt.max).toList();

  if (avgContained.length == 1) {
    return avgContained.first.name;
  }

  // [3단계] 평균 음정과 가장 최고/최저의 중간값이 비슷한 성부 선택
  return vocalRanges.reduce((a, b) {
    final aMid = (a.min + a.max) / 2;
    final bMid = (b.min + b.max) / 2;
    final aDiff = (avgMidi - aMid).abs();
    final bDiff = (avgMidi - bMid).abs();
    return aDiff < bDiff ? a : b;
  }).name;
}
