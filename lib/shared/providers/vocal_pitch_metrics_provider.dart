import 'package:flutter_riverpod/flutter_riverpod.dart';

// 음정 평균/최고/최저 를 담는 클래스. 추후 domain/models 에 따로 파일을 분리하여 넣을 수 있음.
class VocalPitchMetrics {
  final double? averagePitch;
  final double? minPitch;
  final double? maxPitch;

  const VocalPitchMetrics({this.averagePitch, this.minPitch, this.maxPitch});

  VocalPitchMetrics copyWith({double? averagePitch, double? minPitch, double? maxPitch}) {
    return VocalPitchMetrics(
      averagePitch: averagePitch ?? this.averagePitch,
      minPitch: minPitch ?? this.minPitch,
      maxPitch: maxPitch ?? this.maxPitch,
    );
  }
}

// 평균음, 최저음, 최고음 노트명을 관리하는 Notifier
class VocalRangeNotifier extends StateNotifier<VocalPitchMetrics> {
  VocalRangeNotifier() : super(VocalPitchMetrics());

  void setAveragePitch(double pitch) {
    state = state.copyWith(averagePitch: pitch);
  }

  void setMinPitch(double pitch) {
    state = state.copyWith(minPitch: pitch);
  }

  void setMaxPitch(double pitch) {
    state = state.copyWith(maxPitch: pitch);
  }
}

// Provider 선언
final pitchStatsProvider = StateNotifierProvider<VocalRangeNotifier, VocalPitchMetrics>((ref) => VocalRangeNotifier());
