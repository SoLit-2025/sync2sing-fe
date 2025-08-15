class TimedLyric {
  final int index;
  final String text;
  final int startTime;

  /// 시작 시간 (단위: ms)

  TimedLyric(this.index, this.text, this.startTime);

  factory TimedLyric.fromJson(Map<String, dynamic> json) {
    return TimedLyric(json['line_index'] ?? 0, json['text'] ?? '', json['start_time'] ?? 0);
  }
}
