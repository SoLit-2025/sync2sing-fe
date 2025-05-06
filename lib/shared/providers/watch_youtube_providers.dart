import 'package:flutter_riverpod/flutter_riverpod.dart';

// 시청한 시간
final watchedDurationProvider = StateProvider<Duration>((ref) => Duration.zero);

// 버튼 활성화 여부 (10초 이상 시청했는지)
final isOnboardingRecordingStartButtonEnabledProvider = Provider<bool>((ref) {
  final duration = ref.watch(watchedDurationProvider);
  return duration.inSeconds >= 10;
});
