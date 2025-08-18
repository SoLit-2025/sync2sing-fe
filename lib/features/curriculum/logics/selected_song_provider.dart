import 'package:flutter_riverpod/flutter_riverpod.dart';

// 선택된 노래의 정보를 저장하는 상태 클래스
class SelectedSong {
  final int? id;
  final String? title;
  final String? artist;
  final String? albumArtUrl;
  final String? voiceType ;
  final int? trainingDays;

  SelectedSong({
    this.id,
    this.title,
    this.artist,
    this.albumArtUrl,
    this.voiceType ,
    this.trainingDays,
  });

  SelectedSong copyWith({
    final int? id,
    final String? title,
    final String? artist,
    final String? albumArtUrl,
    final String? voiceType ,
    final int? trainingDays,
  }) {
    return SelectedSong(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      albumArtUrl: albumArtUrl ?? this.albumArtUrl,
      voiceType : voiceType  ?? this.voiceType ,
      trainingDays: trainingDays ?? this.trainingDays,
    );
  }
}

// 선택된 노래 정보를 관리하는 Notifier
class SelectedSongNotifier extends StateNotifier<SelectedSong> {
  SelectedSongNotifier() : super(SelectedSong());

  void setId(int id) {
    state = state.copyWith(id: id);
  }

  void setTitle(String title) {
    state = state.copyWith(title: title);
  }

  void setArtist(String artist) {
    state = state.copyWith(artist: artist);
  }

  void setAlbumArtUrl(String albumArtUrl) {
    state = state.copyWith(albumArtUrl: albumArtUrl);
  }

  void setVoiceType(String voiceType) {
    state = state.copyWith(voiceType : voiceType);
  }

  void setTrainingDays(int trainingDays) {
    state = state.copyWith(trainingDays: trainingDays);
  }

  // 노래 전체 정보를 한 번에 설정하는 메서드
  void selectSong({
    required int id,
    required String title,
    required String artist,
    String? albumArtUrl,
    String? voiceType,
  }) {
    state = SelectedSong(
      id: id,
      title: title,
      artist: artist,
      albumArtUrl: albumArtUrl,
      voiceType : voiceType,
      trainingDays: state.trainingDays, // 기존 훈련일수 유지
    );
  }

  // 선택 초기화
  void clearSelection() {
    state = SelectedSong();
  }
}

// Provider 선언
final selectedSongProvider = StateNotifierProvider<SelectedSongNotifier, SelectedSong>(
      (ref) => SelectedSongNotifier(),
);
