import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync2sing/shared/providers/mic_permission_provider.dart';

Future<bool> ensureMicPermission(WidgetRef ref) async {
  final notifier = ref.read(micPermissionProvider.notifier);

  await notifier.checkPermission();

  if (!notifier.isGranted) {
    await notifier.requestPermission();
  }

  return notifier.isGranted;
}
