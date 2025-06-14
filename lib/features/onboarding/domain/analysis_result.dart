// class AnalysisResult {
//   final int reportId;
//   final String analysisType;
//   final String title;
//   final int pitchScore;
//   final int beatScore;
//   final String overallReviewTitle;
//
//   AnalysisResult({
//     required this.reportId,
//     required this.analysisType,
//     required this.title,
//     required this.pitchScore,
//     required this.beatScore,
//     required this.overallReviewTitle,
//   });
//
//   factory AnalysisResult.fromJson(Map<String, dynamic> json) {
//     return AnalysisResult(
//       reportId: json['report_id'] as int,
//       analysisType: json['analysis_type'] as String,
//       title: json['title'] as String,
//       pitchScore: json['pitch_score'] as int,
//       beatScore: json['beat_score'] as int,
//       overallReviewTitle: json['overall_review_title'] as String,
//     );
//   }
// }
