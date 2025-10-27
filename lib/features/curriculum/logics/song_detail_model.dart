import 'package:sync2sing/features/curriculum/logics/timed_lyric.dart';

class SongDetailModel {
  final int id;
  final String title;
  final String artist;
  final String youtubeLink;
  final String voiceType;
  final String pitchNoteMin;
  final String pitchNoteMax;
  final List<TimedLyric> lyrics;
  final String albumArtUrl;
  final String fileUrl;
  String? pitchJsonPath;

  SongDetailModel(
    this.id,
    this.title,
    this.artist,
    this.youtubeLink,
    this.voiceType,
    this.pitchNoteMin,
    this.pitchNoteMax,
    this.lyrics,
    this.albumArtUrl,
    this.fileUrl, {
    this.pitchJsonPath,
  });

  // JSON → 객체 변환
  factory SongDetailModel.fromJson(Map<String, dynamic> data) {
    return SongDetailModel(
      data['id'] ?? 0,
      data['title'] ?? '',
      data['artist'] ?? '',
      data['youtube_link'] ?? '',
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

  void setPitchJsonPath(String path) {
    pitchJsonPath = path;
  }

  static String convertVoiceTypeEng2Kor(String voiceTypeEng) {
    switch (voiceTypeEng) {
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
        return voiceTypeEng;
    }
  }
}
