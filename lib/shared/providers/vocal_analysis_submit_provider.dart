import 'package:flutter_riverpod/flutter_riverpod.dart';

final vocalAnalysisSubmitProvider = FutureProvider.autoDispose<void>((
  ref,
) async {
  await Future.delayed(const Duration(seconds: 2));
});
