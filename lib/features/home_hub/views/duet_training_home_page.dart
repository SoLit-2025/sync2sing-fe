import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';
import 'package:sync2sing/features/shared/logics/analysis_type.dart';
import 'package:sync2sing/features/shared/logics/dio_factory.dart';
import 'package:sync2sing/features/shared/views/custom_loading_page.dart';

import '../../shared/logics/secure_storage.dart';
import '../logics/room_item.dart';
import '../logics/training_session_status.dart';
import '../logics/training_item.dart';
import 'before_session_widget.dart';
import 'duet_song_section.dart';
import 'training_item_card.dart';

class DuetTrainingHomePage extends StatefulWidget {
  const DuetTrainingHomePage({super.key});

  @override
  State<DuetTrainingHomePage> createState() => _DuetTrainingHomePageState();
}

class _DuetTrainingHomePageState extends State<DuetTrainingHomePage> {
  late final DioFactory dioFactory;
  late final List<TrainingItem> items;
  final String nickname = "노래하는해파리";
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
  bool isFABVisible = false; // floatingActionButton 이 보이는지
  late final Room? room;

  final Map<String, dynamic> beforeSessionJson = {"data": <String, dynamic>{}};

  final Map<String, dynamic> beforeTrainingJson = // 훈련 생성 전
      {
    "status": 200,
    "message": "듀엣 트레이닝 세션 정보 조회에 성공했습니다.",
    "data": {
      "session_id": 7,
      "status": "BEFORE_TRAINING",
      "start_date": "2025-09-24T03:10:03",
      "end_date": "2025-09-30T03:10:03",
      "training_days": 7,
      "song": {
        "id": 6,
        "title": "Do-Re-Mi Duet Dong",
        "artist": "Richard Rodgers",
        "user_part_name": "철수",
      },
      "pre_recording_file_url": null,
      "post_recording_file_url": null,
      "curriculum": {"pitch": [], "rhythm": [], "pronunciation": []},
      "pre_recording_due_date": "2025-09-24T03:10:03",
      "post_recording_due_date": "2025-10-03T03:10:03",
      "duet_training_room": {
        "id": 5,
        "created_at": "2025-09-21T02:41:01",
        "training_days": 7,
        "song": {
          "id": 6,
          "title": "Do-Re-Mi Duet Dong",
          "artist": "Richard Rodgers",
          "album_art_url":
              "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/363161ac-62ed-4154-8577-3ff2245c7d0b.jpg",
        },
        "host_part": {
          "part_number": 1,
          "part_name": "철수",
          "voice_type": "SOPRANO",
          "pitch_note_min": "C4",
          "pitch_note_max": "D5",
        },
        "partner_part": {
          "part_number": 0,
          "part_name": "영희",
          "voice_type": "SOPRANO",
          "pitch_note_min": "C4",
          "pitch_note_max": "D5",
        },
      },
    },
  };

  final Map<String, dynamic> trainingInProgressJson = // 훈련 추천 생성 후
      {
    "status": 200,
    "message": "듀엣 트레이닝 세션 정보 조회에 성공했습니다.",
    "data": {
      "session_id": 7,
      "status": "TRAINING_IN_PROGRESS",
      "start_date": "2025-09-24T03:10:03",
      "end_date": "2025-09-30T03:10:03",
      "training_days": 7,
      "song": {
        "id": 6,
        "title": "Do-Re-Mi Duet Dong",
        "artist": "Richard Rodgers",
        "user_part_name": "철수",
      },
      "pre_recording_file_url": null,
      "post_recording_file_url": null,
      "curriculum": {
        "pitch": [
          {
            "id": 106,
            "category": "PITCH",
            "title": "세밀한 음정 조절 연습",
            "grade": "MEDIUM",
            "description": "반음 단위의 정확한 음정 조절 능력을 향상시킵니다.",
            "training_minutes": 5,
            "progress": 0,
            "current_training": true,
          },
          {
            "id": 109,
            "category": "PITCH",
            "title": "스케일 따라 부르기",
            "grade": "MEDIUM",
            "description": "도레미 패턴을 기반으로 음정 일관성을 높이는 훈련입니다.",
            "training_minutes": 5,
            "progress": 0,
            "current_training": false,
          },
        ],
        "rhythm": [
          {
            "id": 110,
            "category": "RHYTHM",
            "title": "리듬 감각 강화 훈련",
            "grade": "HIGH",
            "description": "박자 감각을 높이고 리듬 정확도를 향상시키는 훈련입니다.",
            "training_minutes": 5,
            "progress": 0,
            "current_training": true,
          },
          {
            "id": 111,
            "category": "RHYTHM",
            "title": "박자 일관성 연습",
            "grade": "HIGH",
            "description": "일관된 템포 유지 능력을 기르기 위한 반복 연습입니다.",
            "training_minutes": 5,
            "progress": 0,
            "current_training": false,
          },
        ],
        "pronunciation": [
          {
            "id": 115,
            "category": "PRONUNCIATION",
            "title": "자음 발음 훈련",
            "grade": "LOW",
            "description": "자음을 정확하게 발음하는 연습을 통해 발음을 또렷하게 합니다.",
            "training_minutes": 5,
            "progress": 0,
            "current_training": true,
          },
          {
            "id": 116,
            "category": "PRONUNCIATION",
            "title": "모음 길이 구분 연습",
            "grade": "LOW",
            "description": "짧은 모음과 긴 모음을 구분하여 발음하는 훈련입니다.",
            "training_minutes": 5,
            "progress": 0,
            "current_training": false,
          },
        ],
      },
      "pre_recording_due_date": "2025-09-24T03:10:03",
      "post_recording_due_date": "2025-10-03T03:10:03",
      "duet_training_room": {
        "id": 5,
        "created_at": "2025-09-21T02:41:01",
        "training_days": 7,
        "song": {
          "id": 6,
          "title": "Do-Re-Mi Duet Dong",
          "artist": "Richard Rodgers",
          "album_art_url":
              "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/363161ac-62ed-4154-8577-3ff2245c7d0b.jpg",
        },
        "host_part": {
          "part_number": 1,
          "part_name": "철수",
          "voice_type": "SOPRANO",
          "pitch_note_min": "C4",
          "pitch_note_max": "D5",
        },
        "partner_part": {
          "part_number": 0,
          "part_name": "영희",
          "voice_type": "SOPRANO",
          "pitch_note_min": "C4",
          "pitch_note_max": "D5",
        },
      },
    },
  };

  int calculateTotalProgressFromItems(List<TrainingItem> items) {
    // totalProgress 계산
    if (items.isEmpty) return 0;
    final total = items.fold<int>(0, (sum, e) => sum + e.progress);
    return (total / items.length).round();
  }

  Future<Map<String, dynamic>> _fetchSessionInfo() async {
    await Future.delayed(Duration(milliseconds: 5));
    final Map<String, dynamic> data =
        beforeSessionJson; //beforeTrainingJson; beforeSessionJson trainingInProgressJson

    final Map<String, dynamic> jsonData = data['data'] as Map<String, dynamic>;
    debugPrint("jsonData type: ${jsonData.runtimeType}");
    trainingSessionStatus = _getDataFromResponse(jsonData); // TrainingSessionStatus

    debugPrint("trainingSessionStatus: $trainingSessionStatus}");
    if (trainingSessionStatus != TrainingSessionStatus.beforeSession) {
      room =
          jsonData['duet_training_room'] != null
              ? Room.fromJson(jsonData['duet_training_room'])
              : null;
    }
    return jsonData;

    // dioFactory = DioFactory(SecureStorage());
    //
    // try {
    //   final response = await dioFactory.get('/duet-training/session');
    //
    //   debugPrint("duetHome: response - ${response.data}");
    //   trainingSessionStatus = _getDataFromResponse(response.data['data']);
    //
    //   return response.data['data'];
    // } on DioException catch (e) {
    //   debugPrint("error2: ${e.response}");
    //   throw Exception(e.response);
    // }
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

  void _isRoomHost(bool result) async {
    // 사용자가 방 주인이 아닌 경우에만 FAB 보임
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 페이지 빌드 이후 setState()
      setState(() {
        isFABVisible = !result;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    // todo: 리턴값 타입 변경(not Map) / trainingSession 을 반환값으로 받기
    responseData = _fetchSessionInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grayscale8,
      body: SafeArea(
        child: FutureBuilder(
          future: responseData,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              final errorString = snapshot.error.toString();
              debugPrint("결과: ${snapshot.error.toString()}");

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

              DateTime? dateTime;
              String? userPartName;

              if (trainingSessionStatus != TrainingSessionStatus.beforeSession) {
                dateTime =
                    snapshot.data['pre_recording_due_date'] != null
                        ? DateTime.parse(snapshot.data['pre_recording_due_date'])
                        : null;
                userPartName = snapshot.data['song']['user_part_name'] ?? '';
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMainHeader(), // 상단 배너
                    Padding(
                      padding: EdgeInsets.fromLTRB(31.w, 5.4.h, 31.w, 10.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 12.h),
                          (trainingSessionStatus == TrainingSessionStatus.beforeSession)
                              ? BeforeSessionWidget(isRoomHost: _isRoomHost) // 콜백함수 전달
                              : (trainingSessionStatus == TrainingSessionStatus.beforeTraining)
                              ? _buildBeforeTraining(room, dateTime!, userPartName!)
                              : _buildExistSessionHome(),
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

      floatingActionButton:
          (isFABVisible)
              ? Container(
                width: 74.r,
                height: 74.r,
                margin: EdgeInsets.only(bottom: 12.h, right: 10.w),
                child: FittedBox(
                  child: FloatingActionButton(
                    onPressed: () async {
                      await context.push(AppRoutePaths.duetTrainingSetting);
                    },
                    elevation: 0,
                    foregroundColor: AppColors.grayscale8,
                    backgroundColor: AppColors.primaryPink,
                    shape: CircleBorder(),
                    focusElevation: 0,
                    hoverElevation: 0,
                    highlightElevation: 0,
                    child: Icon(CupertinoIcons.add, size: 42.r),
                  ),
                ),
              )
              : null,
    );
  }

  Widget _buildMainHeader() {
    // 상단 배너
    return Container(
      color: AppColors.grayscale8,
      width: double.infinity,
      height: 272.h,
      child: Stack(
        alignment: Alignment.centerRight,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -64.84.w,
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
            alignment: Alignment.topRight,
            padding: EdgeInsets.only(right: 24.w, top: 95.h),
            child: Text(
              (trainingSessionStatus == TrainingSessionStatus.trainingInProgress ||
                      trainingSessionStatus == TrainingSessionStatus.afterTraining)
                  ? "$nickname 님,\n진행중인\n트레이닝이 있어요"
                  : (trainingSessionStatus == TrainingSessionStatus.beforeSession)
                  ? "$nickname 님,\n원하는 연습실에\n참여해보세요"
                  : '$nickname 님,\n맞춤형 훈련을\n추천받아보세요', // beforeTraining 시
              style: AppTextStyles.heading2Bold,
              textAlign: TextAlign.right,
            ),
          ),
          // ),
        ],
      ),
    );
  }

  Widget _buildExistSessionHome() {
    // beforeSession || beforeTraining -> 노출되지 x
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Training 진행 현황
        RichText(
          text: TextSpan(
            style: AppTextStyles.body1Bold,
            children: [
              TextSpan(text: "트레이닝 진행현황  ", style: TextStyle(color: AppColors.grayscale2)),
              TextSpan(text: "$totalProgress%", style: TextStyle(color: AppColors.primaryPink)),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        ...switch (trainingSessionStatus) {
          TrainingSessionStatus.beforeSession => [],
          TrainingSessionStatus.beforeTraining => [],
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
                  "${AppRoutePaths.songExampleVideo}/duet/${AnalysisType.post.name}/$songId",
                );
              },
            ),
            Container(
              width: 16.w,
              height: 16.h,
              margin: EdgeInsets.only(left: 16.w),
              color: AppColors.grayscale6,
            ),
            _curriculumListView(),
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
        }, // Training 진행 현황
      ],
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
                backGroundColor: AppColors.grayscale7,
              ),
            ); //
          },
        );
  }

  // Widget _buildBeforeTraining(Map<String, dynamic> responseData) {
  Widget _buildBeforeTraining(Room? room, DateTime recordingDueDate, String userPartName) {
    if (room == null) return Text("연습실 정보를 불러오지 못했습니다");
    // Room room = Room.fromJson(roomJson);
    // DateTime recordingDueDate = DateTime.parse(responseData['pre_recording_due_date']);
    // final String userPartName = responseData['song']['user_part_name'];

    final bool isHostPart = (userPartName == room.hostPart.partName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment(-1, -1),
          child: Text(
            "참여중인 연습실",
            style: AppTextStyles.heading3Bold.copyWith(color: AppColors.grayscale2),
          ),
        ),
        SizedBox(height: 8.h),
        DuetSongSection(
          title: room.song.title,
          id: room.song.id,
          artist: room.song.artist,
          voiceType: isHostPart ? room.hostPart.voiceType : room.partnerPart.voiceType,
          albumArtUrl: room.song.albumArtUrl,
          partName: userPartName,
        ),
        SizedBox(height: 8.h),
        Text(
          "${recordingDueDate.year}. ${recordingDueDate.month}. ${recordingDueDate.day}. 까지 AI 보컬 진단을 완료하면 훈련이 시작돼요",
          style: AppTextStyles.body5.copyWith(color: AppColors.grayscale3),
        ),
        CupertinoButton(
          padding: EdgeInsets.symmetric(vertical: 4.h),

          onPressed: () {
            context.go("${AppRoutePaths.songExampleVideo}/duet/pre/${room.song.id}");
          },
          child: Container(
            alignment: Alignment.center,
            width: 300.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: AppColors.primaryPink,
              borderRadius: BorderRadius.circular(30.r),
            ),
            margin: EdgeInsets.only(top: 12.h),
            child: Text("진단하러 가기", style: AppTextStyles.body2BoldWhite),
          ),
        ),
      ],
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
