import 'package:sync2sing/features/curriculum/logics/song_detail_model.dart';

class DuetSongModel extends SongDetailModel {
  List<DuetPart> duetParts;

  DuetSongModel(
    super.id,
    super.title,
    super.artist,
    super.youtubeLink,
    super.voiceType,
    super.pitchNoteMin,
    super.pitchNoteMax,
    super.lyrics,
    super.albumArtUrl,
    super.fileUrl, {
    required this.duetParts,
  });

  factory DuetSongModel.fromJson(Map<String, dynamic> json) {
    // SongDetailModel 영역
    final base = SongDetailModel.fromJson(json);

    // 새로운 필드 파싱
    final duetParts =
        (json['duet_parts'] as List<dynamic>? ?? [])
            .map((e) => DuetPart.fromJson(e as Map<String, dynamic>))
            .toList();

    return DuetSongModel(
      base.id,
      base.title,
      base.artist,
      base.youtubeLink,
      base.voiceType,
      base.pitchNoteMin,
      base.pitchNoteMax,
      base.lyrics,
      base.albumArtUrl,
      base.fileUrl,
      duetParts: duetParts,
    );
  }
}

class DuetPart {
  final int partNumber; // 파트 번호
  final String partName; // 파트 이름
  final String voiceType;
  final String pitchNoteMin;
  final String pitchNoteMax;

  DuetPart({
    required this.partNumber,
    required this.partName,
    required this.voiceType,
    required this.pitchNoteMin,
    required this.pitchNoteMax,
  });

  factory DuetPart.fromJson(Map<String, dynamic> json) {
    return DuetPart(
      partNumber: json['part_number'] ?? 0,
      partName: json['part_name'] ?? '',
      voiceType: json['voice_type'] ?? '',
      pitchNoteMin: json['pitch_note_min'] ?? '',
      pitchNoteMax: json['pitch_note_max'] ?? '',
    );
  }
}
