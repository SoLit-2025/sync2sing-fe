// import 'dart:convert';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';
import 'package:sync2sing/features/home_hub/logics/nickname_get_provider.dart';
import 'package:sync2sing/features/shared/logics/analysis_type.dart';
import 'package:sync2sing/features/shared/logics/dio_factory.dart';
import 'package:sync2sing/features/shared/views/custom_loading_page.dart';

import '../../shared/logics/secure_storage.dart';
import '../logics/training_session_status.dart';
import '../logics/training_item.dart';
import 'training_item_card.dart';

class SoloTrainingHomePage extends StatefulWidget {
  const SoloTrainingHomePage({super.key});

  @override
  State<SoloTrainingHomePage> createState() => _SoloTrainingHomePageState();
}

class _SoloTrainingHomePageState extends State<SoloTrainingHomePage> {
  late final DioFactory dioFactory;
  late final List<TrainingItem> items;
  late final Future<Map<String, dynamic>> responseData;
  late final int totalProgress;
  late final TrainingSessionStatus trainingSessionStatus;
  late final int? sessionId;
  late final int? songId;
  late int selectedIdx = // 버튼이 보이는 위젯 인덱스 == 클릭한 위젯의 인덱스
      (trainingSessionStatus == TrainingSessionStatus.trainingInProgress)
          ? 0 // 트레이닝 진행 중일 때: 첫 진입에는 0번 인덱스만 버튼 보임
          : -1; // 그 외는 기본 카드만 버튼이 보임)
  late final String _apiMessage;

  int calculateTotalProgressFromItems(List<TrainingItem> items) {
    // totalProgress 계산
    if (items.isEmpty) return 0;
    final total = items.fold<int>(0, (sum, e) => sum + e.progress);
    return (total / items.length).round();
  }

  Future<Map<String, dynamic>> _fetchSessionInfo() async {
    dioFactory = DioFactory(SecureStorage());
    try {
      final response = await dioFactory.get('/solo-training/session');

      debugPrint("soloHome: response - ${response.data}");
      trainingSessionStatus = _getDataFromResponse(response.data['data']);

      return response.data['data'];
    } on DioException catch (e) {
      debugPrint("error2: ${e.response}");
      throw Exception(e.response);
    }
  }

  TrainingSessionStatus _getDataFromResponse(Map<String, dynamic> responseBody) {
    debugPrint("responseBody - data: $responseBody");
    var tTrainingSessionStatus = getTrainingStatusFromJson(responseBody);
    switch (tTrainingSessionStatus) {
      case TrainingSessionStatus.beforeSession:
      case TrainingSessionStatus.beforeTraining:
        // 아직 트레이닝 시작 전 --> 진행 0.
        totalProgress = 0;
        break;
      case TrainingSessionStatus.afterTraining:
      case TrainingSessionStatus.trainingInProgress:
        sessionId = responseBody['session_id'];
        items = parseCurriculumItemsInOrderAndPostCompletedLast(responseBody['curriculum']);
        totalProgress = calculateTotalProgressFromItems(items);
        if (totalProgress >= 100) tTrainingSessionStatus = TrainingSessionStatus.afterTraining;
        // 만약 트레이닝진행 현황이 100% -> afterTraining 처럼 보이게.
        break;
      case TrainingSessionStatus.error:
        totalProgress = 0;
    }

    if (tTrainingSessionStatus != TrainingSessionStatus.beforeSession) {
      songId = responseBody['song']['id'];
    }
    return tTrainingSessionStatus;
  }

  void onCardTap(int idx) {
    // trainingInProgress 가 아니면 카드를 클릭해도 버튼이 보이지 x
    if (trainingSessionStatus != TrainingSessionStatus.trainingInProgress) return;
    // 선택한 항목이 완료(progress >= 100)면 무시
    if (items[idx].progress >= 100) return;

    setState(() {
      selectedIdx = idx; // 클릭한 위젯 인덱스로 selectedIdx 업데이트
    });
  }

  @override
  void initState() {
    super.initState();
    responseData = _fetchSessionInfo(); // api 요청 응답 받기
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grayscale7,
      body: SafeArea(
        child: FutureBuilder(
          future: responseData,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              final errorString = snapshot.error.toString();

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
              // 응답이 오지 않았으면
              return CustomLoading();
            } else {
              // 응답이 정상적으로 온 경우
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer(
                      builder: (context, ref, child) {
                        final nickname = ref.watch(nicknameGetProvider);
                        return nickname.when(
                          data: (data) => _buildMainHeader(data), // nickname이 존재하면
                          error: (e, stackTrace) => _buildMainHeader("error"), // 불러오는데 실패하면
                          loading: () => _buildMainHeader(""), // 불러오는 중이면
                        );
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(31.w, 5.4.h, 31.w, 10.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 12.h),

                          // Training 진행 현황
                          RichText(
                            text: TextSpan(
                              style: AppTextStyles.body1Bold,
                              children: [
                                TextSpan(
                                  text: "트레이닝 진행현황  ",
                                  style: TextStyle(color: AppColors.grayscale2),
                                ),
                                TextSpan(
                                  text: "$totalProgress%",
                                  style: TextStyle(color: AppColors.primaryPink),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 12.h),
                          ...switch (trainingSessionStatus) {
                            TrainingSessionStatus.beforeSession => [
                              SessionOptionCard(
                                category: "트레이닝 준비",
                                title: "STEP1. 연습곡 선택",
                                desc: "연습곡과 연습기간을 선택하면 맞춤형 훈련을 추천받을 수 있어요",
                                buttonText: "솔로 트레이닝 시작하기",
                                isMicReq: false,
                                onPressed: () {
                                  context.push(AppRoutePaths.soloTrainingSetting);
                                },
                              ),
                              SizedBox(height: 17.h),
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "진단이 완료되면 나에게 맞는 훈련을 추천받을 수 있어요",
                                  style: AppTextStyles.body5.copyWith(color: AppColors.grayscale3),
                                ),
                              ),
                            ],
                            TrainingSessionStatus.beforeTraining => [
                              SessionOptionCard(
                                category: "트레이닝 준비",
                                title: "STEP2. AI 보컬 진단",
                                desc: "AI가 트레이닝 전후를 비교해 나만의 성장 리포트를 제공해요",
                                buttonText: "진단하러 가기",
                                isMicReq: true,
                                onPressed: () {
                                  context.go("${AppRoutePaths.songExampleVideo}/solo/pre/$songId");
                                },
                              ),
                              SizedBox(height: 17.h),
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "진단이 완료되면 나에게 맞는 훈련을 추천받을 수 있어요",
                                  style: AppTextStyles.body5.copyWith(color: AppColors.grayscale3),
                                ),
                              ),
                            ],
                            TrainingSessionStatus.trainingInProgress => [_curriculumListView()],
                            TrainingSessionStatus.afterTraining => [
                              SessionOptionCard(
                                category: "트레이닝 마무리",
                                title: "AI 보컬 진단",
                                desc: "AI가 트레이닝 전후를 비교해 나만의 성장 리포트를 제공해요",
                                buttonText: "진단하러 가기",
                                isMicReq: true,
                                onPressed: () {
                                  context.go(
                                    "${AppRoutePaths.songExampleVideo}/solo/${AnalysisType.post.name}/$songId",
                                  );
                                },
                              ),
                              if (items.isNotEmpty)
                                Column(
                                  children: [
                                    Container(
                                      width: 16.w,
                                      height: 16.h,
                                      margin: EdgeInsets.only(left: 16.w),
                                      color: AppColors.grayscale6,
                                    ),
                                    _curriculumListView(),
                                  ],
                                ),
                            ],
                            TrainingSessionStatus.error => [
                              SessionOptionCard(
                                category: "",
                                title: "데이터를 조회하지 못했습니다.",
                                desc: "통신 오류로 인해 데이터를 조회하지 못했습니다. $_apiMessage",
                                buttonText: "홈으로 가기",
                                isMicReq: false,
                                onPressed: () {
                                  context.go(AppRoutePaths.mainHome);
                                },
                              ),
                            ],
                          },
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildMainHeader(String nickname) {
    // 상단 배너
    return Container(
      color: AppColors.grayscale8,
      height: 272.h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -64.84.w,
            top: 28.81.h,
            child: Transform.rotate(
              angle: 0.22,
              child: Image.asset(
                'assets/images/solo_training_home_cherry_image.png',
                width: 205.03.r,
                height: 205.03.r,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(left: 24.w, top: 95.h),
            child: Text(
              (trainingSessionStatus == TrainingSessionStatus.trainingInProgress ||
                      trainingSessionStatus == TrainingSessionStatus.afterTraining)
                  ? "$nickname 님,\n진행중인\n트레이닝이 있어요"
                  : "$nickname 님,\n맞춤형 훈련을\n추천받아보세요",
              style: AppTextStyles.heading2Bold,
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget _curriculumListView() {
    // trainingInProgress 상태의 커리큘럼 카드 리스트.
    return items.isEmpty
        ? Center(child: Text('커리큘럼 정보가 없습니다')) // 커리큘럼 리스트가 존재하지 않으면
        : ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(), // 리스트뷰 내의 스크롤 방지
          itemCount: items.length,
          separatorBuilder: // 리스트 아이템 사이의 요소: 위젯 사이의 막대
              (_, __) => Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 16.w,
                  height: 16.h,
                  margin: EdgeInsets.only(left: 16.w),
                  color: AppColors.grayscale6,
                ),
              ),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => onCardTap(index),
              child: TrainingItemCard(
                trainingItem: items[index],
                sessionId: sessionId!,
                showButton: selectedIdx == index,
              ),
            ); //
          },
        );
  }
}

class SessionOptionCard extends StatelessWidget {
  // 특정 세션 상태일 때 보여지는 카드
  final String category; // 상단 분홍 글씨
  final String title; // 가장 큰 bold 체
  final String desc;
  final String buttonText;
  final bool isMicReq; // 마이크가 필요한지 여부
  final VoidCallback onPressed;

  const SessionOptionCard({
    super.key,
    required this.category,
    required this.title,
    required this.desc,
    required this.buttonText,
    required this.isMicReq,
    required this.onPressed,
  });

  Widget _trainingCardTop() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(category, style: AppTextStyles.body5Bold.copyWith(color: AppColors.primaryPink)),
        if (isMicReq)
          Row(
            children: [
              Text("마이크 사용 필요 ", style: AppTextStyles.body6.copyWith(color: AppColors.grayscale4)),
              Image.asset(
                'assets/images/training_card_mic_icon.png',
                width: 15.r,
                height: 16.r,
                fit: BoxFit.contain,
                color: AppColors.grayscale4,
              ),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 150.h,
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 5.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: AppColors.grayscale8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _trainingCardTop(),

              SizedBox(height: 3.h),
              RichText(
                text: TextSpan(
                  style: AppTextStyles.body5,
                  children: [
                    TextSpan(
                      text: "$title\n",
                      style: AppTextStyles.body1Bold.copyWith(fontSize: 18.sp),
                    ),
                    TextSpan(text: desc, style: TextStyle(color: AppColors.grayscale3)),
                  ],
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.symmetric(vertical: 4.h),

                onPressed: onPressed,
                child: Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: AppColors.primaryPink,
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  margin: EdgeInsets.only(top: 12.h),
                  child: Text(buttonText, style: AppTextStyles.body2BoldWhite),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
