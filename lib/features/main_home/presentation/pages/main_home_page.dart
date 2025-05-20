import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';
import 'package:sync2sing/shared/widgets/common_bottom_navigation_bar.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({Key? key}) : super(key: key);

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  final String nickname = "노래하는 해파리";
  final bool hasSoloTraining = true;
  final bool hasDuetTraining = false;
  final int soloDDay = 3;
  final int duetDDay = 0;

  int _soloActiveCardIndex = 0;
  int _duetActiveCardIndex = 0;

  final PageController _soloPageController = PageController();
  final PageController _duetPageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(
                left: 24.w,
                right: 24.w,
                top: 40.h,
                bottom: 24.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMainHeader(),
                  SizedBox(height: 40.h),
                  _buildSoloTrainingSection(),
                  SizedBox(height: 40.h),
                  _buildDuetTrainingSection(),
                  SizedBox(height: 80.h),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: EdgeInsets.only(bottom: 0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: const CommonBottomNavigationBar(currentIndex: 0),
        ),
      ),
    );
  }

  Widget _buildMainHeader() {
    bool hasAnyTraining = hasSoloTraining || hasDuetTraining;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          right: -70.w,
          top: -50.h,
          child: Image.asset(
            'assets/images/main_home_mic_image.png',
            width: 190.w,
            height: 190.h,
            fit: BoxFit.contain,
          ),
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(right: 100.w),
          child: Text(
            hasAnyTraining
                ? "$nickname 님,\n진행중인\n트레이닝이 있어요"
                : "$nickname 님,\n지금 바로\n트레이닝을 시작해보세요",
            style: AppTextStyles.heading2Bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSoloTrainingSection() {
    final List<Map<String, String>> trainings =
        hasSoloTraining
            ? [
              {
                'category': '음정',
                'title': '스타카토',
                'description': '짧게 끊어 내는 소리 연습하기',
              },
              {
                'category': '호흡',
                'title': '레가토',
                'description': '부드럽게 이어지는 호흡 연습',
              },
              {
                'category': '발성',
                'title': '벨팅',
                'description': '성량을 높이는 발성 연습하기',
              },
            ]
            : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hasSoloTraining ? "솔로 트레이닝 D-$soloDDay" : "솔로 트레이닝",
          style: AppTextStyles.heading3Bold,
        ),
        SizedBox(height: 12.h),
        Column(
          children: [
            SizedBox(
              height: 180.h,
              child: PageView.builder(
                controller: _soloPageController,
                itemCount: trainings.isNotEmpty ? trainings.length : 1,
                onPageChanged: (index) {
                  setState(() {
                    _soloActiveCardIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  if (trainings.isNotEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: _buildActiveTrainingCard(
                        category: trainings[index]['category'] ?? '',
                        title: trainings[index]['title'] ?? '',
                        description: trainings[index]['description'] ?? '',
                        buttonText: "연습하러 가기",
                        onPressed: () {},
                        width: 327.w,
                      ),
                    );
                  } else {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: _buildEmptyTrainingCard(
                        message: "진행중인 트레이닝이 없어요",
                        buttonText: "맞춤형 커리큘럼 생성하기",
                        onPressed: () {},
                      ),
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 16.h),
            if (trainings.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  trainings.length,
                  (index) => _buildPageIndicator(index == _soloActiveCardIndex),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildDuetTrainingSection() {
    final List<Map<String, String>> trainings =
        hasDuetTraining
            ? [
              {
                'category': '음정',
                'title': '하모니',
                'description': '듀엣 곡을 조화롭게 부르기',
              },
              {
                'category': '리듬',
                'title': '박자 맞추기',
                'description': '함께 박자를 맞추는 연습',
              },
            ]
            : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hasDuetTraining ? "듀엣 트레이닝 D-$duetDDay" : "듀엣 트레이닝",
          style: AppTextStyles.heading3Bold,
        ),
        SizedBox(height: 12.h),
        Column(
          children: [
            SizedBox(
              height: 180.h,
              child: PageView.builder(
                controller: _duetPageController,
                itemCount: trainings.isNotEmpty ? trainings.length : 1,
                onPageChanged: (index) {
                  setState(() {
                    _duetActiveCardIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  if (trainings.isNotEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: _buildActiveTrainingCard(
                        category: trainings[index]['category'] ?? '',
                        title: trainings[index]['title'] ?? '',
                        description: trainings[index]['description'] ?? '',
                        buttonText: "연습하러 가기",
                        onPressed: () {},
                        width: 327.w,
                      ),
                    );
                  } else {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: _buildEmptyTrainingCard(
                        message: "진행중인 트레이닝이 없어요",
                        buttonText: "맞춤형 커리큘럼 생성하기",
                        onPressed: () {},
                      ),
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 16.h),
            if (trainings.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  trainings.length,
                  (index) => _buildPageIndicator(index == _duetActiveCardIndex),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildPageIndicator(bool isActive) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      height: 8.h,
      width: 8.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? AppColors.primaryRed : AppColors.grayscale5,
      ),
    );
  }

  Widget _buildActiveTrainingCard({
    required String category,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onPressed,
    required double width,
  }) {
    return Container(
      width: width,
      height: 180.h,
      decoration: BoxDecoration(
        color: AppColors.grayscale7,
        borderRadius: BorderRadius.circular(10.r),
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category,
            style: AppTextStyles.body3.copyWith(color: AppColors.primaryRed),
          ),
          SizedBox(height: 4.h),
          Text(title, style: AppTextStyles.heading4Bold),
          SizedBox(height: 4.h),
          Text(
            description,
            style: AppTextStyles.body1.copyWith(color: AppColors.grayscale3),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                buttonText,
                style: AppTextStyles.body1Bold.copyWith(
                  color: AppColors.grayscale8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTrainingCard({
    required String message,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 327.w,
      height: 180.h,
      decoration: BoxDecoration(
        color: AppColors.grayscale7,
        borderRadius: BorderRadius.circular(10.r),
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: Text(
                message,
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.grayscale3,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                buttonText,
                style: AppTextStyles.body1Bold.copyWith(
                  color: AppColors.grayscale8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
