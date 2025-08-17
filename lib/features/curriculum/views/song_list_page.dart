import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/features/curriculum/logics/song_detail_model.dart';
import 'package:sync2sing/features/curriculum/logics/timed_lyric.dart';
import 'package:sync2sing/features/shared/logics/training_mode.dart';

class SongListPage extends StatelessWidget {
  final TrainingMode trainingMode;
  const SongListPage({super.key, required this.trainingMode});

  @override
  Widget build(BuildContext context) {
    SongDetailModel songDetailModel = SongDetailModel(
      3,
      "Golden",
      "HUNXR/X(EJAE, Audrey NUNA, REI AMI",
      "SOFRANO",
      "A3",
      "C4",
      [
        TimedLyric(0, "I'm done hidin", 100),
        TimedLyric(1, "now I'm shinin'", 2000),
        TimedLyric(2, "like I'm born to be", 3000),
        TimedLyric(3, "We dreamin' hard", 5000),
        TimedLyric(4, "we came so far", 7000),
        TimedLyric(5, "now I believe", 9000),
      ],
      "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/images/album-cover/5fe33ac0-fd48-4fdb-908a-12441469fea3.jpg",
      "https://sync2sing-bucket.s3.ap-northeast-2.amazonaws.com/audios/original/6875743e-3955-4067-abed-da1911a6aae1.mp3",
    );
    List<DuetPart> duetParts = [
      DuetPart(partNumber: 1, partName: "파트 A", lyricsIndexes: [1, 2]),
    ];
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text("SongListPage - $trainingMode"),
            SizedBox(
              width: 327.w,
              height: 50.w,
              child: CupertinoButton(
                borderRadius: BorderRadius.circular(10.w),
                onPressed: () {
                  context.goNamed(AppRouteNames.soloSongDetail, extra: songDetailModel);
                },
                child: Text("soloSongDetailPage"),
              ),
            ),
            SizedBox(
              width: 327.w,
              height: 50.w,
              child: CupertinoButton(
                borderRadius: BorderRadius.circular(10.w),
                onPressed: () {
                  context.goNamed(
                    AppRouteNames.duetSongDetail,
                    extra: (songDetailModel: songDetailModel, duetParts: duetParts),
                  );
                },
                child: Text("duetDetailPage"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
