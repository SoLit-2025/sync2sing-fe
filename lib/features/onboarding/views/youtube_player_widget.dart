import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logics/watch_youtube_providers.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubePlayerWidget extends ConsumerStatefulWidget {
  final String videoId;
  final int videoStartSec;

  const YoutubePlayerWidget({super.key, required this.videoId, this.videoStartSec = 0});

  @override
  ConsumerState<YoutubePlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends ConsumerState<YoutubePlayerWidget> {
  late YoutubePlayerController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: YoutubePlayerFlags(autoPlay: false, startAt: widget.videoStartSec), // 자동 재생 금지
    );

    _startWatchTracking();
  }

  void _startWatchTracking() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      // 1초 간격으로 추적
      if (_controller.value.isPlaying) {
        ref
            .read(watchedDurationProvider.notifier)
            .update((current) => current + Duration(seconds: 1));
      }
    });
  }

  @override
  void dispose() {
    // '중지' 버튼을 누르지 않고 다른 페이지로 이동하는 경우 -> 소리가 계속 나옴
    _timer?.cancel();
    _controller.pause();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(controller: _controller, showVideoProgressIndicator: true);
  }
}
