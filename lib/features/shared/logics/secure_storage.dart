import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class SecureStorage {
  static final SecureStorage _instance = SecureStorage._internal();
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  factory SecureStorage() {
    return _instance;
  }

  SecureStorage._internal();

  /// accessToken 저장
  Future<void> saveAccessToken(String accessToken) async {
    try {
      await storage.write(key: 'ACCESS_TOKEN', value: accessToken);
      debugPrint('AccessToken 저장 성공: $accessToken');
    } catch (e) {
      debugPrint('AccessToken 저장 실패: $e');
    }
  }

  /// refreshToken 저장
  Future<void> saveRefreshToken(String refreshToken) async {
    try {
      await storage.write(key: 'REFRESH_TOKEN', value: refreshToken);
      debugPrint('RefreshToken 저장 성공: $refreshToken');
    } catch (e) {
      debugPrint('RefreshToken 저장 실패: $e');
    }
  }

  /// accessToken 읽기
  Future<String?> readAccessToken() async {
    try {
      final token = await storage.read(key: 'ACCESS_TOKEN');
      debugPrint('AccessToken 읽기: $token');
      return token;
    } catch (e) {
      debugPrint('AccessToken 읽기 실패: $e');
      return null;
    }
  }

  /// refreshToken 읽기
  Future<String?> readRefreshToken() async {
    try {
      final token = await storage.read(key: 'REFRESH_TOKEN');
      debugPrint('RefreshToken 읽기: $token');
      return token;
    } catch (e) {
      debugPrint('RefreshToken 읽기 실패: $e');
      return null;
    }
  }

  /// 저장된 토큰 모두 삭제 (로그아웃용)
  Future<void> deleteTokens() async {
    try {
      await storage.delete(key: 'ACCESS_TOKEN');
      await storage.delete(key: 'REFRESH_TOKEN');
      debugPrint('토큰 삭제 성공');
    } catch (e) {
      debugPrint('토큰 삭제 실패: $e');
    }
  }
}
