import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';
import 'dart:math' as math;
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:sync2sing/features/vocal_analysis/logics/providers/voice_type_profile_provider.dart';
import 'package:sync2sing/features/vocal_analysis/logics/providers/vocal_result_provider.dart';

class VocalAnalysisReportPage extends ConsumerWidget {
  const VocalAnalysisReportPage({super.key});

  // extra에서 데이터 받기
  Map<String, dynamic> getReportData(BuildContext context) {
    final state = GoRouterState.of(context);
    try {
      if (state.extra == null) {
        debugPrint('⚠️ state.extra가 null입니다.');
        return {};
      }

      // Null-safe 객체 처리
      final dynamic extra = state.extra!;

      if (extra is Map<String, dynamic>) {
        return extra;
      } else if (extra is String) {
        final decoded = jsonDecode(extra);
        return decoded is Map<String, dynamic> ? decoded : {};
      } else if (extra is AnalysisResult || extra is Song) {
        return extra.toJson();
      } else {
        debugPrint('⚠️ 알 수 없는 데이터 타입: ${extra.runtimeType}');
        return {};
      }
    } catch (e) {
      debugPrint('❌ 데이터 파싱 오류: $e');
      return {};
    }
  }

  Map<String, dynamic> getSongData(Map<String, dynamic> reportData) =>
      reportData['song'] as Map<String, dynamic>? ?? {};
  String getVoiceType(String voiceType) => _getVoiceTypeKorean(voiceType.toUpperCase());
  String getPitchNoteMin(Map<String, dynamic> songData) =>
      songData['pitch_note_min'] as String? ?? '';
  String getPitchNoteMax(Map<String, dynamic> songData) =>
      songData['pitch_note_max'] as String? ?? '';

  String _getVoiceTypeKorean(String voiceType) {
    switch (voiceType) {
      case 'TENOR':
        return '테너';
      case 'BASS':
        return '베이스';
      case 'BARITONE':
        return '바리톤';
      case 'SOPRANO':
        return '소프라노';
      case 'MEZZO_SOPRANO':
        return '메조 소프라노';
      case 'ALTO':
        return '알토';
      default:
        return voiceType;
    }
  }

  String getVoiceTypeDescription(String voiceType) {
    switch (voiceType) {
      case 'TENOR':
        return '평균적인 남성의 높은 음역대로, 밝고 맑은 톤으로 아름다운 멜로디를 들려줘요';
      case 'BASS':
        return '남성의 가장 낮은 음역대로, 깊고 풍부한 저음이 특징이에요';
      case 'BARITONE':
        return '남성의 중간 음역대로, 안정적이고 따뜻한 음색이 매력적이에요';
      case 'SOPRANO':
        return '여성의 가장 높은 음역대로, 화려하고 밝은 고음이 아름다워요';
      case 'MEZZO_SOPRANO':
        return '여성의 소프라노와 알토 중간 음역대로, 풍부하고 따뜻하며 유연한 음색이 특징이에요';
      case 'ALTO':
        return '여성의 낮은 음역대로, 부드럽고 따뜻한 음색이 특징이에요';
      default:
        return '고유한 음색과 특성을 가진 음역대예요';
    }
  }

  List<double> getRadarData(Map<String, dynamic> reportData) {
    final pitchScore = (reportData['pitch_score'] as num? ?? 0).toDouble();
    final beatScore = (reportData['beat_score'] as num? ?? 0).toDouble();
    final pronunciationScore = (reportData['pronunciation_score'] as num? ?? 0).toDouble();
    final breathScore = (reportData['breath_score'] as num? ?? 0).toDouble();

    return [
      pitchScore / 100.0, // 음정
      beatScore / 100.0, // 박자
      pronunciationScore / 100.0, // 발음
      breathScore / 100.0, // 호흡
      ((pitchScore + beatScore + pronunciationScore + breathScore) / 4) / 100.0, // 완성도
    ];
  }

  double getVoiceRangeProgress(Map<String, dynamic> songData) {
    final startValue = _noteToNumber(getPitchNoteMin(songData));
    final endValue = _noteToNumber(getPitchNoteMax(songData));

    if (startValue == -1 || endValue == -1) return 0.0;

    // 인간의 전체 음역대를 C0(12) ~ C8(108)로 가정 (96 semitones)
    const humanRangeStart = 12; // C0
    const humanRangeEnd = 108; // C8
    const totalHumanRange = humanRangeEnd - humanRangeStart;

    final userRange = endValue - startValue;
    return (userRange / totalHumanRange).clamp(0.0, 1.0);
  }

  int _noteToNumber(String note) {
    if (note.isEmpty) return -1;

    final noteMap = {
      'C': 0,
      'C#': 1,
      'Db': 1,
      'D': 2,
      'D#': 3,
      'Eb': 3,
      'E': 4,
      'F': 5,
      'F#': 6,
      'Gb': 6,
      'G': 7,
      'G#': 8,
      'Ab': 8,
      'A': 9,
      'A#': 10,
      'Bb': 10,
      'B': 11,
    };

    // 숫자 추출
    final octaveMatch = RegExp(r'\d+').firstMatch(note);
    if (octaveMatch == null) return -1;

    final octave = int.tryParse(octaveMatch.group(0)!) ?? -1;
    if (octave < 0) return -1;

    // 음표 이름 추출
    final noteName = note.replaceAll(RegExp(r'\d+'), '');
    final noteValue = noteMap[noteName];
    if (noteValue == null) return -1;

    return (octave + 1) * 12 + noteValue;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportData = getReportData(context);

    final voiceTypeData = ref.watch(voiceTypeProfileProvider);
    debugPrint(
      "음역대 저장: ${voiceTypeData.voiceType} | ${voiceTypeData.minNote} | ${voiceTypeData.maxNote}",
    );

    // 디버깅: 실제 전달된 데이터 로그
    debugPrint('reportData: $reportData');

    if (reportData.isEmpty) {
      return Scaffold(
        body: Center(child: Text("분석 결과 데이터가 없습니다.", style: AppTextStyles.body1Bold)),
      );
    }
    final songData = getSongData(reportData);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20.h),
                _buildHeader(),
                SizedBox(height: 24.h),
                _buildVoiceTypeSection(songData, voiceTypeData.voiceType!),
                SizedBox(height: 30.h),
                _buildVoiceRangeSection(
                  context,
                  songData,
                  voiceTypeData.minNote!,
                  voiceTypeData.maxNote!,
                ),
                SizedBox(height: 30.h),
                _buildMusicInfoSection(songData),
                SizedBox(height: 30.h),
                _buildRadarChart(reportData),
                SizedBox(height: 30.h),
                _buildAnalysisDescription(reportData),
                SizedBox(height: 30.h),
                _buildRecommendationSection(reportData),
                SizedBox(height: 40.h),
                _buildCurriculumButton(),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text("최초 종합 분석 리포트", style: AppTextStyles.heading3Bold, textAlign: TextAlign.center);
  }

  Widget _buildVoiceTypeSection(Map<String, dynamic> songData, String voiceType) {
    return Column(
      children: [
        Container(
          width: 120.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: AppColors.primaryPink,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Center(
            child: Text(
              getVoiceType(voiceType),
              style: AppTextStyles.body1Bold.copyWith(color: Colors.white),
            ),
          ),
        ),
        SizedBox(height: 20.h),
        Text(
          getVoiceTypeDescription(voiceType.toUpperCase()),
          style: AppTextStyles.body2,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildVoiceRangeSection(
    BuildContext context,
    Map<String, dynamic> songData,
    String minNote,
    String maxNote,
  ) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text("나의 음역대", style: AppTextStyles.body1Bold),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(width: double.infinity, height: 20.h),
                        Positioned(
                          left: 0,
                          child: Text(
                            // getPitchNoteMin(songData),
                            minNote,
                            style: AppTextStyles.body3,
                          ),
                        ),
                        Positioned(
                          left:
                              (MediaQuery.of(context).size.width - 48.w - 120.w - 16.w) *
                                  getVoiceRangeProgress(songData) -
                              10.w,
                          child: Text(
                            // getPitchNoteMax(songData),
                            maxNote,
                            style: AppTextStyles.body3,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: AppColors.grayscale6,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.grayscale6,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                          FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: getVoiceRangeProgress(songData),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primaryPink,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMusicInfoSection(Map<String, dynamic> songData) {
    final title = songData['title'] as String? ?? '';
    final artist = songData['artist'] as String? ?? '';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.grayscale6,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text("$title - $artist", style: AppTextStyles.body1Bold, textAlign: TextAlign.center),
    );
  }

  Widget _buildRadarChart(Map<String, dynamic> reportData) {
    return Container(
      width: 280.w,
      height: 280.h,
      child: CustomPaint(painter: RadarChartPainter(getRadarData(reportData))),
    );
  }

  Widget _buildAnalysisDescription(Map<String, dynamic> reportData) {
    final reviewTitle = reportData['overall_review_title'] as String? ?? '';
    final reviewContent = reportData['overall_review_content'] as String? ?? '';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.grayscale6,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(reviewTitle, style: AppTextStyles.body2Bold, textAlign: TextAlign.center),
          SizedBox(height: 12.h),
          Text(reviewContent, style: AppTextStyles.body2, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildRecommendationSection(Map<String, dynamic> reportData) {
    final causeContent = reportData['cause_content'] as String? ?? '';
    final proposalContent = reportData['proposal_content'] as String? ?? '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.grayscale6,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("원인", style: AppTextStyles.body1Bold, textAlign: TextAlign.center),
                SizedBox(height: 12.h),
                Text(causeContent, style: AppTextStyles.body3, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.grayscale6,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("제안", style: AppTextStyles.body1Bold, textAlign: TextAlign.center),
                SizedBox(height: 12.h),
                Text(proposalContent, style: AppTextStyles.body3, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurriculumButton() {
    return GestureDetector(
      onTap: () {
        // todo: 맞춤형 커리큘럼 생성 로직 추가
      },
      child: Container(
        width: double.infinity,
        height: 52.h,
        decoration: BoxDecoration(
          color: AppColors.primaryRed,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: Text(
            "맞춤형 커리큘럼 생성하기",
            style: AppTextStyles.body1Bold.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class RadarChartPainter extends CustomPainter {
  final List<double> values;

  RadarChartPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // 배경 그리드 그리기
    final gridPaint =
        Paint()
          ..color = Colors.grey.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    // 5각형 그리드
    for (int i = 1; i <= 5; i++) {
      final currentRadius = radius * i / 5;
      final path = Path();

      for (int j = 0; j < 5; j++) {
        final angle = (j * 2 * math.pi / 5) - math.pi / 2;
        final x = center.dx + currentRadius * math.cos(angle);
        final y = center.dy + currentRadius * math.sin(angle);

        if (j == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // 축 선 그리기
    final axisPaint =
        Paint()
          ..color = Colors.grey.withOpacity(0.5)
          ..strokeWidth = 1;

    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * math.pi / 5) - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), axisPaint);
    }

    // 데이터 영역 그리기
    final dataPaint =
        Paint()
          ..color = AppColors.primaryRed.withOpacity(0.3)
          ..style = PaintingStyle.fill;

    final dataPath = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * math.pi / 5) - math.pi / 2;
      final currentRadius = radius * (values.length > i ? values[i] : 0.0);
      final x = center.dx + currentRadius * math.cos(angle);
      final y = center.dy + currentRadius * math.sin(angle);

      if (i == 0) {
        dataPath.moveTo(x, y);
      } else {
        dataPath.lineTo(x, y);
      }
    }
    dataPath.close();
    canvas.drawPath(dataPath, dataPaint);

    // 데이터 경계선
    final dataBorderPaint =
        Paint()
          ..color = AppColors.primaryRed
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
    canvas.drawPath(dataPath, dataBorderPaint);

    // 레이블 그리기
    final labels = ["음정", "박자", "발음", "호흡", "완성도"];
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * math.pi / 5) - math.pi / 2;
      final labelRadius = radius + 25;
      final x = center.dx + labelRadius * math.cos(angle);
      final y = center.dy + labelRadius * math.sin(angle);

      textPainter.text = TextSpan(
        text: labels[i],
        style: TextStyle(color: Colors.black, fontSize: 12.sp, fontWeight: FontWeight.w500),
      );
      textPainter.layout();

      // 텍스트 중앙 정렬
      final offset = Offset(x - textPainter.width / 2, y - textPainter.height / 2);
      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
