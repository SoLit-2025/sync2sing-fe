import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';
import 'package:sync2sing/features/curriculum/logics/song_detail_model.dart';
import 'package:sync2sing/features/shared/logics/training_mode.dart';
import 'package:sync2sing/config/theme/app_colors.dart';


class SongListPage extends StatefulWidget {
  final TrainingMode trainingMode;
  const SongListPage({Key? key, required this.trainingMode}) : super(key: key);

  @override
  State<SongListPage> createState() => _SongListPageState();
}

class _SongListPageState extends State<SongListPage> {
  final List<String> voiceTypes = ['전체', '소프라노', '알토', '테너', '바리톤','베이스'];
  String selectedVoiceType = '전체';


  final List<Map<String, String>> songList = [
    // 소프라노 8곡
    {
      'title': "How It's Done",
      'artist': "HUNTR/X(EJAE, Audrey Nuna...)",
      'voiceType': "소프라노",
      'albumArtUrl': "assets/images/album-art.png",
    },
    {
      'title': "Soda Pop",
      'artist': "Saja Boys(Andrew Choi, Neck...)",
      'voiceType': "소프라노",
      'albumArtUrl': "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
    },
    {
      'title': "Golden",
      'artist': "HUNTR/X(EJAE, Audrey Nuna...)",
      'voiceType': "소프라노",
      'albumArtUrl': "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
    },
    {
      'title': "Free",
      'artist': "Rumi(EJAE), Jinu(Andrew Choi)",
      'voiceType': "소프라노",
      'albumArtUrl': "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
    },
    {
      'title': "Take Down",
      'artist': "TWICE(정연,지효,채영)",
      'voiceType': "소프라노",
      'albumArtUrl': "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
    },
    {
      'title': "Take Down",
      'artist': "HUNTR/X(EJAE, Audrey Nuna...)",
      'voiceType': "소프라노",
      'albumArtUrl': "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
    },
    {
      'title': "Your Idol",
      'artist': "Saja Boys(Andrew Choi, Neck...)",
      'voiceType': "소프라노",
      'albumArtUrl': "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
    },
    {
      'title': "What It Sounds Like",
      'artist': "HUNTR/X(EJAE, Audrey Nuna...)",
      'voiceType': "소프라노",
      'albumArtUrl': "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
    },
    // 알토 8곡
    {
      'title': "How It's Done",
      'artist': "HUNTR/X(EJAE, Audrey Nuna...)",
      'voiceType': "알토",
      'albumArtUrl': "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
    },
    {
      'title': "Soda Pop",
      'artist': "Saja Boys(Andrew Choi, Neck...)",
      'voiceType': "알토",
      'albumArtUrl': "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
    },
    {
      'title': "Golden",
      'artist': "HUNTR/X(EJAE, Audrey Nuna...)",
      'voiceType': "알토",
      'albumArtUrl': "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
    },
    {
      'title': "Free",
      'artist': "Rumi(EJAE), Jinu(Andrew Choi)",
      'voiceType': "알토",
      'albumArtUrl': "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
    },
    {
      'title': "Take Down",
      'artist': "TWICE(정연,지효,채영)",
      'voiceType': "알토",
      'albumArtUrl': "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
    },
    {
      'title': "Take Down",
      'artist': "HUNTR/X(EJAE, Audrey Nuna...)",
      'voiceType': "알토",
      'albumArtUrl': "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
    },
    {
      'title': "Your Idol",
      'artist': "Saja Boys(Andrew Choi, Neck...)",
      'voiceType': "알토",
      'albumArtUrl': "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
    },
    {
      'title': "What It Sounds Like",
      'artist': "HUNTR/X(EJAE, Audrey Nuna...)",
      'voiceType': "알토",
      'albumArtUrl': "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
    },
    //테너8곡
    {
      'title': "How It's Done",
      'artist': "HUNTR/X(EJAE, Audrey Nuna...)",
      'voiceType': "테너",
      'albumArtUrl': "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
    },
    {
      'title': "Soda Pop",
      'artist': "Saja Boys(Andrew Choi, Neck...)",
      'voiceType': "테너",
      'albumArtUrl': "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
    },
    {
      'title': "Golden",
      'artist': "HUNTR/X(EJAE, Audrey Nuna...)",
      'voiceType': "테너",
      'albumArtUrl': "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
    },
    {
      'title': "Free",
      'artist': "Rumi(EJAE), Jinu(Andrew Choi)",
      'voiceType': "테너",
      'albumArtUrl': "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
    },
    {
      'title': "Take Down",
      'artist': "TWICE(정연,지효,채영)",
      'voiceType': "테너",
      'albumArtUrl': "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
    },
    {
      'title': "Take Down",
      'artist': "HUNTR/X(EJAE, Audrey Nuna...)",
      'voiceType': "테너",
      'albumArtUrl': "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
    },
    {
      'title': "Your Idol",
      'artist': "Saja Boys(Andrew Choi, Neck...)",
      'voiceType': "테너",
      'albumArtUrl': "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
    },
    {
      'title': "What It Sounds Like",
      'artist': "HUNTR/X(EJAE, Audrey Nuna...)",
      'voiceType': "테너",
      'albumArtUrl': "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
    },
    //바리톤 8곡
    {
      'title': "How It's Done",
      'artist': "HUNTR/X(EJAE, Audrey Nuna...)",
      'voiceType': "바리톤",
      'albumArtUrl': "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
    },
    {
      'title': "Soda Pop",
      'artist': "Saja Boys(Andrew Choi, Neck...)",
      'voiceType': "바리톤",
      'albumArtUrl': "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
    },
    {
      'title': "Golden",
      'artist': "HUNTR/X(EJAE, Audrey Nuna...)",
      'voiceType': "바리톤",
      'albumArtUrl': "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
    },
    {
      'title': "Free",
      'artist': "Rumi(EJAE), Jinu(Andrew Choi)",
      'voiceType': "바리톤",
      'albumArtUrl': "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
    },
    {
      'title': "Take Down",
      'artist': "TWICE(정연,지효,채영)",
      'voiceType': "바리톤",
      'albumArtUrl': "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
    },
    {
      'title': "Take Down",
      'artist': "HUNTR/X(EJAE, Audrey Nuna...)",
      'voiceType': "바리톤",
      'albumArtUrl': "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
    },
    {
      'title': "Your Idol",
      'artist': "Saja Boys(Andrew Choi, Neck...)",
      'voiceType': "바리톤",
      'albumArtUrl': "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
    },
    {
      'title': "What It Sounds Like",
      'artist': "HUNTR/X(EJAE, Audrey Nuna...)",
      'voiceType': "바리톤",
      'albumArtUrl': "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
    },
    // 베이스 8곡
    {
      'title': "How It's Done",
      'artist': "HUNTR/X(EJAE, Audrey Nuna...)",
      'voiceType': "베이스",
      'albumArtUrl': "assets/images/album-art.png",
    },
    {
      'title': "Soda Pop",
      'artist': "Saja Boys(Andrew Choi, Neck...)",
      'voiceType': "베이스",
      'albumArtUrl': "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
    },
    {
      'title': "Golden",
      'artist': "HUNTR/X(EJAE, Audrey Nuna...)",
      'voiceType': "베이스",
      'albumArtUrl': "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
    },
    {
      'title': "Free",
      'artist': "Rumi(EJAE), Jinu(Andrew Choi)",
      'voiceType': "베이스",
      'albumArtUrl': "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
    },
    {
      'title': "Take Down",
      'artist': "TWICE(정연,지효,채영)",
      'voiceType': "베이스",
      'albumArtUrl': "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
    },
    {
      'title': "Take Down",
      'artist': "HUNTR/X(EJAE, Audrey Nuna...)",
      'voiceType': "베이스",
      'albumArtUrl': "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
    },
    {
      'title': "Your Idol",
      'artist': "Saja Boys(Andrew Choi, Neck...)",
      'voiceType': "베이스",
      'albumArtUrl': "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
    },
    {
      'title': "What It Sounds Like",
      'artist': "HUNTR/X(EJAE, Audrey Nuna...)",
      'voiceType': "베이스",
      'albumArtUrl': "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
    }


  ];

  @override
  Widget build(BuildContext context) {

    final List<Map<String, String>> filteredSongList = selectedVoiceType == '전체'
        ? songList
        : songList.where((song) => song['voiceType'] == selectedVoiceType).toList();

    return Scaffold(
      backgroundColor: AppColors.grayscale8,
      body: SafeArea(
        child: Column(
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
                separatorBuilder: (context, idx) =>  Container(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  color: AppColors.grayscale6,
                  width: double.infinity,
                  height: 1,
                ),
                itemBuilder: (context, idx) {
                  final song = filteredSongList[idx];

                  return GestureDetector(
                    onTap: () {
                      context.go(AppRoutePaths.soloSongDetail, extra: SongDetailModel.fromJson(song));
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
                            child: song['albumArtUrl']!.startsWith('assets') ?
                            Image.asset(
                              song['albumArtUrl']!,
                              width: 80.w,
                              height: 80.h,
                              fit: BoxFit.cover,
                            )
                                : Image.network(
                              song['albumArtUrl']!,
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
                                  song['title']!,
                                  style:AppTextStyles.body1Bold,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 5.h),
                                Text(
                                  song['artist']!,
                                  style: AppTextStyles.body2.copyWith(
                                      color: AppColors.grayscale3
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 5.h),
                                Container(
                                  height: 20.h ,
                                  width: 60.w,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.grayscale3,
                                    borderRadius: BorderRadius.circular(12.w),
                                  ),
                                  child: Text(
                                    song['voiceType']!,
                                    style: AppTextStyles.body6.copyWith(
                                        color: AppColors.grayscale8
                                    ) ,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 20.w),
                        ],
                      ),
                    ),
                  ) ;
                },
              ),
            ),
          ],
        ),

      ),
    );
  }
}
