import 'package:sync2sing/features/curriculum/logics/duet_song_model.dart';

class Room {
  int id;
  int trainingDays;
  DateTime? createdAt;
  SongOfRoom song;
  DuetPart hostPart;
  DuetPart partnerPart;

  Room({
    required this.id,
    required this.trainingDays,
    required this.song,
    required this.hostPart,
    required this.partnerPart,
    this.createdAt,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    DateTime? date;
    try {
      date = DateTime.parse(json['created_at']);
    } catch (Exception) {
      date = null;
    }

    return Room(
      id: json['id'] as int? ?? 0,
      trainingDays: json['training_days'] as int? ?? 0,
      song: SongOfRoom.fromJson(json['song']),
      hostPart: DuetPart.fromJson(json['host_part'] ?? ''),
      partnerPart: DuetPart.fromJson(json['partner_part'] ?? ''),
      createdAt: date,
    );
  }
}

class SongOfRoom {
  int id;
  String title;
  String artist;
  String albumArtUrl;

  SongOfRoom({
    required this.id,
    required this.title,
    required this.artist,
    required this.albumArtUrl,
  });

  factory SongOfRoom.fromJson(Map<String, dynamic> json) {
    return SongOfRoom(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      artist: json['artist'] ?? '',
      albumArtUrl: json['album_art_url'] ?? '',
    );
  }
}
