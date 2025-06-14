import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';

// 1. AnalysisResult 모델 클래스 추가
class AnalysisResult {
  final int reportId;
  final String analysisType;
  final String title;
  final int pitchScore;
  final int beatScore;
  final String overallReviewTitle;

  AnalysisResult({
    required this.reportId,
    required this.analysisType,
    required this.title,
    required this.pitchScore,
    required this.beatScore,
    required this.overallReviewTitle,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      reportId: json['report_id'] as int,
      analysisType: json['analysis_type'] as String,
      title: json['title'] as String,
      pitchScore: json['pitch_score'] as int,
      beatScore: json['beat_score'] as int,
      overallReviewTitle: json['overall_review_title'] as String,
    );
  }
}

// 2. 기존 VocalResult 클래스 확장
class VocalResult {
  final String? wavFilePath;
  final int? pitchAccuracy;
  final int? rhythmAccuracy;
  final AnalysisResult? analysisResult; // 새로운 필드 추가

  VocalResult({
    this.wavFilePath,
    this.pitchAccuracy,
    this.rhythmAccuracy,
    this.analysisResult, // 초기값 null 허용
  });

  VocalResult copyWith({
    String? wavFilePath,
    int? pitchAccuracy,
    int? rhythmAccuracy,
    AnalysisResult? analysisResult, // 새로운 필드 복사 지원
  }) {
    return VocalResult(
      wavFilePath: wavFilePath ?? this.wavFilePath,
      pitchAccuracy: pitchAccuracy ?? this.pitchAccuracy,
      rhythmAccuracy: rhythmAccuracy ?? this.rhythmAccuracy,
      analysisResult: analysisResult ?? this.analysisResult,
    );
  }
}

// 3. Notifier 클래스 수정
class VocalResultNotifier extends StateNotifier<VocalResult> {
  VocalResultNotifier() : super(VocalResult());

  // 기존 메서드 유지
  void setWavFilePath(String path) {
    state = state.copyWith(wavFilePath: path);
  }

  void setPitchAccuracy(int accuracy) {
    state = state.copyWith(pitchAccuracy: accuracy);
  }

  void setRhythmAccuracy(int accuracy) {
    state = state.copyWith(rhythmAccuracy: accuracy);
  }

  // 업데이트 메서드 수정
  void updateAnalysisResult(String responseJson) {
    final jsonResult = jsonDecode(responseJson);
    if (jsonResult['status'] == 201) {
      final responseData = jsonResult['data'] as Map<String, dynamic>;
      state = state.copyWith(
        analysisResult: AnalysisResult.fromJson(responseData),
      );
    }
  }
}

// 4. Provider는 그대로 유지
final vocalResultProvider =
    StateNotifierProvider<VocalResultNotifier, VocalResult>(
      (ref) => VocalResultNotifier(),
    );
