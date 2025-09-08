import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:sync2sing/features/shared/logics/secure_storage.dart';

class DioFactory {
  final SecureStorage secureStorage;
  final String contentType;
  late final Dio _dio;

  DioFactory(this.secureStorage, {this.contentType = 'application/json'}) {
    _dio = createDio();
  }

  Dio createDio() {
    final options = BaseOptions(
      baseUrl: 'http://13.125.152.131:8080/api',
      connectTimeout: const Duration(seconds: 100),
      receiveTimeout: const Duration(seconds: 100),
      headers: {'Content-Type': contentType},
    );

    final dio = Dio(options);

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (!options.path.contains('/login') && !options.path.contains('/signup')) {
            final accessToken = await secureStorage.readAccessToken();
            if (accessToken != null && accessToken.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $accessToken';
            }
          }

          debugPrint(" 경로: ${options.path} | 데이터: ${options.data}");
          debugPrint(" 경로: ${options.uri} | header: ${options.headers}");
          debugPrint(" 경로: ${options.uri} | method: ${options.method}");
          return handler.next(options);
        },
        onError: (error, handler) {
          debugPrint("dio error: ${error.response?.data}"); // 오류 메시지 확인
          // 추후 토큰 갱신 로직 추가 작성 예정
          return handler.next(error);
        },
      ),
    );

    return dio;
  }

  /// CREATE - 새 데이터 생성
  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  /// READ - 데이터 조회
  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) async {
    return await _dio.get(path, queryParameters: queryParams);
  }

  /// UPDATE - 데이터 수정
  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  /// DELETE - 데이터 삭제
  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }
}
