import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 현재 시점에서 부를 음정 (예: 악보 기준 음정)
final targetPitchProvider = StateProvider<int>((ref) => 100);
