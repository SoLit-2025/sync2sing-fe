import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubePlayerWidget extends StatefulWidget {
  const YoutubePlayerWidget({super.key});

  @override
  State<YoutubePlayerWidget> createState() => _YoutubePlayerWidgetState();
}

class _YoutubePlayerWidgetState extends State<YoutubePlayerWidget> {
  static String youtubeId = 'Qy9cj-zwbVY';

  final YoutubePlayerController _con = YoutubePlayerController(
    initialVideoId: youtubeId,

    flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
  );

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      controller: _con,
      showVideoProgressIndicator: true,
      aspectRatio: 4 / 3,
      // progressIndicatorColor: Colors.amber,
      // progressColors: const ProgressBarColors(
      //   playedColor: Colors.amber,
      //   handleColor: Colors.amberAccent,
      // ),
      onReady: () {
        print('plalyer is ready.');
      },
    );
  }
}
