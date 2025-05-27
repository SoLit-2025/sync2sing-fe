import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

// 사용자 음성 녹음
class VoiceRecorder {
  final AudioRecorder _recorder = AudioRecorder();
  String? _recordedFilePath;
  bool _isRecording = false;

  // 녹음 시작
  Future<void> startRecording() async {
    if (_isRecording) return; // 이미 녹음 중이면 무시
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      throw Exception('마이크 권한이 필요합니다.');
    }
    final dir = await getApplicationDocumentsDirectory();
    // 유니크 파일명 생성
    _recordedFilePath = '${dir.path}/origin_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: _recordedFilePath!,
    );
    _isRecording = true;
  }

  // 녹음 종료
  Future<void> stopRecording() async {
    if (_isRecording) {
      await _recorder.stop();
      _isRecording = false;
    }
  }

  // 녹음된 파일 경로 반환
  String? getRecordedFilePath() => _recordedFilePath;
}
