import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';
import 'package:sync2sing/features/curriculum/views/duet_room_detail_page.dart';
import 'package:sync2sing/features/home_hub/views/duet_song_section.dart';
import 'package:sync2sing/features/shared/logics/dio_factory.dart';
import 'package:sync2sing/features/shared/views/custom_loading_page.dart';

import '../../shared/logics/secure_storage.dart';
import '../logics/room_item.dart';

class _BothRoomList {
  // fetch 함수 응답 객체
  List<Room> totalRooms;
  List<Room> partnerRooms;
  Room? hostRoom;

  _BothRoomList({required this.totalRooms, required this.partnerRooms, this.hostRoom});

  _BothRoomList copyWith({List<Room>? totalRooms, List<Room>? partnerRooms, Room? hostRoom}) {
    return _BothRoomList(
      totalRooms: totalRooms ?? this.totalRooms,
      partnerRooms: partnerRooms ?? this.partnerRooms,
      hostRoom: hostRoom ?? this.hostRoom,
    );
  }
}

class BeforeSessionWidget extends StatefulWidget {
  final ValueChanged<bool> isRoomHost;
  const BeforeSessionWidget({super.key, required this.isRoomHost}); // , required this.isRoomHost

  @override
  State<BeforeSessionWidget> createState() => _BeforeSessionWidgetState();
}

class _BeforeSessionWidgetState extends State<BeforeSessionWidget> {
  late final Future<List<Map<String, dynamic>>> sentList;
  late final Future<List<int>> sentRoomIds;
  late final Future<List<Room>> sentRooms;
  late final Future<List<Room>> rooms;
  late final Future<_BothRoomList> roomLists;

  Future<_BothRoomList> _fetchSentList() async {
    final dio = DioFactory(SecureStorage());

    try {
      final partnerSentResponse = await dio.get('/duet-training/applications/sent');
      final dataList =
          partnerSentResponse.data['data']['application_list'] as List<dynamic>; // 보낸 파트너 신청 목록
      final roomListResponse = await dio.get('/duet-training/rooms');

      final roomDataList = roomListResponse.data['data']['room_list'] as List;

      final roomIdList = dataList.map((e) => e['room_id'] as int).toList();

      final Room? hostRoom =
          roomListResponse.data['data']['my_room'] != null
              ? Room.fromJson(roomListResponse.data['data']['my_room'])
              : null;

      if (hostRoom == null) {
        widget.isRoomHost(false);
      } else {
        widget.isRoomHost(true);
      }

      final List<Room> roomList =
          roomDataList.isNotEmpty ? roomDataList.map((json) => Room.fromJson(json)).toList() : [];

      final List<Room> partnerSentList = []; // 보낸 신청 요청의 방 정보를 저장
      for (var i = 0; i < roomIdList.length; i++) {
        for (var r in roomList) {
          if (r.id == roomIdList[i]) {
            partnerSentList.add(r);
          }
        }
      }

      return _BothRoomList(totalRooms: roomList, partnerRooms: partnerSentList, hostRoom: hostRoom);
    } on DioException catch (e) {
      debugPrint("error2: ${e.response}");
      throw Exception(e.response);
    }
  }

  @override
  void initState() {
    roomLists = _fetchSentList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: roomLists,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          final errorString = snapshot.error.toString();

          debugPrint("widget 오류 발생: ${errorString}");
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
          final _BothRoomList lists = snapshot.data;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEnterRoomList(lists.hostRoom, lists.partnerRooms), // 참여 대기중인 연습실
              if (lists.hostRoom != null || lists.partnerRooms.isNotEmpty) SizedBox(height: 48.h),
              Text(
                "대기중인 연습실",
                style: AppTextStyles.heading3Bold.copyWith(color: AppColors.grayscale2),
              ),
              (lists.totalRooms.isNotEmpty)
                  ? _buildWaitingRoomList(snapshot.data.totalRooms)
                  : Container(
                    // 방을 만들지 않은 경우에만 연습실 만들어보세요 항목 노출
                    alignment: Alignment(0, 0),
                    padding: EdgeInsets.only(top: 100.h),
                    child: Text(
                      (lists.hostRoom == null)
                          ? "대기중인 연습실이 없어요 \n새로운 연습실을 만들어보세요"
                          : "대기중인 연습실이 없어요",
                      style: AppTextStyles.body1.copyWith(color: AppColors.grayscale4),
                      textAlign: TextAlign.center,
                    ),
                  ),
            ],
          );
        }
      },
    );
  }

  Widget _buildEnterRoomList(Room? ownerRoom, List<Room> partnerRooms) {
    // 참여 대기 중인 연습실들
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (ownerRoom != null || partnerRooms.isNotEmpty)
          Text(
            "참여 대기중인 연습실",
            style: AppTextStyles.heading3Bold.copyWith(color: AppColors.grayscale2),
          ),
        if (ownerRoom != null || partnerRooms.isNotEmpty) SizedBox(height: 12.h),
        if (ownerRoom != null) _buildMyRoom(ownerRoom),
        if (ownerRoom != null && partnerRooms.isNotEmpty) // 방장 / 참여자 리스트 룸 사이
          Container(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Divider(color: AppColors.grayscale6),
          ),
        if (partnerRooms.isNotEmpty) _buildPartnerRooms(partnerRooms),
      ],
    );
  }

  Widget _buildMyRoom(Room hostRoom) {
    // 내가 방 주인인 연습실
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () async {
            if (mounted) {
              context.push(
                AppRoutePaths.duetRoomDetail,
                extra: {'roomPosition': RoomPosition.host, 'room': hostRoom},
              );
            }
          },
          child: _buildRoomField(
            hostRoom.song,
            hostRoom.id,
            hostRoom.hostPart.voiceType,
            hostRoom.hostPart.partName,
          ),
        ),
        SizedBox(height: 12.h),

        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 5.h),
          alignment: Alignment.topCenter,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.r),
            color: AppColors.grayscale6,
          ),
          child: Text(
            "파트너 매칭을 진행 중이에요",
            style: AppTextStyles.body5.copyWith(color: AppColors.grayscale3),
          ),
        ),
      ],
    );
  }

  Widget _buildPartnerRooms(List<Room> waitingRooms) {
    // 파트너 신청을 넣은 연습실 목록
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(), // 리스트뷰 내의 스크롤 방지
      itemCount: waitingRooms.length,
      separatorBuilder:
          (context, idx) => Container(
            margin: EdgeInsets.symmetric(vertical: 12.h),
            color: AppColors.grayscale6,
            width: double.infinity,
            height: 1,
            child: Divider(color: AppColors.grayscale6),
          ),
      itemBuilder: (context, idx) {
        final song = waitingRooms[idx].song;

        return Column(
          children: [
            GestureDetector(
              onTap: () async {
                await context.push(
                  AppRoutePaths.duetRoomDetail,
                  extra: {'roomPosition': RoomPosition.partner, 'room': waitingRooms[idx]},
                );
              },

              child: _buildRoomField(
                song,
                waitingRooms[idx].id,
                waitingRooms[idx].partnerPart.voiceType,
                waitingRooms[idx].partnerPart.partName,
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 5.h),
              alignment: Alignment.topCenter,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.r),
                color: AppColors.grayscale6,
              ),
              child: Text(
                "파트너 신청 수락을 기다리고 있어요",
                style: AppTextStyles.body5.copyWith(color: AppColors.grayscale3),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRoomField(SongOfRoom song, int roomId, String voiceType, String partName) {
    return DuetSongSection(
      id: song.id,
      title: song.title,
      artist: song.artist,
      voiceType: voiceType,
      albumArtUrl: song.albumArtUrl,
      partName: partName,
    );
  }

  // 대기중인 방 목록
  Widget _buildWaitingRoomList(List<Room> totalRooms) {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(), // 리스트뷰 내의 스크롤 방지
      itemCount: totalRooms.length,
      separatorBuilder:
          (context, idx) => Container(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            color: AppColors.grayscale6,
            width: double.infinity,
            height: 1,
          ),
      itemBuilder: (context, idx) {
        final song = totalRooms[idx].song;

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: GestureDetector(
            onTap: () async {
              await context.push(
                AppRoutePaths.duetRoomDetail,
                extra: {'roomPosition': RoomPosition.viewer, 'room': totalRooms[idx]},
              );
            },
            child: _buildRoomField(
              song,
              totalRooms[idx].id,
              totalRooms[idx].partnerPart.voiceType,
              totalRooms[idx].partnerPart.partName,
            ),
          ),
        );
      },
    );
  }
}
