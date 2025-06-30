import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 노래 재생 위치(시간)를 공유하는 Provider
final audioPositionProvider = StateProvider<Duration>((ref) => Duration.zero);
