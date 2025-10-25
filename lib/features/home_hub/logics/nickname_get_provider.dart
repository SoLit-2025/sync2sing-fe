import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync2sing/features/shared/logics/dio_factory.dart';
import 'package:sync2sing/features/shared/logics/secure_storage.dart';

// todo: 로그아웃 시 이름 지우기
class NicknameManager {
  String? nickName;

  Future<String> fetchNickname() async {
    final response = await DioFactory(SecureStorage()).get('/user');
    return response.data['data']['nickname'];
  }
}

final nicknameGetProvider = FutureProvider<String>((ref) async {
  final nickname = await NicknameManager().fetchNickname();
  return nickname;
});
