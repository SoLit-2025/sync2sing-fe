import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/routes/route_names.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  int? _pressedReportIndex;
  String? _pressedReportType;

  // 보컬 분석 리포트 mock 데이터
  final List<Map<String, String>> _soloReports = [
    {'date': '2025-07-15', 'title': 'Golden (From \'K-POP Demon H...'},
    {'date': '2025-06-15', 'title': 'Goodbye (From \'Catch Me If You Can\')'},
    {'date': '2025-04-15', 'title': 'Defying Gravity (From \'Wicked\')'},
    {'date': '2025-03-15', 'title': 'What is This Feeling? (From \'Wicked\')'},
  ];

  final List<Map<String, String>> _duetReports = [
    {'date': '2025-07-15', 'title': 'Golden (From \'K-POP Demon H...)'},
    {'date': '2025-06-15', 'title': 'Goodbye (From \'Catch Me If You Can\')'},
    {'date': '2025-04-15', 'title': 'Defying Gravity (From \'Wicked\')'},
    {'date': '2025-03-15', 'title': 'What is This Feeling? (From \'Wicked\')'},
    {'date': '2025-02-15', 'title': 'Popular (From \'Wicked\')'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grayscale8,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 15.h),
              _buildHeader(),
              SizedBox(height: 30.h),
              _buildProfileSection(),
              SizedBox(height: 10.h),
              _buildVoiceTypeSection(),
              SizedBox(height: 20.h),
              _buildVoiceRangeSection(),
              SizedBox(height: 20.h),
              _buildParticipationStatusSection(),
              SizedBox(height: 30.h),
              _buildVocalAnalysisReportSection(),
              SizedBox(height: 100.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          child: GestureDetector(
            onTap: () {
              context.push(AppRoutePaths.settings);
            },
            child: Image.asset('assets/images/settings_icon.png', width: 27.w, height: 27.h),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 10.w),
            Text(
              '노래하는 해파리',
              style: AppTextStyles.heading2Bold.copyWith(color: AppColors.grayscale1),
              textAlign: TextAlign.center,
            ),
            SizedBox(width: 8.w),
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: GestureDetector(
                onTap: () {
                  // todo: 닉네임 수정 기능 추가
                },
                child: Image.asset(
                  'assets/images/edit_nickname_icon.png',
                  width: 12.w,
                  height: 12.h,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 3.h),
        Text(
          '@jellyfish1234',
          style: AppTextStyles.body2.copyWith(color: AppColors.grayscale4),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildVoiceTypeSection() {
    return Container(
      width: 100.w,
      height: 30.h,
      decoration: BoxDecoration(
        color: AppColors.primaryPink,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Center(
        child: Text(
          '소프라노',
          style: AppTextStyles.body3Bold.copyWith(color: AppColors.grayscale8),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildVoiceRangeSection() {
    return Container(
      width: 327.w,
      height: 50.h,
      decoration: BoxDecoration(
        color: AppColors.grayscale8,
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: AppColors.grayscale6, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
        child: Row(
          children: [
            Text('나의 음역대', style: AppTextStyles.body4.copyWith(color: AppColors.grayscale1)),
            SizedBox(width: 20.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Text(
                          'E1',
                          style: AppTextStyles.body6.copyWith(color: AppColors.grayscale1),
                        ),
                      ),
                      Positioned(
                        left: 74.w,
                        top: 0,
                        child: Text(
                          'F4',
                          style: AppTextStyles.body6.copyWith(color: AppColors.grayscale1),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 18.h),
                        child: Stack(
                          children: [
                            Container(
                              width: 200.w,
                              height: 7.h,
                              decoration: BoxDecoration(
                                color: AppColors.grayscale6,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                            Container(
                              width: 80.w,
                              height: 7.h,
                              decoration: BoxDecoration(
                                color: AppColors.primaryPink,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipationStatusSection() {
    return Row(
      children: [
        Expanded(child: _buildStatusCard('총 연습시간', '32분')),
        SizedBox(width: 12.w),
        Expanded(child: _buildStatusCard('완료한 훈련', '16개')),
        SizedBox(width: 12.w),
        Expanded(child: _buildStatusCard('패널티', '1개')),
      ],
    );
  }

  Widget _buildStatusCard(String title, String value) {
    return Container(
      width: 100.w,
      height: 85.h, // 이하로 줄이면 BOTTOM OVERFLOWED BY 11 PIXEL 오류 발생
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.grayscale8,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.grayscale6, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: AppTextStyles.body4.copyWith(color: AppColors.grayscale2),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: AppTextStyles.body1Bold.copyWith(color: AppColors.grayscale1),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVocalAnalysisReportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '보컬 분석 리포트 기록',
              style: AppTextStyles.body4Bold.copyWith(color: AppColors.grayscale3),
            ),
            Text(
              '${_soloReports.length + _duetReports.length}',
              style: AppTextStyles.body3Bold.copyWith(color: AppColors.primaryPink),
            ),
          ],
        ),
        SizedBox(height: 20.h),
        _buildTrainingSection('솔로 트레이닝', '${_soloReports.length}', _soloReports, 'solo'),
        SizedBox(height: 30.h),
        _buildTrainingSection('듀엣 트레이닝', '${_duetReports.length}', _duetReports, 'duet'),
      ],
    );
  }

  Widget _buildTrainingSection(
    String title,
    String count,
    List<Map<String, String>> reports,
    String type,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTextStyles.body3Bold.copyWith(color: AppColors.grayscale1)),
            Text(count, style: AppTextStyles.body3Bold.copyWith(color: AppColors.primaryPink)),
          ],
        ),
        SizedBox(height: 12.h),
        ...reports.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, String> report = entry.value;
          return _buildReportItem(report['date']!, report['title']!, index, type);
        }).toList(),
      ],
    );
  }

  Widget _buildReportItem(String date, String title, int index, String type) {
    bool isPressed = _pressedReportIndex == index && _pressedReportType == type;

    return Column(
      children: [
        GestureDetector(
          onTapDown: (_) {
            setState(() {
              _pressedReportIndex = index;
              _pressedReportType = type;
            });
          },
          onTapUp: (_) {
            setState(() {
              _pressedReportIndex = null;
              _pressedReportType = null;
            });
            // todo: 리포트 상세 페이지 이동 구현
            // context.pushNamed(AppRouteNames.reportDetail, extra: {'date': date, 'title': title});
          },
          onTapCancel: () {
            setState(() {
              _pressedReportIndex = null;
              _pressedReportType = null;
            });
          },
          child: Container(
            width: 327.w,
            height: 35.h,
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: isPressed ? AppColors.grayscale7 : AppColors.grayscale8,
            ),
            child: Row(
              children: [
                Text(date, style: AppTextStyles.body4.copyWith(color: AppColors.grayscale1)),
                SizedBox(width: 16.w),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final textPainter = TextPainter(
                        text: TextSpan(
                          text: title,
                          style: AppTextStyles.body4.copyWith(color: AppColors.grayscale1),
                        ),
                        textDirection: TextDirection.ltr,
                      );
                      textPainter.layout(maxWidth: constraints.maxWidth);

                      return Text(
                        title,
                        style: AppTextStyles.body4.copyWith(color: AppColors.grayscale1),
                        overflow:
                            textPainter.didExceedMaxLines
                                ? TextOverflow.ellipsis
                                : TextOverflow.visible,
                      );
                    },
                  ),
                ),
                SizedBox(width: 8.w),
                Image.asset('assets/images/right_arrow_icon.png', width: 7.w, height: 12.h),
              ],
            ),
          ),
        ),
        Container(width: 327.w, height: 1.h, color: AppColors.grayscale6),
      ],
    );
  }
}
