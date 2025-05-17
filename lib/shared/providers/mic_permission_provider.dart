import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

final micPermissionProvider =
StateNotifierProvider<MicPermissionNotifier, PermissionStatus>((ref) {
  return MicPermissionNotifier();
});

class MicPermissionNotifier extends StateNotifier<PermissionStatus> {
  MicPermissionNotifier() : super(PermissionStatus.denied);

  Future<void> checkPermission() async {
    final status = await Permission.microphone.status;
    state = status;
  }

  Future<void> requestPermission() async {
    final result = await Permission.microphone.request();
    state = result;

    if (result.isPermanentlyDenied) {
      // 앱 설정 열기 유도
      openAppSettings();
    }
  }

  bool get isGranted => state.isGranted;
}
