import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioFactory {
  final FlutterSecureStorage storage;

  DioFactory(this.storage);

  Dio createDio() {
    final options = BaseOptions(
      baseUrl: 'http://13.125.152.131:8080',
      connectTimeout: const Duration(seconds: 100),
      receiveTimeout: const Duration(seconds: 100),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    final dio = Dio(options);

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if(!options.path.contains('/login') && !options.path.contains('/signup')){
          final accessToken = await storage.read(key: 'ACCESS_TOKEN');
          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        // 추후 토큰 갱신 로직 추가 작성 예정
        return handler.next(error);
      },
    ));

    return dio;
  }
}
