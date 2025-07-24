import 'package:flutter_riverpod/flutter_riverpod.dart';

// 평균음, 최저음, 최고음 노트명을 저장하는 상태 클래스
class VoiceRangeState {
  final String? averageNote;
  final String? minNote;
  final String? maxNote;
  VoiceRangeState({this.averageNote, this.minNote, this.maxNote});

  VoiceRangeState copyWith({
    String? averageNote,
    String? minNote,
    String? maxNote,
  }) {
    return VoiceRangeState(
      averageNote: averageNote ?? this.averageNote,
      minNote: minNote ?? this.minNote,
      maxNote: maxNote ?? this.maxNote,
    );
  }
}

// 평균음, 최저음, 최고음 노트명을 관리하는 Notifier
class VoiceRangeNotifier extends StateNotifier<VoiceRangeState> {
  VoiceRangeNotifier() : super(VoiceRangeState());

  void setAverageNote(String note) {
    state = state.copyWith(averageNote: note);
  }
  void setMinNote(String note) {
    state = state.copyWith(minNote: note);
  }
  void setMaxNote(String note) {
    state = state.copyWith(maxNote: note);
  }
}

// Provider 선언
final voiceRangeProvider = StateNotifierProvider<VoiceRangeNotifier, VoiceRangeState>(
      (ref) => VoiceRangeNotifier(),
);
