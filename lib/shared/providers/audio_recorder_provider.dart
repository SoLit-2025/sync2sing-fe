import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync2sing/shared/providers/target_pitch_provider.dart';
import '../../features/training_common/data/services/audio_stream_recorder.dart';
import '../../features/training_common/domain/evaluated_pitch.dart';
import '../../features/training_common/presentation/controller/audio_recorder_controller.dart';

// recordindg_song_page / music_content_widget 에 사용될 Provider -> 이름 바뀔 수도 있음
// 파일 저장 / 음정 탐지 / 박자 분석(아마) 수행
final audioRecorderProvider = StateNotifierProvider<AudioRecorderController, bool>((ref) {
  final streamRecorder = AudioStreamRecorder(
    isFileSave: true,
    isPitchDetection: true,
    isRhythmDetection: false, // 추후 확장 가능
  );
  final controller = AudioRecorderController(streamRecorder: streamRecorder);
  controller.init(); // Provider 생성 시 초기화
  ref.onDispose(() => controller.disposeRecorder());
  return controller; // controller 리턴 -> 위젯에서 controller 사용 가능
});

// 실시간 음정 탐지한 것을 보냄
// final pitchStreamProvider = StreamProvider.autoDispose<PitchData>((ref) async* {
//   final controller = ref.watch(audioRecorderProvider.notifier);
//
//   // pitchStream이 null이 아니게 될 때까지 기다림
//   while (controller.pitchStream == null) {
//     await Future.delayed(Duration(milliseconds: 50));
//   }
//
//   yield* controller.pitchStream!;
// });

// stream 으로 들어오는 음정을 비교
final evaluatedPitchStreamProvider = StreamProvider.autoDispose<EvaluatedPitch>((ref) async* {
  final controller = ref.watch(audioRecorderProvider.notifier);
  final targetPitchState = ref.watch(targetPitchProvider);

  while (controller.pitchStream == null) {
    await Future.delayed(const Duration(milliseconds: 50));
  }

  await for (final raw in controller.pitchStream!) {
    final targetPitch = ref.read(targetPitchProvider); // 최신 기준 pitch 사용
    final isCorrect = controller.evaluatePitch(_frequencyToMidi(raw.pitch), targetPitch);
    yield EvaluatedPitch(pitch: raw.pitch, isCorrect: isCorrect);
  }
});

// 주파수를 MIDI 넘버로 변환하는 함수
int _frequencyToMidi(double frequency) {
  // A4 = 440Hz = MIDI 69를 기준으로 계산
  double midiDouble = 12 * (log(frequency / 440) / log(2)) + 69;

  // 반올림하여 정수로 변환 (MIDI는 정수값만 사용)
  return midiDouble.round();
}
