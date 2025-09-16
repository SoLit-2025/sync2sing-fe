import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:sync2sing/features/shared/logics/dio_factory.dart';
import 'package:sync2sing/features/shared/logics/secure_storage.dart';
import 'package:sync2sing/features/shared/views/custom_loading_page.dart';
import 'package:sync2sing/features/home_hub/logics/training_session_status.dart';
import 'package:sync2sing/features/shared/views/page_indicator.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({Key? key}) : super(key: key);

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  final String nickname = "노래하는 해파리";
  late final Future<Map<String, dynamic>> _trainingData;
  late final DioFactory dioFactory;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<String> _categoryOrder = ['PITCH', 'RHYTHM', 'PRONUNCIATION', 'BREATH']; // 카테고리 순서 정의

  @override
  void initState() {
    super.initState();
    _trainingData = _fetchTrainingData();
  }

  Future<Map<String, dynamic>> _fetchTrainingData() async {
    dioFactory = DioFactory(SecureStorage());
    final response = await dioFactory.get('/training/trainings/in-progress');

    debugPrint("MainHome: response - ${response.data}");
    if (response.statusCode == 200) {
      return response.data['data'];
    } else {
      throw Exception('API 요청 실패: ${response.data['message']}');
    }
  }

  // 솔로 트레이닝 상태 확인
  bool _hasSoloTraining(Map<String, dynamic> soloData) {
    return soloData.isNotEmpty;
  }

  // 듀엣 트레이닝 상태 확인 (지금은 항상 false)
  bool _hasDuetTraining(Map<String, dynamic> duetData) {
    return duetData.isNotEmpty;
  }

  // 카테고리 순서대로 솔로 데이터 정리
  List<Map<String, dynamic>> _getOrderedSoloTrainingList(Map<String, dynamic> soloData) {
    List<Map<String, dynamic>> orderedList = [];

    for (String category in _categoryOrder) {
      if (soloData.containsKey(category)) {
        orderedList.add(soloData[category] as Map<String, dynamic>);
      }
    }

    return orderedList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _trainingData,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildErrorWidget(snapshot.error.toString());
            } else if (snapshot.hasData == false) {
              return CustomLoading();
            } else {
              final data = snapshot.data!;
              final soloData = data['solo'] as Map<String, dynamic>;
              final duetData = data['duet'] as Map<String, dynamic>;

              return SingleChildScrollView(
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
                        _buildMainHeader(soloData, duetData),
                        SizedBox(height: 45.h),
                        _buildSoloTrainingSection(soloData),
                        SizedBox(height: 40.h),
                        _buildDuetTrainingSection(duetData),
                        SizedBox(height: 80.h),
                      ],
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "데이터를 불러올 수 없습니다",
              style: AppTextStyles.heading3Bold,
            ),
            SizedBox(height: 16.h),
            Text(
              error,
              style: AppTextStyles.body1.copyWith(color: AppColors.grayscale3),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: 300.w,
              height: 50.h,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  setState(() {
                    _trainingData = _fetchTrainingData();
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primaryPink,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    "다시 시도",
                    style: AppTextStyles.body1BoldWhite,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainHeader(Map<String, dynamic> soloData, Map<String, dynamic> duetData) {
    bool hasAnyTraining = _hasSoloTraining(soloData) || _hasDuetTraining(duetData);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          right: -64.84.w,
          top: -15.6.h,
          child: Image.asset(
            'assets/images/main_home_mic_image.png',
            width: 190.w,
            height: 190.h,
            fit: BoxFit.contain,
          ),
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(top: 55.h),
          child: Text(
            hasAnyTraining
                ? "$nickname 님,\n진행중인\n트레이닝이 있어요"
                : "$nickname 님,\n지금 바로\n트레이닝을 시작해보세요",
            style: AppTextStyles.heading2Bold,
            textAlign: TextAlign.left,
            softWrap: false,
          ),
        ),
      ],
    );
  }

  Widget _buildSoloTrainingSection(Map<String, dynamic> soloData) {
    final hasSolo = _hasSoloTraining(soloData);
    final orderedTrainingList = _getOrderedSoloTrainingList(soloData);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w),
          child: Text(
            hasSolo ? "솔로 트레이닝 진행 중" : "솔로 트레이닝",
            style: AppTextStyles.heading3Bold,
            textAlign: TextAlign.left,
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: hasSolo ? 210.h : 180.h,
          child: hasSolo
              ? PageView.builder(
            controller: _pageController,
            onPageChanged: (int page){
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: orderedTrainingList.length,
            itemBuilder: (context, index) {
              final training = orderedTrainingList[index];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: _buildActiveTrainingCard(
                  category: categoryKr[training['category'].toString().toLowerCase()] ?? training['category'],
                  title: training['title'],
                  description: training['description'],
                  buttonText: "연습하러 가기",
                  onPressed: () {
                    context.push(AppRoutePaths.soloTrainingHome);
                  },
                  width: 327.w,
                ),
              );
            },
          )
              : Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: _buildEmptyTrainingCard(
              message: "진행중인 트레이닝이 없어요",
              buttonText: "맞춤형 커리큘럼 생성하기",
              onPressed: () {
                context.push(AppRoutePaths.soloTrainingHome);
              },
            ),
          ),
        ),
        // 페이지 인디케이터
        if (hasSolo && orderedTrainingList.length > 1)
          SizedBox(height: 8.h),
        if (hasSolo && orderedTrainingList.length > 1)
          Center(
            child: PageIndicator(
              currentPage: _currentPage.toDouble(),
              pageCount: orderedTrainingList.length,
            ),
          ),
      ],
    );
  }



  Widget _buildDuetTrainingSection(Map<String, dynamic> duetData) {
    final hasDuet = _hasDuetTraining(duetData);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w),
          child: Text(
            hasDuet ? "듀엣 트레이닝 진행 중" : "듀엣 트레이닝",
            style: AppTextStyles.heading3Bold,
            textAlign: TextAlign.left,
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 180.h,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: _buildEmptyTrainingCard(
              message: "진행중인 트레이닝이 없어요",
              buttonText: "맞춤형 커리큘럼 생성하기",
              onPressed: () {
                context.push(AppRoutePaths.duetTrainingHome);
              },
            ),
          ),
        ),
      ],
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
      height: 210.h,
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
            style: AppTextStyles.body3.copyWith(color: AppColors.primaryPink),
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: AppTextStyles.heading4Bold,
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 4.h),
          Text(
            description,
            style: AppTextStyles.body1.copyWith(color: AppColors.grayscale3),
            textAlign: TextAlign.left,
          ),
          const Spacer(),
          Center(
            child: SizedBox(
              width: 300.w,
              height: 50.h,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 0,
                onPressed: onPressed,
                child: Container(
                  alignment: Alignment.center,
                  width: 300.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: AppColors.primaryPink,
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: Text(
                    buttonText,
                    style: AppTextStyles.body1BoldWhite,
                    textAlign: TextAlign.center,
                  ),
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
      height: 180.h,
      width: 327.w,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: AppColors.grayscale7,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 32.h),
          Center(
            child: Text(
              message,
              style: AppTextStyles.body1.copyWith(color: AppColors.grayscale3),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 18.h),
          Center(
            child: SizedBox(
              width: 300.w,
              height: 50.h,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 0,
                onPressed: onPressed,
                child: Container(
                  alignment: Alignment.center,
                  width: 300.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: AppColors.primaryPink,
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: Text(buttonText, style: AppTextStyles.body1BoldWhite,
                    textAlign: TextAlign.center,),

                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
