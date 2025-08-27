import 'package:sync2sing/features/shared/logics/dio_factory.dart';

class SoloTrainingService {
  final DioFactory dioFactory;

  SoloTrainingService(this.dioFactory);

  /// 솔로 트레이닝 세션 생성
  Future<Map<String, dynamic>> createSoloTrainingSession({
    required int songId,
    required int trainingDays,
    int keyAdjustment = 0, // 하드코딩된 기본값
  }) async {
    try {
      final response = await dioFactory.post(
        '/solo-training/session',
        data: {
          'song_id': songId,
          'key_adjustment': keyAdjustment,
          'training_days': trainingDays,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
