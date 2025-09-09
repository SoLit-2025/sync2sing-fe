import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';

// 1. 중첩된 Song 모델 클래스 (null-safe, 기본값 처리)
class Song {
  final int songId;
  final String title;
  final String artist;
  final String voiceType;
  final String pitchNoteMin;
  final String pitchNoteMax;
  final String albumCoverUrl;

  Song({
    required this.songId,
    required this.title,
    required this.artist,
    required this.voiceType,
    required this.pitchNoteMin,
    required this.pitchNoteMax,
    required this.albumCoverUrl,
  });

  Map<String, dynamic> toJson() => {
    'song_id': songId,
    'title': title,
    'artist': artist,
    'voice_type': voiceType,
    'pitch_note_min': pitchNoteMin,
    'pitch_note_max': pitchNoteMax,
    'album_cover_url': albumCoverUrl,
  };

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      songId: json['song_id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      artist: json['artist'] as String? ?? '',
      voiceType: json['voice_type'] as String? ?? '',
      pitchNoteMin: json['pitch_note_min'] as String? ?? '',
      pitchNoteMax: json['pitch_note_max'] as String? ?? '',
      albumCoverUrl: json['album_cover_url'] as String? ?? '',
    );
  }
}

// 2. AnalysisResult 모델 클래스 (null-safe, 기본값 처리, 안전한 toJson)
class AnalysisResult {
  final int reportId;
  final String analysisType;
  final String title;
  final Song? song;
  final int pitchScore;
  final int beatScore;
  final int pronunciationScore;
  final String overallReviewTitle;
  final String overallReviewContent;
  final DateTime? createdAt;
  final String causeContent;
  final String proposalContent;

  AnalysisResult({
    required this.reportId,
    required this.analysisType,
    required this.title,
    this.song,
    required this.pitchScore,
    required this.beatScore,
    required this.pronunciationScore,
    required this.overallReviewTitle,
    required this.overallReviewContent,
    this.createdAt,
    required this.causeContent,
    required this.proposalContent,
  });

  Map<String, dynamic> toJson() => {
    'report_id': reportId,
    'analysis_type': analysisType,
    'title': title,
    'song': song != null ? song!.toJson() : {},
    'pitch_score': pitchScore,
    'beat_score': beatScore,
    'pronunciation_score': pronunciationScore,
    'overall_review_title': overallReviewTitle,
    'overall_review_content': overallReviewContent,
    'created_at': createdAt?.toIso8601String() ?? '',
    'cause_content': causeContent,
    'proposal_content': proposalContent,
  };

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      reportId: json['report_id'] as int? ?? 0,
      analysisType: json['analysis_type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      song:
          json['song'] != null && json['song'] is Map<String, dynamic>
              ? Song.fromJson(json['song'] as Map<String, dynamic>)
              : null,
      pitchScore: json['pitch_score'] as int? ?? 0,
      beatScore: json['beat_score'] as int? ?? 0,
      pronunciationScore: json['pronunciation_score'] as int? ?? 0,
      overallReviewTitle: json['overall_review_title'] as String? ?? '',
      overallReviewContent: json['overall_review_content'] as String? ?? '',
      createdAt:
          json['created_at'] != null &&
                  json['created_at'] is String &&
                  (json['created_at'] as String).isNotEmpty
              ? DateTime.tryParse(json['created_at'] as String)
              : null,
      causeContent: json['cause_content'] as String? ?? '',
      proposalContent: json['proposal_content'] as String? ?? '',
    );
  }
}

// 3. VocalResult 클래스 (null-safe, toJson 추가)
class VocalResult {
  final String? wavFilePath;
  final int? pitchAccuracy;
  final int? rhythmAccuracy;
  final AnalysisResult? analysisResult;

  VocalResult({this.wavFilePath, this.pitchAccuracy, this.rhythmAccuracy, this.analysisResult});

  VocalResult copyWith({
    String? wavFilePath,
    int? pitchAccuracy,
    int? rhythmAccuracy,
    AnalysisResult? analysisResult,
  }) {
    return VocalResult(
      wavFilePath: wavFilePath ?? this.wavFilePath,
      pitchAccuracy: pitchAccuracy ?? this.pitchAccuracy,
      rhythmAccuracy: rhythmAccuracy ?? this.rhythmAccuracy,
      analysisResult: analysisResult ?? this.analysisResult,
    );
  }

  Map<String, dynamic> toJson() => {
    'wavFilePath': wavFilePath ?? '',
    'pitchAccuracy': pitchAccuracy ?? 0,
    'rhythmAccuracy': rhythmAccuracy ?? 0,
    'analysisResult': analysisResult != null ? analysisResult!.toJson() : {},
  };
}

// 4. Notifier 클래스 (null-safe, 예외 처리, 타입 안전)
class VocalResultNotifier extends StateNotifier<VocalResult> {
  VocalResultNotifier() : super(VocalResult());

  void setWavFilePath(String path) {
    state = state.copyWith(wavFilePath: path);
  }

  void setPitchAccuracy(int accuracy) {
    state = state.copyWith(pitchAccuracy: accuracy);
  }

  void setRhythmAccuracy(int accuracy) {
    state = state.copyWith(rhythmAccuracy: accuracy);
  }

  void updateAnalysisResult(String responseJson) {
    try {
      final jsonResult = jsonDecode(responseJson);
      if (jsonResult['status'] == 201) {
        final responseData = jsonResult['data'] as Map<String, dynamic>;
        state = state.copyWith(
          analysisResult: AnalysisResult.fromJson(responseData),
          pitchAccuracy: responseData['pitch_score'] as int? ?? 0,
          rhythmAccuracy: responseData['beat_score'] as int? ?? 0,
        );
      }
    } catch (e) {
      // 에러 로깅 (실서비스에서는 Sentry 등으로 연동 예정)
      print('⚠️ 분석 결과 업데이트 실패: $e');
    }
  }
}

// 5. Provider 정의
final vocalResultProvider = StateNotifierProvider<VocalResultNotifier, VocalResult>(
  (ref) => VocalResultNotifier(),
);
