import 'package:flutter_riverpod/flutter_riverpod.dart';

// 평균, 최저, 최고 음정의 노트명을 저장하는 상태 클래스
class VoiceTypeProfile {
  final String? voiceType;
  final String? minNote;
  final String? maxNote;
  VoiceTypeProfile({this.voiceType, this.minNote, this.maxNote});

  VoiceTypeProfile copyWith({
    final String? voiceType,
    final String? minNote,
    final String? maxNote,
  }) {
    return VoiceTypeProfile(
      voiceType: voiceType ?? this.voiceType,
      minNote: minNote ?? this.minNote,
      maxNote: maxNote ?? this.maxNote,
    );
  }
}

// 평균음, 최저음, 최고음 노트명을 관리하는 Notifier
class VoiceTypeProfileNotifier extends StateNotifier<VoiceTypeProfile> {
  VoiceTypeProfileNotifier() : super(VoiceTypeProfile());

  void setVoiceType(String voiceType) {
    state = state.copyWith(voiceType: voiceType);
  }

  void setMinNote(String note) {
    state = state.copyWith(minNote: note);
  }

  void setMaxNote(String note) {
    state = state.copyWith(maxNote: note);
  }
}

// Provider 선언
final voiceTypeProfileProvider = StateNotifierProvider<VoiceTypeProfileNotifier, VoiceTypeProfile>(
  (ref) => VoiceTypeProfileNotifier(),
);
