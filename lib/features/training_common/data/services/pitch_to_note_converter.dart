import 'dart:math';

// 주파수(Hz)를 노트명(=음명)으로 변환
class PitchToNoteConverter {
  // Hz(주파수)를 노트명으로 변환
  String hzToNote(double hz) {
    if (hz <= 0) return '';
    // STEP1. 주파수를 MIDI 넘버로 계산
    final midi = (12 * (log(hz / 440.0) / ln2) + 69).round();
    // 노트명 배열
    const noteNames = [
      'C', 'C#', 'D', 'D#', 'E', 'F',
      'F#', 'G', 'G#', 'A', 'A#', 'B'
    ];
    // STEP2. MIDI 넘버를 노트명과 옥타브로 변환
    final note = noteNames[midi % 12];
    final octave = (midi ~/ 12) - 1;
    // STEP3. 변환된 노트명 반환
    return '$note$octave';
  }
}
