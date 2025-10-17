import 'package:sync2sing/features/shared/logics/dio_factory.dart';

class AuthApi {
  final DioFactory dioFactory;

  AuthApi(this.dioFactory);

  /// 회원가입 API
  Future<Map<String, dynamic>> signUp({
    required String username,
    required String password,
    required String nickname,
    required String gender,
    required int age,
    required String voiceType,
    String? pitchNoteMin,
    String? pitchNoteMax,
    int? reportId,
  }) async {
    try {
      final response = await dioFactory.post(
        '/user/signup',
        data: {
          'username': username,
          'password': password,
          'nickname': nickname,
          'gender': gender,
          'age': age,
          'pitch_note_min': pitchNoteMin ?? " ",
          'pitch_note_max': pitchNoteMax ?? " ",
          'voice_type': voiceType,
          if (reportId != null) 'report_id': reportId,
        },
      );

      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('회원가입 실패: ${response.data['message']}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 로그인 API
  Future<Map<String, dynamic>> login({required String username, required String password}) async {
    try {
      final response = await dioFactory.post(
        '/user/login',
        data: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('로그인 실패: ${response.data['message']}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 로그아웃 API
  Future<void> logout({required String refreshToken}) async {
    try {
      final response = await dioFactory.post('/user/logout', data: {'refreshToken': refreshToken});

      if (response.statusCode != 200) {
        throw Exception('로그아웃 실패: ${response.data['message']}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
