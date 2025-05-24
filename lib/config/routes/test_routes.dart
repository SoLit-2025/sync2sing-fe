import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/shared/utils/audio_player_sample.dart';
import 'package:sync2sing/shared/utils/record_to_stream_example.dart';
import 'package:sync2sing/shared/utils/use_permission.dart';

final List<GoRoute> testRoutes = [
  // GoRoute(
  //   path: '/permission',
  //   builder: (context, state) => const SimpleRecorder(),
  // ),
  // GoRoute(
  //   path: '/record_to_stream',
  //   builder: (context, state) => const RecordToStreamExample(),
  // ),
  // GoRoute(
  //   path: '/audio_player_sample',
  //   builder: (context, state) => const AudioPlayerSample(),
  // ),
  // GoRoute(
  //   path: '/audio_player_sample',
  //   builder: (context, state) {
  //     return AudioPlayerSample(
  //       name: (state.extra as Map<String, dynamic>)["name"],
  //     );
  //   },
  // ),
];
