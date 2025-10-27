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

                return Text(errorJson['message']);
              } catch (e) {
                return Text('알 수 없는 오류가 발생했습니다.');
              }
            } else if (snapshot.hasData == false) {
              // api 응답 대기 중
              return CustomLoading();
            } else {
              // api 응답 완료:
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
                            context.push(
                              AppRoutePaths.duetSongDetail,
                              extra: {'song': song, 'isSelectFirst': isFirstVoiceTypeSelected},
                            );
                          },

                          child: Padding(
                            padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
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
