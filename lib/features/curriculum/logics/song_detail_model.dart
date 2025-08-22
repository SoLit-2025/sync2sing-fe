import 'package:sync2sing/features/curriculum/logics/timed_lyric.dart';

class SongDetailModel {
  final int id;
  final String title;
  final String artist;
  final String voiceType;
  final String pitchNoteMin;
  final String pitchNoteMax;
  final List<TimedLyric> lyrics;
  final String albumArtUrl;
  final String fileUrl;

  SongDetailModel(
    this.id,
    this.title,
    this.artist,
    this.voiceType,
    this.pitchNoteMin,
    this.pitchNoteMax,
    this.lyrics,
    this.albumArtUrl,
    this.fileUrl,
  );

  // JSON → 객체 변환
  factory SongDetailModel.fromJson(Map<String, dynamic> data) {
    return SongDetailModel(
      data['id'] ?? 0,
      data['title'] ?? '',
      data['artist'] ?? '',
      data['voice_type'] ?? '',
      data['pitch_note_min'] ?? '',
      data['pitch_note_max'] ?? '',
      (data['lyrics'] as List<dynamic>? ?? []).map((item) => TimedLyric.fromJson(item)).toList(),
      data['album_art_url'] ?? '',
      data['file_url'] ?? '',
    );
  }
  String getVoiceTypeKorean() {
    switch (voiceType) {
      case 'TENOR':
        return '테너';
      case 'BASS':
        return '베이스';
      case 'BARITONE':
        return '바리톤';
      case 'SOPRANO':
        return '소프라노';
      case 'ALTO':
        return '알토';
      default:
        return voiceType;
    }
  }
}

class DuetPart {
  final int partNumber; // 파트 번호
  final String partName; // 파트 이름
  final List<int> lyricsIndexes; // 해당 파트에서 사용하는 가사 인덱스 목록

  DuetPart({required this.partNumber, required this.partName, required this.lyricsIndexes});

  factory DuetPart.fromJson(Map<String, dynamic> json) {
    return DuetPart(
      partNumber: json['part_number'],
      partName: json['part_name'],
      lyricsIndexes: (json['lyrics_indexes'] as List).map((e) => e as int).toList(),
    );
  }
}
