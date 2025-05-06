import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync2sing/shared/providers/watch_youtube_providers.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubePlayerWidget extends ConsumerStatefulWidget {
  final String videoId;
  final YoutubePlayerFlags flags;

  const YoutubePlayerWidget({
    super.key,
    required this.videoId,
    required this.flags,
  });

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
      flags: widget.flags,
    );

    _startWatchTracking();
  }

  void _startWatchTracking() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      // 1초 간격으로 추적
      if (_controller.value.isPlaying) {
        final current = ref.read(watchedDurationProvider);
        ref.read(watchedDurationProvider.notifier).state =
            current + Duration(seconds: 1);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      controller: _controller,
      showVideoProgressIndicator: true,
    );
  }
}
