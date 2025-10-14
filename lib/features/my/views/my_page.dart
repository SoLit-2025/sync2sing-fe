import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/features/curriculum/logics/song_detail_model.dart';
import 'package:sync2sing/features/shared/logics/dio_factory.dart';
import 'package:sync2sing/features/shared/logics/secure_storage.dart';
import 'package:sync2sing/features/shared/logics/training_mode.dart';
import 'package:sync2sing/features/shared/views/custom_loading_page.dart';
import 'package:sync2sing/features/shared/views/voice_range_display.dart';

class _ReportOverviewData {
  String title;
  int id;
  _ReportOverviewData({required this.id, required this.title});

  factory _ReportOverviewData.fromJson(Map<String, dynamic> json) {
    return _ReportOverviewData(id: json['report_id'] ?? -1, title: json['title'] ?? '');
  }
}

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  int? _pressedReportIndex;
  TrainingMode? _pressedReportMode;
  late final Future<Map<String, dynamic>> _userData;
  List<_ReportOverviewData> _soloReports = [];
  List<_ReportOverviewData> _duetReports = [];
  String nickname = "";
  bool _isNicknameEditing = false;
  late TextEditingController _nicknameController;

  Future<Map<String, dynamic>> _fetchUserData() async {
    final response = await DioFactory(SecureStorage()).get('/user');
    return response.data['data'];

    // 보분리 api 요청까지도 완료 후 아래 삭제 예정
    // await Future.delayed(Duration(milliseconds: 5));
    // final Map<String, dynamic> userJson = {
    //   // 듀엣 패널티가 없을 경우
    //   "status": "200",
    //   "message": "회원 정보 조회 성공",
    //   "data": {
    //     "username": "user@example.com",
    //     "nickname": "노래하는 해파리",
    //     "gender": "FEMALE",
    //     "age": 26,
    //     "pitch_note_min": "C3",
    //     "pitch_note_max": "G5",
    //     "voice_type": "SOPRANO",
    //     "duet_penalty_count": 0,
    //     "duet_penalty_until": null,
    //     "total_training_minutes": 30, // 총 훈련한 시간(연습량)
    //     "total_training_count": 12, // 총 훈련 개수(훈련 개수)
    //   },
    // };
    // return userJson['data'];
  }

  Future<List<_ReportOverviewData>> _fetchSoloReportData() async {
    // final response = await DioFactory(SecureStorage()).get('/user/reports?mode=solo');
    // final reportsJsonList = response.data['data'] as List;

    await Future.delayed(Duration(milliseconds: 5));
    final Map<String, dynamic> reportsJson = {
      "status": 200,
      "message": "솔로 보컬 분석 리포트 목록 조회에 성공했습니다.",
      "data": [
        {"report_id": 790, "title": "2025-04-07 Shape of You"},
        {"report_id": 789, "title": "2025-04-01 Shape of You"},
        {"report_id": 39, "title": "2025-03-15 Do-Re-Mi Solo Song"},
      ],
    };
    final reportsJsonList = reportsJson['data'] as List;

    final reportsList = reportsJsonList.map((e) => _ReportOverviewData.fromJson(e)).toList();
    return reportsList;
  }

  Future<List<_ReportOverviewData>> _fetchDuetReportData() async {
    // final response = await DioFactory(SecureStorage()).get('/user/reports?mode=duet');
    // final reportsJsonList = response.data['data'] as List;

    await Future.delayed(Duration(milliseconds: 5));
    final Map<String, dynamic> reportsJson = // 듀엣 보컬 분석 리포트 목록 조회
        {
      "status": 200,
      "message": "듀엣 보컬 분석 리포트 목록 조회에 성공했습니다.",
      "data": [
        {"report_id": 155, "title": "2025-05-13 Popular (From 'Wicked')"},
        {"report_id": 150, "title": "2025-05-07 Golden (From 'K-POP Demon Hunters')"},
      ],
    };
    final reportsJsonList = reportsJson['data'] as List;

    final reportsList = reportsJsonList.map((e) => _ReportOverviewData.fromJson(e)).toList();
    return reportsList;
  }

  void _loadReports() async {
    final results = await Future.wait([_fetchSoloReportData(), _fetchDuetReportData()]);
    setState(() {
      _soloReports = results[0];
      _duetReports = results[1];
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _applyNicknameChange() async {
    // 닉네이 텍스트 필드 -> 밖 클릭
    final newNickname = _nicknameController.text.trim();
    if (newNickname != nickname && newNickname.isNotEmpty) {
      if (!validateNickname(newNickname)) {
        return;
      }

      final success = await _submitNicknameChange(newNickname);
      if (!mounted) return;
      if (success) {
        setState(() {
          _isNicknameEditing = false;
        });
      }
    } else {
      setState(() => _isNicknameEditing = false);
    }
  }

  Future<bool> _submitNicknameChange(String? newNickname) async {
    // 닉네임 수정 api 요청
    try {
      DioFactory dio = DioFactory(SecureStorage());
      var response = await dio.put('/user', data: jsonEncode({'nickname': newNickname}));
      final updatedNickname = response.data['data']['nickname'];
      if (!mounted) return false;
      setState(() {
        nickname = updatedNickname;
        _nicknameController.text = updatedNickname; // 컨트롤러도 최신 값으로 갱신
      });
      return true;
    } on DioException catch (e) {
      int? statusCode = e.response?.statusCode;
      if (statusCode == 400 || statusCode == 401 || statusCode == 404) {
        _showError(e.response?.data['message']);
      }
      _showError("닉네임 수정에 실패했습니다. 다시 시도해주세요.");
      return false;
    }
  }

  bool validateNickname(String value) {
    // 1. 허용 문자: 한글+영문만, 공백 불가
    final isValidCharacters = RegExp(r'^[가-힣a-zA-Z]+$').hasMatch(value);
    final hasSpace = value.contains(' ');
    // 2. 길이 제한: 8자 이내
    final isLengthValid = value.length <= 8;

    String nicknameValidationMsg;
    if (value.isEmpty) {
      nicknameValidationMsg = "";
    } else if (hasSpace) {
      nicknameValidationMsg = "닉네임에 공백은 사용할 수 없습니다";
    } else if (!isValidCharacters) {
      nicknameValidationMsg = "닉네임은 한글과 영문만 사용 가능합니다";
    } else if (!isLengthValid) {
      nicknameValidationMsg = "닉네임은 8자 이내여야 합니다";
    } else {
      nicknameValidationMsg = "valid";
      return true;
    }

    _showError(nicknameValidationMsg);
    return false;
  }

  @override
  void initState() {
    super.initState();
    _userData = _fetchUserData();
    _loadReports();
    _nicknameController = TextEditingController();

    _userData.then((data) {
      if (mounted) {
        setState(() {
          nickname = data['nickname'];
          _nicknameController.text = data['nickname']; // 텍스트에디터 기본값: 기존의 nickname 값
        });
      }
    });
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grayscale8,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 15.h),
              _buildAppBar(),
              SizedBox(height: 30.h),

              SizedBox(
                width: 327.w,
                child: Column(
                  children: [
                    FutureBuilder(
                      future: _userData,
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
                          final Map<String, dynamic> json = snapshot.data;
                          return Column(
                            children: [
                              _buildProfileSection(json['username']), //json['nickname']
                              SizedBox(height: 10.h),
                              _buildVoiceTypeSection(json['voice_type']),
                              SizedBox(height: 20.h),
                              VoiceRangeDisplay(
                                pitchNoteMin: json['pitch_note_min'],
                                pitchNoteMax: json['pitch_note_max'],
                                title: "나의 음역대",
                              ),
                              SizedBox(height: 20.h),
                              _buildParticipationStatusSection(json),
                            ],
                          );
                        }
                      },
                    ),
                    SizedBox(height: 30.h),
                    _buildVocalAnalysisReportSection(),
                    SizedBox(height: 100.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            context.push(AppRoutePaths.settings);
          },
          child: Image.asset('assets/images/settings_icon.png', width: 27.w, height: 27.h),
        ),
        SizedBox(width: 18.w),
      ],
    );
  }

  Widget _buildProfileSection(String username) {
    return Column(
      children: [
        _buildNicknameSection(),
        SizedBox(height: 3.h),
        Text(
          username,
          style: AppTextStyles.body2.copyWith(color: AppColors.grayscale4),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNicknameSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 10.w),
        _isNicknameEditing
            ? Expanded(
              child: Focus(
                onFocusChange: (hasFocus) {
                  if (!hasFocus) _applyNicknameChange();
                },
                child: TextField(
                  controller: _nicknameController,
                  decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.grayscale2),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.grayscale2),
                    ),
                  ),
                  onTapOutside: (event) {
                    // 텍스트 에디터 밖 선택 -> 포커스 사라짐
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  cursorColor: AppColors.grayscale1,
                ),
              ),
            )
            : Text(
              nickname,
              style: AppTextStyles.heading2Bold.copyWith(color: AppColors.grayscale1),
              textAlign: TextAlign.center,
            ),
        SizedBox(width: 2.w),
        GestureDetector(
          // 닉네임 수정 버튼
          onTap: () {
            setState(() {
              _isNicknameEditing = true;
            });
          },
          child: Padding(
            padding: EdgeInsets.fromLTRB(6.w, 2.h, 20.w, 8.h),
            child: Image.asset('assets/images/edit_nickname_icon.png', width: 12.w, height: 12.h),
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceTypeSection(String voiceType) {
    return Container(
      width: 100.w,
      height: 30.h,
      decoration: BoxDecoration(
        color: AppColors.primaryPink,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Center(
        child: Text(
          SongDetailModel.convertVoiceTypeEng2Kor(voiceType),
          style: AppTextStyles.body3Bold.copyWith(color: AppColors.grayscale8),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildParticipationStatusSection(Map<String, dynamic> json) {
    return Row(
      children: [
        Expanded(child: _buildStatusCard('총 연습시간', '${json['total_training_minutes'] ?? ''}분')),
        SizedBox(width: 12.w),
        Expanded(child: _buildStatusCard('완료한 훈련', '${json['total_training_count'] ?? ''}개')),
        SizedBox(width: 12.w),
        Expanded(child: _buildStatusCard('패널티', '${json['duet_penalty_count'] ?? 0}개')),
      ],
    );
  }

  Widget _buildStatusCard(String title, String value) {
    return Container(
      width: 100.w,
      height: 70.h,
      padding: EdgeInsets.symmetric(vertical: 8.h),
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
          SizedBox(height: 2.h),
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
        _buildTrainingSection('솔로 트레이닝', '${_soloReports.length}', _soloReports, TrainingMode.solo),
        SizedBox(height: 30.h),
        _buildTrainingSection('듀엣 트레이닝', '${_duetReports.length}', _duetReports, TrainingMode.duet),
      ],
    );
  }

  Widget _buildTrainingSection(
    String title,
    String count,
    List<_ReportOverviewData> reports,
    TrainingMode mode,
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
          _ReportOverviewData report = entry.value;
          return _buildReportItem(report.title, index, mode, report.id);
        }),
      ],
    );
  }

  Widget _buildReportItem(String title, int index, TrainingMode mode, int reportId) {
    bool isPressed = _pressedReportIndex == index && _pressedReportMode == mode;

    return Column(
      children: [
        GestureDetector(
          onTapDown: (_) {
            setState(() {
              _pressedReportIndex = index;
              _pressedReportMode = mode;
            });
          },
          onTapUp: (_) async {
            String voiceType = await _userData.then((value) => value['voice_type']);
            String pitchNoteMin = await _userData.then((value) => value['pitch_note_min']);
            String pitchNoteMax = await _userData.then((value) => value['pitch_note_max']);
            setState(() {
              context.push(
                '${AppRoutePaths.detailReportPage}/$reportId?trainingMode=${mode.name}',
                extra: {
                  'voiceType': voiceType,
                  'pitchNoteMin': pitchNoteMin,
                  'pitchNoteMax': pitchNoteMax,
                },
              );
              _pressedReportIndex = null;
              _pressedReportMode = null;
            });
          },
          onTapCancel: () {
            setState(() {
              _pressedReportIndex = null;
              _pressedReportMode = null;
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
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.body4.copyWith(color: AppColors.grayscale1),
                    overflow: TextOverflow.ellipsis,
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
