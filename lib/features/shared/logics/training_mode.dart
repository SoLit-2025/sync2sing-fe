enum TrainingMode {
  solo('SOLO', '/api/solo-training'),
  duet('DUET', '/api/duet-training');

  final String apiValue;
  final String apiBasePath;
  const TrainingMode(this.apiValue, this.apiBasePath);

  static TrainingMode fromName(String name) =>
      TrainingMode.values.firstWhere((e) => e.name == name);
}
