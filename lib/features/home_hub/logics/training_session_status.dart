import 'training_item.dart';

enum TrainingSessionStatus {
  // 세션 상태 : 세션 생성 전 | BEFORE_TRAINING (백엔드 api 참조) | TRAINING_IN_PROGRESS | AFTER_TRAINING
  beforeSession,
  beforeTraining,
  trainingInProgress,
  afterTraining,
  error,
}

extension TrainingStatusConverter on TrainingSessionStatus {
  // ['data']['status']로 들어온 값을 TrainingSessionStatus로 변환
  static TrainingSessionStatus fromDataStatusString(String dataStatusString) {
    switch (dataStatusString) {
      case 'BEFORE_TRAINING':
        return TrainingSessionStatus.beforeTraining;
      case 'TRAINING_IN_PROGRESS':
        return TrainingSessionStatus.trainingInProgress;
      case 'AFTER_TRAINING':
        return TrainingSessionStatus.afterTraining;
      default:
        return TrainingSessionStatus.error;
    }
  }
}

TrainingSessionStatus getTrainingStatusFromJson(Map<String, dynamic> decodedJson) {
  try {
    final Map<String, dynamic> data = decodedJson; // decodedJson['data'] as Map<String, dynamic>?;

    // data가 빈 객체이면 -> beforeSession
    if (data.isEmpty) {
      return TrainingSessionStatus.beforeSession;
    }

    final String? dataStatus = data['status'] as String?;
    if (dataStatus == null) {
      return TrainingSessionStatus.error;
    }
    return TrainingStatusConverter.fromDataStatusString(dataStatus);
  } on FormatException {
    return TrainingSessionStatus.error;
  } on TypeError {
    // 'status'가 String이 아니거나 'data'가 map이 아닐 때 등 타입예외 발생 시
    return TrainingSessionStatus.error;
  } catch (e) {
    return TrainingSessionStatus.error;
  }
}

// pitch-rhythm-pronunciation-breath 인터리브 + 완료 항목 마지막으로 이동
List<TrainingItem> parseCurriculumItemsInOrderAndPostCompletedLast(
  Map<String, dynamic> curriculum,
) {
  final List pitch = curriculum['pitch'] ?? [];
  final List rhythm = curriculum['rhythm'] ?? [];
  final List pronunciation = curriculum['pronunciation'] ?? [];
  final List breath = curriculum['breath'] ?? [];
  int maxLen = [
    pitch.length,
    rhythm.length,
    pronunciation.length,
    breath.length,
  ].reduce((a, b) => a > b ? a : b);

  List<TrainingItem> preList = [];
  List<TrainingItem> completed = [];

  for (int i = 0; i < maxLen; i++) {
    void add(Map item, String key) {
      final t = TrainingItem(
        id: item['id'],
        title: item['title'],
        category: _categoryKr[key] ?? key,
        description: item['description'],
        grade: item['grade'],
        trainingMinutes: item['training_minutes'],
        progress: item['progress'],
        // isCurrentTraining: item['is_current_training'],
      );
      if (t.progress >= 100) {
        completed.add(t);
      } else {
        preList.add(t);
      }
    }

    if (i < pitch.length) add(pitch[i], 'pitch');
    if (i < rhythm.length) add(rhythm[i], 'rhythm');
    if (i < pronunciation.length) add(pronunciation[i], 'pronunciation');
    if (i < breath.length) add(breath[i], 'breath');
  }

  return [...preList, ...completed];
}

const Map<String, String> _categoryKr = {
  // category 항목의 영어를 한글로 변환
  'pitch': '음정',
  'rhythm': '박자',
  'pronunciation': '발음',
  'breath': '호흡',
};
