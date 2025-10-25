import 'package:dio/dio.dart';
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

class _UserVoiceInfo {
  String voiceType;
  String pitchNoteMin;
  String pitchNoteMax;

  _UserVoiceInfo({required this.voiceType, required this.pitchNoteMin, required this.pitchNoteMax});
}

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
  late _UserVoiceInfo _userVoiceInfo;

  _UserVoiceInfo getUserVoiceInfo() {
    final state = GoRouterState.of(context);
    // Null-safe 객체 처리
    final dynamic extra = state.extra!;
    debugPrint("extra: $extra");
    try {
      if (state.extra == null) {
        debugPrint('⚠️ state.extra가 null입니다.');
        return _UserVoiceInfo(voiceType: '', pitchNoteMin: '', pitchNoteMax: '');
      }

      if (extra is Map<String, dynamic>) {
        return _UserVoiceInfo(
          voiceType: extra['voiceType'],
          pitchNoteMin: extra['pitchNoteMin'],
          pitchNoteMax: extra['pitchNoteMax'],
        );
      } else {
        debugPrint('⚠️ 알 수 없는 데이터 타입: ${extra.runtimeType}');
        return _UserVoiceInfo(voiceType: '', pitchNoteMin: '', pitchNoteMax: '');
      }
    } catch (e) {
      debugPrint('❌ 데이터 파싱 오류: $e');
      return _UserVoiceInfo(voiceType: '', pitchNoteMin: '', pitchNoteMax: '');
    }
  }

  Future<Map<String, dynamic>> _fetchReportData() async {
    final Map<String, dynamic> nowJson;
    try {
      final response = await DioFactory(SecureStorage()).get('/user/reports/${widget.reportId}');
      nowJson = response.data['data'];
      debugPrint("detail_vocal_analysis_report ${widget.reportId}: $nowJson");
      setState(() {
        appBarTitle = nowJson['title'];
      });
    } on DioException catch (_) {
      rethrow;
    }

    return nowJson;
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
    _userVoiceInfo = getUserVoiceInfo();

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

                        final voiceTypeData =
                            (AnalysisType.guest == analysisType)
                                ? _userVoiceInfo.voiceType
                                : songData['voice_type'] ?? "";
                        final pitchNoteMin =
                            (AnalysisType.guest == analysisType)
                                ? _userVoiceInfo.pitchNoteMin
                                : songData['pitch_note_min'] ?? "";
                        final pitchNoteMax =
                            (AnalysisType.guest == analysisType)
                                ? _userVoiceInfo.pitchNoteMax
                                : songData['pitch_note_max'] ?? "";

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 46.h),
                            _buildSongOverView(songData),
                            SizedBox(height: 16.h),
                            (analysisType == AnalysisType.guest)
                                ? _buildVoiceTypeSection(voiceTypeData) // guest 모드인 경우 타입 설명 포함
                                : _buildVoiceTypeBadge(voiceTypeData),
                            SizedBox(height: 16.h),
                            VoiceRangeDisplay(
                              pitchNoteMin: pitchNoteMin,
                              pitchNoteMax: pitchNoteMax,
                              title: (analysisType == AnalysisType.guest) ? "나의 음역대" : "노래 음역대",
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
                            if (reportData['feedback_title'] != null &&
                                reportData['feedback_content'] != null)
                              _buildFeedbackSection(reportData),
                            if (reportData['cause_content'] != null &&
                                reportData['proposal_content'] != null)
                              _buildRecommendationSection(reportData),
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

  Widget _buildVoiceTypeSection(String voiceType) {
    return Column(
      children: [
        _buildVoiceTypeBadge(voiceType),
        SizedBox(height: 20.h),
        Text(
          getVoiceTypeDescription(voiceType.toUpperCase()),
          style: AppTextStyles.body2.copyWith(color: AppColors.grayscale2),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

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
    int? preTotalScore =
        (prePitchAcc != null && preBeatAcc != null && prePronAcc != null)
            ? ((prePitchAcc + preBeatAcc + prePronAcc) / 3).toInt()
            : null;

    return Column(
      children: [
        _buildAccuracyBarRow("음정", pitchAcc, prePitchAcc),
        SizedBox(height: (prePitchAcc == null) ? 25.h : 15.h),
        _buildAccuracyBarRow("박자", beatAcc, preBeatAcc),
        SizedBox(height: (prePitchAcc == null) ? 25.h : 15.h),
        _buildAccuracyBarRow("발음", pronAcc, prePronAcc),
        SizedBox(height: (prePitchAcc == null) ? 25.h : 15.h),
        _buildAccuracyBarRow(
          "총점",
          ((pronAcc + pitchAcc + beatAcc) / 3).toInt(),
          preTotalScore,
          isTotal: true,
        ),
        if (prePitchAcc != null)
          Padding(padding: EdgeInsets.only(top: 20.h), child: _buildChartLegend())
        else
          SizedBox(height: 15.h),
      ],
    );
  }

  Widget _buildAccuracyBarRow(String desc, int acc, int? preAcc, {bool isTotal = false}) {
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
            _buildAccuracyBar(
              acc,
              (isTotal && preAcc == null) ? AppColors.primaryGreen : AppColors.primaryPink,
            ),
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
