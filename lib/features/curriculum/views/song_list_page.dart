import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';
import 'package:sync2sing/features/curriculum/logics/song_detail_model.dart';
import 'package:sync2sing/features/shared/logics/dio_factory.dart';
import 'package:sync2sing/features/shared/logics/secure_storage.dart';
import 'package:sync2sing/features/shared/logics/training_mode.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/features/shared/views/custom_loading_page.dart';

class SongListPage extends StatefulWidget {
  final TrainingMode trainingMode;
  const SongListPage({Key? key, required this.trainingMode}) : super(key: key);

  @override
  State<SongListPage> createState() => _SongListPageState();
}

class _SongListPageState extends State<SongListPage> {
  final List<String> voiceTypes = ['전체', '소프라노', '알토', '테너', '바리톤', '베이스'];
  String selectedVoiceType = '전체';
  late final Future<Map<String, dynamic>> responseData; // status 를 포함하는 response data.
  late List<SongDetailModel> songs = [];
  late final List<Map<String, dynamic>> songList;

  Future<Map<String, dynamic>> _fetchSongsInfo() async {
    final dioFactory = DioFactory(SecureStorage());
    debugPrint('/${widget.trainingMode.apiBasePath}/songs?type=original');
    final response = await dioFactory.get(
      '/${widget.trainingMode.apiBasePath}/songs?type=original',
    );
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('API 요청 실패');
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
            if (snapshot.hasData == false) {
              // api 응답 대기 중
              return CustomLoading();
            } else if (snapshot.hasError) {
              return Text("오류 발생: ${snapshot.data['message']}");
            } else {
              // api 응답 완료:
              debugPrint("responseData: ${snapshot.data}");

              songs = [];
              snapshot.data['data']['song_list'].forEach((e) {
                songs.add(SongDetailModel.fromJson(e));
              });

              final List<SongDetailModel> filteredSongList =
                  selectedVoiceType == '전체'
                      ? songs
                      : songs
                          .where((song) => song.voiceType == getVoiceTypeEnglish(selectedVoiceType))
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

                        return GestureDetector(
                          onTap: () {
                            context.push(AppRoutePaths.soloSongDetail, extra: song);
                          },
                          child: Container(
                            width: 327.w.roundToDouble(),
                            height: 103.h.roundToDouble(),
                            decoration: BoxDecoration(
                              color: AppColors.grayscale8,
                              borderRadius: BorderRadius.circular(15.w),
                            ),
                            child: Row(
                              children: [
                                SizedBox(width: 10.w),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12.w),
                                  child:
                                      song.albumArtUrl.startsWith('assets')
                                          ? Image.asset(
                                            song.albumArtUrl,
                                            width: 80.w,
                                            height: 80.h,
                                            fit: BoxFit.cover,
                                          )
                                          : Image.network(
                                            song.albumArtUrl,
                                            width: 80.w,
                                            height: 80.h,
                                            fit: BoxFit.cover,
                                          ),
                                ),
                                SizedBox(width: 14.w),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        song.title,
                                        // song['title']!, //
                                        style: AppTextStyles.body1Bold,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 5.h),
                                      Text(
                                        song.artist,
                                        // song['artist']!,
                                        style: AppTextStyles.body2.copyWith(
                                          color: AppColors.grayscale3,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 5.h),
                                      Container(
                                        height: 20.h,
                                        width: 60.w,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: AppColors.grayscale3,
                                          borderRadius: BorderRadius.circular(12.w),
                                        ),
                                        child: Text(
                                          songDetailModel.getVoiceTypeKorean(),
                                          style: AppTextStyles.body6.copyWith(
                                            color: AppColors.grayscale8,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 20.w),
                              ],
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
