class TimedLyric {
  final int index;
  final String text;
  final int startTime;
  final int? partNumber;

  /// 시작 시간 (단위: ms)

  TimedLyric(this.index, this.text, this.startTime, {this.partNumber});

  factory TimedLyric.fromJson(Map<String, dynamic> json) {
    return TimedLyric(
      json['line_index'] ?? 0,
      json['text'] ?? '',
      json['start_time'] ?? 0,
      partNumber: json['part_number'] ?? 0,
    );
  }
}
