import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';
import 'package:sync2sing/features/curriculum/logics/appliction_model.dart';
import 'package:sync2sing/features/curriculum/logics/duet_song_model.dart';
import 'package:sync2sing/features/curriculum/logics/song_detail_model.dart';
import 'package:sync2sing/features/curriculum/logics/timed_lyric.dart';
import 'package:sync2sing/features/home_hub/logics/room_item.dart';
import 'package:sync2sing/features/home_hub/views/duet_song_section.dart';
import 'package:sync2sing/features/shared/logics/dio_factory.dart';
import 'package:sync2sing/features/shared/logics/secure_storage.dart';
import 'package:sync2sing/features/shared/views/custom_loading_page.dart';
import 'package:sync2sing/features/shared/views/simple_app_bar.dart';
import 'package:sync2sing/features/shared/views/voice_range_display.dart';

enum RoomPosition { viewer, host, partner }

class DuetRoomDetailPage extends StatefulWidget {
  final RoomPosition roomPosition;
  final Room room;
  DuetRoomDetailPage({super.key, required this.room, required this.roomPosition});

  @override
  State<DuetRoomDetailPage> createState() => _DuetRoomDetailPageState();

  final Map<String, dynamic> applicationListJson = {
    "status": 200,
    "message": "받은 파트너 신청 목록 조회에 성공했습니다.",
    "data": {
      "application_list": [
        {
          "id": 1,
          "applicant_id": 5,
          "applicant_nickname": "호박",
          "requested_at": "2025-09-06T02:22:59",
        },
        {
          "id": 9,
          "applicant_id": 90,
          "applicant_nickname": "리듬타는김바덕",
          "requested_at": "2025-09-06T02:22:59",
        },

        {
          "id": 12,
          "applicant_id": 10,
          "applicant_nickname": "가오리",
          "requested_at": "2025-09-06T02:22:59",
        },
      ],
    },
  };

  final Map<String, dynamic> songJson = {
    "status": 200,
    "message": "듀엣 트레이닝 원곡 조회에 성공했습니다.",
    "data": {
      "id": 9,
      "title": "Do-Re-Mi Duet Dong",
      "artist": "Richard Rodgers",
      "youtube_link": "https://youtu.be/jyLP6XLgEYY?si=OysroAyUTirMbPCT",
      "lyrics": [
        {"line_index": 0, "text": "Doe, a deer, a female deer", "start_time": 0, "part_number": 0},
        {
          "line_index": 1,
          "text": "Ray, a drop of golden sun",
          "start_time": 7200,
          "part_number": 1,
        },
      ],
      "album_art_url":
          "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/272d3a5c-9679-4c11-bc13-b4bde7f5870a.jpg",
      "file_url":
          "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/audios/original/5aeb553f-2e9f-4975-adc7-74d985e4e6e2.wav",
      "duet_parts": [
        {
          "part_number": 0,
          "part_name": "영희",
          "voice_type": "BARITONE",
          "pitch_note_min": "C4",
          "pitch_note_max": "D5",
        },
        {
          "part_number": 1,
          "part_name": "철수",
          "voice_type": "SOPRANO",
          "pitch_note_min": "C4",
          "pitch_note_max": "D5",
        },
      ],
    },
  };
}

class _DuetRoomDetailPageState extends State<DuetRoomDetailPage> {
  late final Future<List<ApplicationModel>> applications;
  late final Future<DuetSongModel> songDetailModel;
  late final int userPartNumber;
  late final DuetPart userDuetPart;
  late final bool isHost;

  Future<DuetSongModel> _fetchSongData() async {
    await Future.delayed(Duration(milliseconds: 5));

    final DuetSongModel song = DuetSongModel.fromJson(widget.songJson['data']);
    return song;
  }

  Future<List<ApplicationModel>> _fetchApplications() async {
    await Future.delayed(Duration(milliseconds: 5));

    final applicationDataList = widget.applicationListJson['data']['application_list'] as List;
    final List<ApplicationModel> applicationList =
        applicationDataList.map((json) => ApplicationModel.fromJson(json)).toList();

    return applicationList;
  }

  @override
  void initState() {
    super.initState();
    isHost = (widget.roomPosition == RoomPosition.host);
    userPartNumber =
        (isHost) ? widget.room.hostPart.partNumber : widget.room.partnerPart.partNumber;
    userDuetPart = (isHost) ? widget.room.hostPart : widget.room.partnerPart;
    applications = _fetchApplications();
    songDetailModel = _fetchSongData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SimpleAppBar(),
              SizedBox(
                width: 327.w,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FutureBuilder(
                      // 노래 영역
                      future: songDetailModel,
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
                          return DuetSongSection(
                            // 재생 버튼 없는 Row Section
                            id: widget.room.song.id,
                            title: widget.room.song.title,
                            albumArtUrl: widget.room.song.albumArtUrl,
                            artist: widget.room.song.artist,
                            voiceType: userDuetPart.voiceType,
                          );
                        } else {
                          // 응답이 정상적으로 온 경우
                          final DuetSongModel song = snapshot.data;

                          final bool isFirstPart =
                              song.duetParts.first.partNumber == userPartNumber;
                          return Column(
                            children: [
                              _buildSongInfo(song, isFirstPart),
                              SizedBox(height: 32.h),
                              _buildLyricsField(song.lyrics, userPartNumber),
                            ],
                          );
                        }
                      },
                    ),
                    SizedBox(height: 32.h),

                    FutureBuilder(
                      future: applications,
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
                          return ApplicationListSection(
                            applicationList: snapshot.data,
                            isHost: isHost,
                            roomId: widget.room.id,
                          );
                        }
                      },
                    ),
                    SizedBox(height: 32.h),

                    SizedBox(
                      width: 327.w,
                      height: 50.h,
                      child: CupertinoButton(
                        color: AppColors.primaryPink,
                        disabledColor: AppColors.primaryPinkDisabled,
                        borderRadius: BorderRadius.circular(10.w),
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          if (widget.roomPosition == RoomPosition.viewer) {
                            try {
                              // await DioFactory(
                              //   SecureStorage(),
                              // ).post('/duet-training/rooms/${widget.room.id}/applications');
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("신청 요청이 실패했습니다. 다시 시도해주세요")),
                                );
                              }
                            }
                            if (context.mounted) {
                              context.go(AppRoutePaths.duetTrainingHome);
                            }
                          } else {
                            context.pop();
                          }
                        },
                        child: Text(
                          widget.roomPosition == RoomPosition.viewer ? '연습실 선택하기' : "확인",
                          style: AppTextStyles.body1BoldWhite,
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSongInfo(DuetSongModel song, bool isFirstPart) {
    final String totalPitchMin =
        (VoiceRangeDisplay.noteToNumber(song.duetParts.first.pitchNoteMin) <
                VoiceRangeDisplay.noteToNumber(song.duetParts.last.pitchNoteMin))
            ? song.duetParts.first.pitchNoteMin
            : song.duetParts.last.pitchNoteMin;
    final String totalPitchMax =
        (VoiceRangeDisplay.noteToNumber(song.duetParts.first.pitchNoteMax) >
                VoiceRangeDisplay.noteToNumber(song.duetParts.last.pitchNoteMax))
            ? song.duetParts.first.pitchNoteMax
            : song.duetParts.last.pitchNoteMax;

    return Column(
      children: [
        DuetSongSection(
          id: song.id,
          title: song.title,
          albumArtUrl: song.albumArtUrl,
          artist: song.artist,
          voiceType: song.duetParts.first.voiceType,
          partName: SongDetailModel.convertVoiceTypeEng2Kor(song.duetParts.last.voiceType),
          fileUrl: song.fileUrl,
          isSelectedHost: isFirstPart, // 강조 색이 첫번째에 들어가는지
        ),
        SizedBox(height: 16.h),

        VoiceRangeDisplay(
          pitchNoteMin: totalPitchMin,
          pitchNoteMax: totalPitchMax,
          themeColor: VoiceRangeColor.gray,
        ),
        SizedBox(height: 16.h),
        VoiceRangeDisplay(
          pitchNoteMin: song.duetParts.first.pitchNoteMin,
          pitchNoteMax: song.duetParts.first.pitchNoteMax,
          title: song.duetParts.first.partName,
          themeColor:
              (isFirstPart) // not gray인 부분: 자기 파트인 경우
                  ? (isHost)
                      ? VoiceRangeColor.pink
                      : VoiceRangeColor.green
                  : VoiceRangeColor.gray,
        ),

        SizedBox(height: 16.h),
        VoiceRangeDisplay(
          pitchNoteMin: song.duetParts.last.pitchNoteMin,
          pitchNoteMax: song.duetParts.last.pitchNoteMax,
          title: song.duetParts.last.partName,
          themeColor:
              (!isFirstPart) // not gray인 부분: 자기 파트인 경우
                  ? (isHost)
                      ? VoiceRangeColor.pink
                      : VoiceRangeColor.green
                  : VoiceRangeColor.gray,
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildLyricsField(List<TimedLyric> lyrics, int userPartNumber) {
    return Container(
      width: double.infinity,
      height: 450.h,
      alignment: Alignment.topCenter,
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 19.w),
      decoration: BoxDecoration(
        color: AppColors.grayscale7,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: ListView.builder(
        physics: const ClampingScrollPhysics(), // 자식 크기가 부모 미만 -> 스크롤 불가 (액션 x)
        itemCount: lyrics.length,
        itemBuilder: (context, index) {
          final lyric = lyrics[index];
          return Text(
            lyric.text,
            style: AppTextStyles.heading4Bold.copyWith(
              color:
                  lyric.partNumber == userPartNumber
                      ? isHost
                          ? AppColors.primaryPink
                          : AppColors.primaryGreen
                      : AppColors.grayscale3,
            ),
            textAlign: TextAlign.center,
          );
        },
      ),
    );
  }
}

class ApplicationListSection extends StatefulWidget {
  final List<ApplicationModel> applicationList;
  final bool isHost;
  final int roomId;
  const ApplicationListSection({
    super.key,
    required this.applicationList,
    required this.isHost,
    required this.roomId,
  });

  @override
  State<ApplicationListSection> createState() => _ApplicationListSectionState();
}

class _ApplicationListSectionState extends State<ApplicationListSection> {
  int selectedIdx = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("파트너 신청 목록", style: AppTextStyles.body3Bold),
            Text(
              widget.applicationList.length.toString(),
              style: AppTextStyles.body3Bold.copyWith(color: AppColors.grayscale3),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        (widget.applicationList.isEmpty)
            ? Container(
              padding: EdgeInsets.only(top: 12.h),
              child: Text(
                "파트너 신청을 기다리고 있어요",
                style: AppTextStyles.body4.copyWith(color: AppColors.grayscale3),
              ),
            )
            : _buildPartnerList(widget.applicationList),
      ],
    );
  }

  Widget _buildPartnerList(List<ApplicationModel> applicationList) {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(), // 리스트뷰 내의 스크롤 방지

      itemBuilder: (context, idx) {
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedIdx = idx;
            });
          },
          child: _buildPartnerSent(applicationList[idx], (idx == selectedIdx)),
        );
      },
      separatorBuilder:
          (context, idx) => Container(
            color: AppColors.grayscale6,
            width: double.infinity,
            height: 1,
            child: Divider(color: AppColors.grayscale6),
          ),
      itemCount: applicationList.length,
    );
  }

  Widget _buildPartnerSent(ApplicationModel app, bool isSelected) {
    return Container(
      height: 40.h,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      color: isSelected ? AppColors.grayscale7 : AppColors.grayscale8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(app.applicantNickname, style: AppTextStyles.body4),
          if (widget.isHost && isSelected) _buildApplyRejectButtons(app.id),
        ],
      ),
    );
  }

  Widget _buildApplyRejectButtons(int applicationId) {
    DioFactory dio = DioFactory(SecureStorage());
    return Row(
      children: [
        CupertinoButton(
          padding: EdgeInsets.zero,

          child: Container(
            width: 60.h,
            height: 20.h,
            alignment: Alignment(0, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              color: AppColors.primaryPink,
            ),
            child: Text("수락", style: AppTextStyles.body6White),
          ),
          onPressed: () async {
            try {
              dio.post('duet-training/rooms/${widget.roomId}/applications/$applicationId');
            } catch (e) {
              _showError("수락에 실패했습니다. 다시 시도해주세요.");
            }
          },
        ),
        SizedBox(width: 8.w),
        CupertinoButton(
          padding: EdgeInsets.zero,
          child: Container(
            width: 70.h,
            height: 20.h,
            alignment: Alignment(0, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              color: AppColors.grayscale6,
            ),
            child: Text("거절", style: AppTextStyles.body6.copyWith(color: AppColors.grayscale3)),
          ),
          onPressed: () {
            try {
              dio.delete('duet-training/rooms/${widget.roomId}/applications/$applicationId');
            } catch (e) {
              _showError("파트너 거절이 실패했습니다. 다시 시도해주세요");
            }
          },
        ),
      ],
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
