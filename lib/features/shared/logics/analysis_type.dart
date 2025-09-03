enum AnalysisType {
  pre('PRE'),
  post('POST'),
  guest('GUEST');

  final String apiValue;
  const AnalysisType(this.apiValue);

  static AnalysisType fromName(String name) =>
      AnalysisType.values.firstWhere((e) => e.name == name);
}
