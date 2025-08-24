import 'package:dio/dio.dart';

class AuthApi {
  final Dio dio;

  AuthApi(this.dio);

  /// 회원가입 API
  Future<Map<String, dynamic>> signUp({
    required String username,
    required String password,
    required String nickname,
  }) async {
    try {
      final response = await dio.post(
        '/api/user/signup',
        data: {
          'username': username,
          'password': password,
          'nickname': nickname,
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
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '/api/user/login',
        data: {
          'username': username,
          'password': password,
        },
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
  Future<void> logout({
    required String refreshToken,
  }) async {
    try {
      final response = await dio.post(
        '/api/user/logout',
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {
            // accessToken은 Dio 인터셉터에서 자동으로 붙여준다고 가정
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('로그아웃 실패: ${response.data['message']}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
