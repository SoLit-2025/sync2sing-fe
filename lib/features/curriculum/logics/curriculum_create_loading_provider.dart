import 'package:flutter_riverpod/flutter_riverpod.dart';

final curriculumCreateLoadingProvider = FutureProvider.autoDispose<void>((ref) async {
  await Future.delayed(const Duration(seconds: 2)); // 2초 지연
});
