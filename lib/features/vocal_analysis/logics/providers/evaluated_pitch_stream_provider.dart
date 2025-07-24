import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync2sing/features/vocal_analysis/logics/providers/target_pitch_provider.dart';
import '../tools/evaluated_pitch.dart';
import 'audio_recorder_provider.dart';

// stream 으로 들어오는 음정을 비교
final evaluatedPitchStreamProvider = StreamProvider.autoDispose<EvaluatedPitch>((ref) async* {
  final controller = ref.watch(audioRecorderProvider.notifier);
  // ⚠ 여기서 필요한 targetPitch를 가져온다
  final targetPitch = ref.watch(targetPitchProvider);

  while (controller.pitchStream == null) {
    await Future.delayed(const Duration(milliseconds: 50));
  }

  await for (final raw in controller.pitchStream!) {
    if (raw.pitch > 30) {
      // pitch=0 -> 사용 x
      final midiDiff = controller.evaluatePitch(_frequencyToMidi(raw.pitch), targetPitch);
      yield EvaluatedPitch(pitch: raw.pitch, pitchDiff: midiDiff);
    }
  }
});

// 주파수를 MIDI 넘버로 변환하는 함수
int _frequencyToMidi(double frequency) {
  // A4 = 440Hz = MIDI 69를 기준으로 계산
  double midiDouble = 12 * (log(frequency / 440) / log(2)) + 69;

  // 반올림하여 정수로 변환 (MIDI는 정수값만 사용)
  return midiDouble.round();
}
