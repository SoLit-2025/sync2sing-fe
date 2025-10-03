import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/features/shared/logics/analysis_type.dart';
import 'package:sync2sing/features/shared/logics/dio_factory.dart';
import 'package:sync2sing/features/shared/logics/secure_storage.dart';
import 'package:sync2sing/features/shared/logics/training_mode.dart';
import 'package:sync2sing/features/shared/views/custom_loading_page.dart';
import 'package:sync2sing/features/shared/views/voice_range_display.dart';
import 'dart:convert';

class DetailVocalAnalysisReportPage extends StatefulWidget {
  final int reportId;
  final TrainingMode trainingMode;

  const DetailVocalAnalysisReportPage({
    super.key,
    required this.reportId,
    required this.trainingMode,
  });

  @override
  State<DetailVocalAnalysisReportPage> createState() => _DetailVocalAnalysisReportPageState();
}

class _DetailVocalAnalysisReportPageState extends State<DetailVocalAnalysisReportPage> {
  late final Future<Map<String, dynamic>> reportJson;
  String appBarTitle = '';

  Future<Map<String, dynamic>> _fetchReportData() async {
    Future.delayed(Duration(milliseconds: 4));
    Map<String, dynamic> postJson = {
      "report_id": 12,
      "analysis_type": "POST",
      "title": "2025-09-06 Do-Re-Mi",
      "song": {
        "song_id": 1,
        "title": "Do-Re-Mi",
        "artist": "Richard Rodgers",
        "voice_type": "SOPRANO",
        "pitch_note_min": "C4",
        "pitch_note_max": "D5",
        "album_cover_url":
            'https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/39f14afc-704b-453a-b481-474728491780.jpg',
        // 'https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/39f14afc-704b-453a-b481-474728491780.jpg',
      },
      "pitch_score": 65,
      "beat_score": 90,
      "pronunciation_score": 11,
      "overall_review_title": "발음 교정이 필요해요",
      "overall_review_content":
          "음정과 박자는 안정적이나 발음이 크게 부족해서 노래 전달력이 떨어져요. 훈련 후 변화가 없어서 지속적인 개선이 필요해요. 발성과 발음 연습을 꾸준히 하면서 발음 교정에 집중해봐요.",
      "created_at": "2025-09-06T01:06:14.764957128",
      "pre_pitch_score": 65,
      "pre_beat_score": 90,
      "pre_pronunciation_score": 11,
      "feedback_title": "발음 연습으로 개선하세요",
      "feedback_content":
          "발음 태그 중 lip_trill이 가장 높으니, 매일 5분씩 혀와 입술 근육을 강화하는 연습을 하세요. 예를 들어, 10분간 '입술 살짝 벌려 소리 내기'와 '혀 끝으로 입천장 지르기'를 하루에 두 번씩 해보세요.",
    };

    Map<String, dynamic> preJson = {
      "report_id": 11,
      "analysis_type": "PRE",
      "title":
          "2025-09-06 Do-Re-Mi", // 2025-05-07 Golden (From 'K-POP Demon Hunters') // 2025-09-06 Do-Re-Mi
      "song": {
        "song_id": 1,
        "title": "Do-Re-Mi",
        "artist": "Richard Rodgers",
        "voice_type": "SOPRANO",
        "pitch_note_min": "C4",
        "pitch_note_max": "D5",
        "album_cover_url":
            'https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/39f14afc-704b-453a-b481-474728491780.jpg',
      },
      "pitch_score": 100,
      "beat_score": 90,
      "pronunciation_score": 11,
      "overall_review_title": "발음이 가장 약해요, 개선이 필요해요",
      "overall_review_content":
          "발음 점수가 낮아 노래 전달력이 떨어질 수 있어요. 특히 발음이 불분명하면 듣는 사람이 이해하기 어려워요. 발음 연습과 꾸준한 연습이 필요해요.",
      "created_at": "2025-09-06T00:58:57.561592029",
      "cause_content": "발음 점수가 매우 낮아 발성 연습과 구체적 혀·입술 움직임 연습이 부족했을 가능성이 있어요.",
      "proposal_content": "매일 10분 동안 발음 교정 연습을 하세요. 혀와 입술을 이용한 소리 명확히 하기, 슬로우하게 발음하면서 연습해요.",
    };

    final nowJson = preJson;

    setState(() {
      appBarTitle = nowJson['title'];
    });

    return nowJson;

    // final state = GoRouterState.of(context);
    // try {
    //   if (state.extra == null) {
    //     debugPrint('⚠️ state.extra가 null입니다.');
    //     return {};
    //   }
    //
    //   // Null-safe 객체 처리
    //   final dynamic extra = state.extra!;
    //
    //   if (extra is Map<String, dynamic>) {
    //     return extra;
    //   } else if (extra is String) {
    //     final decoded = jsonDecode(extra);
    //     return decoded is Map<String, dynamic> ? decoded : {};
    //   } else if (extra is AnalysisResult || extra is Song) {
    //     return extra.toJson();
    //   } else {
    //     debugPrint('⚠️ 알 수 없는 데이터 타입: ${extra.runtimeType}');
    //     return {};
    //   }
    // } catch (e) {
    //   debugPrint('❌ 데이터 파싱 오류: $e');
    //   return {};
    // }
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
      case 'ALTO':
        return '알토';
      default:
        return voiceType;
    }
  }

  String getVoiceTypeDescription(String voiceType) {
    switch (voiceType) {
      case 'TENOR':
        return '평균적인 남성의 높은 음역대로, \n밝고 맑은 톤으로 아름다운 멜로디를 들려줘요';
      case 'BASS':
        return '남성의 가장 낮은 음역대로, \n깊고 풍부한 저음이 특징이에요';
      case 'BARITONE':
        return '남성의 중간 음역대로, \n안정적이고 따뜻한 음색이 매력적이에요';
      case 'SOPRANO':
        return '여성의 가장 높은 음역대로, \n화려하고 밝은 고음이 아름다워요';
      case 'ALTO':
        return '여성의 낮은 음역대로, \n부드럽고 따뜻한 음색이 특징이에요';
      default:
        return '고유한 음색과 특성을 가진 음역대예요';
    }
  }

  @override
  void initState() {
    super.initState();
    reportJson = _fetchReportData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildAppBar(context, appBarTitle),
              Align(
                alignment: Alignment(0.0, -1.0),
                child: SizedBox(
                  width: 327.w,
                  child: FutureBuilder(
                    future: reportJson,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasError) {
                        final errorString = snapshot.error.toString();

                        debugPrint("widget 오류 발생: $errorString");
                        try {
                          final Map<String, dynamic> errorJson = jsonDecode(
                            errorString.replaceFirst('Exception: ', '').trim(),
                          );

                          final status = errorJson['status']?.toString() ?? 'Unknown status';

                          if (status == "403") {
                            return Text("로그인 해주세요!");
                          }
                          return Text('알 수 없는 오류가 발생했습니다.');
                        } catch (e) {
                          return Text('알 수 없는 오류가 발생했습니다.');
                        }
                      } else if (snapshot.hasData == false) {
                        return CustomLoading();
                      } else {
                        final Map<String, dynamic> reportData = snapshot.data;
                        final songData = getSongData(reportData);

                        final AnalysisType analysisType = AnalysisType.values.firstWhere(
                          (e) => e.apiValue == (reportData['analysis_type'] ?? 'PRE'),
                        );

                        final voiceTypeData = songData['voice_type'];
                        final pitchNoteMin = songData['pitch_note_min'] ?? "";
                        final pitchNoteMax = songData['pitch_note_max'] ?? "";

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 46.h),
                            _buildSongOverView(songData),
                            SizedBox(height: 16.h),
                            _buildVoiceTypeBadge(voiceTypeData),
                            SizedBox(height: 16.h),
                            VoiceRangeDisplay(
                              pitchNoteMin: pitchNoteMin,
                              pitchNoteMax: pitchNoteMax,
                              title: "노래 음역대",
                            ),
                            SizedBox(height: 16.h),
                            _buildAccuracySection(
                              reportData['pitch_score'],
                              reportData['beat_score'],
                            ),
                            SizedBox(height: 40.h),
                            _buildAccuracyBarSection(
                              reportData['pitch_score'],
                              reportData['beat_score'],
                              reportData['pronunciation_score'],
                              reportData['pre_pitch_score'],
                              reportData['pre_beat_score'],
                              reportData['pre_pronunciation_score'],
                            ),
                            SizedBox(height: 32.h),
                            _buildAnalysisDescription(reportData),
                            SizedBox(height: 14.h),
                            (analysisType == AnalysisType.post)
                                ? _buildFeedbackSection(reportData)
                                : _buildRecommendationSection(reportData),
                            SizedBox(height: 40.h),
                            _buildCurriculumButton(context, reportData),
                            SizedBox(height: 40.h),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, String text) {
    return SizedBox(
      height: 56.h,
      child: Row(
        children: [
          SizedBox(width: 18.w),
          GestureDetector(
            onTap: () => context.pop(),
            child: Image.asset(
              'assets/images/left_arrow_icon.png',
              width: 14.w,
              height: 24.h,
              fit: BoxFit.contain,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 14.w),
        ],
      ),
    );
  }

  Widget _buildSongOverView(Map<String, dynamic> songData) {
    debugPrint("songData['album_cover_url']: ${songData['album_cover_url']}");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: Image.network(
            songData['album_cover_url'],
            height: 150.h,
            width: 150.w,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildDefaultAlbumArt(),
          ),
        ),
        SizedBox(height: 10.h),
        Text(songData['title'], style: AppTextStyles.heading3Bold),
        Text(songData['artist'], style: AppTextStyles.body3.copyWith(color: AppColors.grayscale3)),
      ],
    );
  }

  Widget _buildDefaultAlbumArt() {
    return Center(
      child: Image.asset(
        'assets/images/default_album_art.png',
        height: 150.h,
        width: 150.w,
        fit: BoxFit.contain,
      ),
    );
  }

  // Widget _buildVoiceTypeSection(String voiceType) {
  //   return Column(
  //     children: [
  //       _buildVoiceTypeBadge(voiceType),
  //       SizedBox(height: 20.h),
  //       Text(
  //         getVoiceTypeDescription(voiceType.toUpperCase()),
  //         style: AppTextStyles.body2.copyWith(color: AppColors.grayscale2),
  //         textAlign: TextAlign.center,
  //       ),
  //     ],
  //   );
  // }

  Widget _buildVoiceTypeBadge(String voiceType) {
    return Container(
      width: 100.w,
      height: 30.h,
      decoration: BoxDecoration(
        color: AppColors.grayscale3,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Center(child: Text(getVoiceType(voiceType), style: AppTextStyles.body1BoldWhite)),
    );
  }

  Widget _buildAccuracySection(int pitchAccuracy, int rhythmAccuracy) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: _buildTitleValueSection("음정 정확도", "$pitchAccuracy%")),
        SizedBox(width: 20.w),
        Expanded(child: _buildTitleValueSection("박자 정확도", "$rhythmAccuracy%")),
      ],
    );
  }

  Widget _buildTitleValueSection(String title, String desc) {
    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grayscale6, width: 1),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: AppTextStyles.body4.copyWith(color: AppColors.grayscale2),
            textAlign: TextAlign.center,
          ),
          Text(desc, style: AppTextStyles.heading4Bold, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildAnalysisDescription(Map<String, dynamic> reportData) {
    final reviewTitle = reportData['overall_review_title'] as String? ?? '';
    final reviewContent = reportData['overall_review_content'] as String? ?? '';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grayscale6),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(reviewTitle, style: AppTextStyles.body4Bold, textAlign: TextAlign.center),
          SizedBox(height: 12.h),
          Text(reviewContent, style: AppTextStyles.body6, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildRecommendationSection(Map<String, dynamic> reportData) {
    final causeContent = reportData['cause_content'] ?? reportData['cause_content'] ?? '';
    final proposalContent = reportData['proposal_content'] as String? ?? '';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,

        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grayscale6),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("이런 연습이 필요해요", style: AppTextStyles.body4Bold, textAlign: TextAlign.center),
                  SizedBox(height: 12.h),
                  Text(causeContent, style: AppTextStyles.body6, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grayscale6),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("이런 방법을 추천해요", style: AppTextStyles.body4Bold, textAlign: TextAlign.center),
                  SizedBox(height: 12.h),
                  Text(proposalContent, style: AppTextStyles.body6, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection(Map<String, dynamic> reportData) {
    final title = reportData['feedback_title'] ?? '';
    final content = reportData['feedback_content'] as String? ?? '';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grayscale6),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, style: AppTextStyles.body4Bold, textAlign: TextAlign.center),
          SizedBox(height: 12.h),
          Text(content, style: AppTextStyles.body6, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildCurriculumButton(BuildContext context, Map<String, dynamic> reportData) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        return GestureDetector(
          onTap: () {
            context.pop();
          },
          child: Container(
            width: double.infinity,
            height: 52.h,
            decoration: BoxDecoration(
              color: AppColors.primaryPink,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(child: Text('확인', style: AppTextStyles.body1BoldWhite)),
          ),
        );
      },
    );
  }

  Widget _buildAccuracyBarSection(
    int pitchAcc,
    int beatAcc,
    int pronAcc,
    int? prePitchAcc,
    int? preBeatAcc,
    int? prePronAcc,
  ) {
    return Column(
      children: [
        _buildAccuracyBarRow("음정", pitchAcc, prePitchAcc),
        SizedBox(height: (prePitchAcc == null) ? 25.h : 15.h),
        _buildAccuracyBarRow("박자", beatAcc, preBeatAcc),
        SizedBox(height: (prePitchAcc == null) ? 25.h : 15.h),
        _buildAccuracyBarRow("발음", pronAcc, prePronAcc),
        if (prePitchAcc != null)
          Padding(padding: EdgeInsets.only(top: 20.h), child: _buildChartLegend())
        else
          SizedBox(height: 15.h),
      ],
    );
  }

  Widget _buildAccuracyBarRow(String desc, int acc, int? preAcc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("$desc $acc", style: AppTextStyles.body4Bold),
        Spacer(),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (preAcc != null)
              Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: _buildAccuracyBar(preAcc, AppColors.primaryGreen),
              ),
            _buildAccuracyBar(acc, AppColors.primaryPink),
          ],
        ),
      ],
    );
  }

  Widget _buildAccuracyBar(int accuracy, Color barColor) {
    final double clampedAccuracy = accuracy.toDouble().clamp(0, 100);
    final double totalWidth = 260.w;
    final double progressWidth = totalWidth * (clampedAccuracy / 100);

    return Container(
      height: 10.h,
      width: totalWidth,
      decoration: BoxDecoration(
        color: AppColors.grayscale6,
        borderRadius: BorderRadius.circular(10.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: <Widget>[
          Container(
            width: progressWidth,
            height: 10.h,
            decoration: BoxDecoration(color: barColor, borderRadius: BorderRadius.circular(10.r)),
          ),
          Positioned(
            left: totalWidth / 3 - 1,
            top: 0,
            bottom: 0,
            child: Container(width: 2.0, color: AppColors.grayscale8),
          ),
          Positioned(
            left: totalWidth * 2 / 3 - 1,
            top: 0,
            bottom: 0,
            child: Container(width: 2.0, color: AppColors.grayscale8),
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend() {
    // 차트 범례
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("훈련 전", style: AppTextStyles.body6),
        SizedBox(width: 10.w),
        Container(
          width: 12.r,
          height: 12.r,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 20.w),
        Text("훈련 후", style: AppTextStyles.body6),
        SizedBox(width: 10.w),
        Container(
          width: 12.r,
          height: 12.r,
          decoration: BoxDecoration(
            color: AppColors.primaryPink,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
      ],
    );
  }
}
