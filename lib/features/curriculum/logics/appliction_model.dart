class ApplicationModel {
  int id;
  int applicantId;
  String applicantNickname;
  DateTime requestedAt;

  ApplicationModel({
    required this.id,
    required this.applicantId,
    required this.applicantNickname,
    required this.requestedAt,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id'] ?? -1,
      applicantId: json['applicant_id'] ?? -1,
      applicantNickname: json['applicant_nickname'] ?? '',
      requestedAt: DateTime.parse(json['requested_at'] ?? ''),
    );
  }
}
