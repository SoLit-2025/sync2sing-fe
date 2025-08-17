class TrainingItem {
  final int id;
  final String title;
  final String category;
  final String description;
  final String grade;
  final int trainingMinutes;
  final int progress;
  final bool isCurrentTraining;

  TrainingItem({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.grade,
    required this.trainingMinutes,
    required this.progress,
    required this.isCurrentTraining,
  });
}
