import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';
import 'package:sync2sing/features/curriculum/logics/duet_song_model.dart';
import 'package:sync2sing/features/curriculum/logics/song_detail_model.dart';
import 'package:sync2sing/features/home_hub/views/duet_song_section.dart';
import 'package:sync2sing/features/shared/logics/dio_factory.dart';
import 'package:sync2sing/features/shared/logics/secure_storage.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/features/shared/logics/training_mode.dart';
import 'package:sync2sing/features/shared/views/custom_loading_page.dart';

class DuetSongListPage extends StatefulWidget {
  const DuetSongListPage({super.key});

  @override
  State<DuetSongListPage> createState() => _DuetSongListPageState();
}

class _DuetSongListPageState extends State<DuetSongListPage> {
  final List<String> voiceTypes = ['전체', '소프라노', '알토', '테너', '바리톤', '베이스'];
  String selectedVoiceType = '전체';
  late final Future<Map<String, dynamic>> responseData; // status 를 포함하는 response data.
  late List<DuetSongModel> songs = [];
  late final List<Map<String, dynamic>> songList;

  Future<Map<String, dynamic>> _fetchSongsInfo() async {
    try {
      final dioFactory = DioFactory(SecureStorage());
      debugPrint('/${TrainingMode.duet.apiBasePath}/songs?type=original');
      final response = await dioFactory.get(
        '/${TrainingMode.duet.apiBasePath}/songs?type=original',
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('API 요청 실패');
      }
    } on DioException catch (e) {
      debugPrint("error2: ${e.response}");
      throw Exception(e.response);
    }

    // try {
    //   await Future.delayed(Duration(milliseconds: 5));
    //
    //   final Map<String, dynamic> json = {
    //     "status": 200,
    //     "message": "듀엣 트레이닝 원곡 목록 조회에 성공했습니다.",
    //     "data": {
    //       "song_list": [
    //         {
    //           "id": 9,
    //           "title": "Do-Re-Mi Duet Dong",
    //           "artist": "Richard Rodgers",
    //           "youtube_link": "https://youtu.be/jyLP6XLgEYY?si=OysroAyUTirMbPCT",
    //           "lyrics": [
    //             {
    //               "line_index": 0,
    //               "text": "Doe, a deer, a female deer",
    //               "start_time": 0,
    //               "part_number": 0,
    //             },
    //             {
    //               "line_index": 1,
    //               "text": "Ray, a drop of golden sun",
    //               "start_time": 7200,
    //               "part_number": 1,
    //             },
    //             {
    //               "line_index": 2,
    //               "text": "Doe, a deer, a female deer",
    //               "start_time": 0,
    //               "part_number": 0,
    //             },
    //             {
    //               "line_index": 3,
    //               "text": "Ray, a drop of golden sun",
    //               "start_time": 7200,
    //               "part_number": 1,
    //             },
    //             {
    //               "line_index": 4,
    //               "text": "Doe, a deer, a female deer",
    //               "start_time": 0,
    //               "part_number": 0,
    //             },
    //             {
    //               "line_index": 5,
    //               "text": "Ray, a drop of golden sun",
    //               "start_time": 7200,
    //               "part_number": 1,
    //             },
    //             {
    //               "line_index": 6,
    //               "text": "Doe, a deer, a female deer",
    //               "start_time": 0,
    //               "part_number": 0,
    //             },
    //             {
    //               "line_index": 7,
    //               "text": "Ray, a drop of golden sun",
    //               "start_time": 7200,
    //               "part_number": 1,
    //             },
    //             {
    //               "line_index": 7,
    //               "text": "Ray, a drop of golden sun",
    //               "start_time": 7200,
    //               "part_number": 1,
    //             },
    //             {
    //               "line_index": 7,
    //               "text": "Ray, a drop of golden sun",
    //               "start_time": 7200,
    //               "part_number": 1,
    //             },
    //             {
    //               "line_index": 7,
    //               "text": "Ray, a drop of golden sun",
    //               "start_time": 7200,
    //               "part_number": 1,
    //             },
    //             {
    //               "line_index": 7,
    //               "text": "Ray, a drop of golden sun",
    //               "start_time": 7200,
    //               "part_number": 1,
    //             },
    //             {
    //               "line_index": 7,
    //               "text": "Ray, a drop of golden sun",
    //               "start_time": 7200,
    //               "part_number": 1,
    //             },
    //             {
    //               "line_index": 7,
    //               "text": "Ray, a drop of golden sun",
    //               "start_time": 7200,
    //               "part_number": 1,
    //             },
    //             {
    //               "line_index": 7,
    //               "text": "Ray, a drop of golden sun",
    //               "start_time": 7200,
    //               "part_number": 1,
    //             },
    //           ],
    //           "album_art_url":
    //               "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/272d3a5c-9679-4c11-bc13-b4bde7f5870a.jpg",
    //           "file_url":
    //               "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/audios/original/5aeb553f-2e9f-4975-adc7-74d985e4e6e2.wav",
    //           "duet_parts": [
    //             {
    //               "part_number": 0,
    //               "part_name": "영희",
    //               "voice_type": "BARITONE",
    //               "pitch_note_min": "C4",
    //               "pitch_note_max": "D5",
    //             },
    //             {
    //               "part_number": 1,
    //               "part_name": "철수",
    //               "voice_type": "SOPRANO",
    //               "pitch_note_min": "C4",
    //               "pitch_note_max": "D5",
    //             },
    //           ],
    //         },
    //       ],
    //     },
    //   };
    //   return json;
    // } on Exception catch (a, e) {
    //   throw Exception("error 발생");
    // }
  }

  String getVoiceTypeEnglish(String korean) {
    switch (korean) {
      case '소프라노':
        return 'SOPRANO';
      case '알토':
        return 'ALTO';
      case '테너':
        return 'TENOR';
      case '바리톤':
        return 'BARITONE';
      case '베이스':
        return 'BASS';
      default:
        return '';
    }
  }

  @override
  void initState() {
    responseData = _fetchSongsInfo();
    super.initState();
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

                // final status = errorJson['status']?.toString() ?? 'Unknown status';
                return Text(errorJson['message']);
              } catch (e) {
                return Text('알 수 없는 오류가 발생했습니다.');
              }
            } else if (snapshot.hasData == false) {
              // api 응답 대기 중
              return CustomLoading();
            } else {
              // api 응답 완료:
              debugPrint("responseData: ${snapshot.data}");

              songs = [];
              snapshot.data['data']['song_list'].forEach((e) {
                songs.add(DuetSongModel.fromJson(e));
              });

              final List<DuetSongModel> filteredSongList =
                  selectedVoiceType == '전체'
                      ? songs
                      : songs
                          .where(
                            (song) =>
                                song.duetParts.first.voiceType ==
                                    getVoiceTypeEnglish(selectedVoiceType) ||
                                song.duetParts.last.voiceType ==
                                    getVoiceTypeEnglish(selectedVoiceType),
                          )
                          .toList();

              return Column(
                children: [
                  SizedBox(height: 32.h),
                  Container(
                    height: 30.h,
                    margin: EdgeInsets.only(left: 15.w),
                    decoration: BoxDecoration(
                      color: AppColors.grayscale7,
                      borderRadius: BorderRadius.circular(30.w),
                    ),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: voiceTypes.length,
                      separatorBuilder: (_, __) => SizedBox(width: 4.w),
                      itemBuilder: (BuildContext context, int index) {
                        final isSelected = selectedVoiceType == voiceTypes[index];

                        return GestureDetector(
                          onTap: () => setState(() => selectedVoiceType = voiceTypes[index]),
                          child: Container(
                            width: 80.w,
                            height: 30.h,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.grayscale3 : AppColors.grayscale7,
                              borderRadius: BorderRadius.circular(15.w),
                            ),
                            child: Text(
                              voiceTypes[index],
                              style: AppTextStyles.body3.copyWith(
                                color: isSelected ? AppColors.grayscale8 : AppColors.grayscale3,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 20.h),
                  // 연습곡 리스트
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      itemCount: filteredSongList.length,
                      separatorBuilder:
                          (context, idx) => Container(
                            padding: EdgeInsets.symmetric(vertical: 4.h),
                            color: AppColors.grayscale6,
                            width: double.infinity,
                            height: 1,
                          ),
                      itemBuilder: (context, idx) {
                        final song = filteredSongList[idx];

                        final songDetailModel = song;

                        bool isFirstVoiceTypeSelected =
                            selectedVoiceType == '전체' ||
                            selectedVoiceType ==
                                SongDetailModel.convertVoiceTypeEng2Kor(
                                  songDetailModel.duetParts.first.voiceType,
                                );

                        return GestureDetector(
                          onTap: () {
                            debugPrint("DuetSongSumSection clicked: ${song.title}");
                            context.push(
                              AppRoutePaths.duetSongDetail,
                              extra: {'song': song, 'isSelectFirst': isFirstVoiceTypeSelected},
                            );
                          },

                          child: DuetSongSection(
                            albumArtUrl: songDetailModel.albumArtUrl,
                            artist: songDetailModel.artist,
                            id: songDetailModel.id,
                            title: songDetailModel.title,
                            voiceType: songDetailModel.duetParts.first.voiceType,
                            partName: SongDetailModel.convertVoiceTypeEng2Kor(
                              songDetailModel.duetParts.last.voiceType,
                            ),
                            isLeftColored: (isFirstVoiceTypeSelected),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
