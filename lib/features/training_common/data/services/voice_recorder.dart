import 'package:path_provider/path_provider.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';
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
    // 고유 파일명 생성, 확장자 .wav로 지정
    _recordedFilePath = '${dir.path}/origin_voice_${DateTime.now().millisecondsSinceEpoch}.audios';
    _recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        numChannels: 1,
        bitRate: 128000,
        sampleRate: PitchDetector.DEFAULT_SAMPLE_RATE,
      ),
    );

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav, // wav 포맷으로 저장
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
