import 'package:flutter_riverpod/flutter_riverpod.dart';

// 파일 경로와 음정/박자 정확도를 저장하는 클래스
class VocalResult {
  final String? wavFilePath;
  final int? pitchAccuracy;
  final int? rhythmAccuracy;
  VocalResult({this.wavFilePath, this.pitchAccuracy, this.rhythmAccuracy});

  VocalResult copyWith({
    final String? wavFilePath,
    final int? pitchAccuracy,
    final int? rhythmAccuracy,
  }) {
    return VocalResult(
      wavFilePath: wavFilePath ?? this.wavFilePath,
      pitchAccuracy: pitchAccuracy ?? this.pitchAccuracy,
      rhythmAccuracy: rhythmAccuracy ?? this.rhythmAccuracy,
    );
  }
}

// 평균음, 최저음, 최고음 노트명을 관리하는 Notifier
class VocalResultNotifier extends StateNotifier<VocalResult> {
  VocalResultNotifier() : super(VocalResult());

  void setWavFilePath(String voiceType) {
    state = state.copyWith(wavFilePath: voiceType);
  }

  void setPitchAccuracy(int accuracy) {
    state = state.copyWith(pitchAccuracy: accuracy);
  }

  void setRhythmAccuracy(int accuracy) {
    state = state.copyWith(rhythmAccuracy: accuracy);
  }
}

// Provider 선언
final vocalResultProvider = StateNotifierProvider<VocalResultNotifier, VocalResult>(
  (ref) => VocalResultNotifier(),
);
