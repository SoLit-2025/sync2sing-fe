enum TrainingMode {
  solo('SOLO', 'solo-training'),
  duet('DUET', 'duet-training');

  final String apiValue;
  final String apiBasePath;
  const TrainingMode(this.apiValue, this.apiBasePath);

  static TrainingMode fromName(String name) =>
      TrainingMode.values.firstWhere((e) => e.name == name);
}
