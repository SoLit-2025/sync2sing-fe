import 'package:sync2sing/features/shared/logics/dio_factory.dart';

class SoloTrainingService {
  final DioFactory dioFactory;

  SoloTrainingService(this.dioFactory);

  /// 솔로 트레이닝 세션 생성
  Future<Map<String, dynamic>> createSoloTrainingSession({
    required int songId,
    required int trainingDays,
  }) async {
    try {
      final response = await dioFactory.post(
        '/solo-training/session',
        data: {'song_id': songId, 'training_days': trainingDays},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
