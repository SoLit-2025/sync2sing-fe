import 'dart:io';
import 'dart:typed_data';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';

class VoiceRecorderService {
  final Record _recorder = Record();
  final PitchDetector _pitchDetector = PitchDetector(44100, 2000);

  List<String> _detectedNotes = [];
  StreamSubscription<Uint8List>? _streamSubscription;

  /// 녹음 시작 및 실시간 음정 분석
  Future<void> startRecording() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/voice_sample_${DateTime.now().millisecondsSinceEpoch}.wav';

    await _recorder.start(
      path: path,
      encoder: AudioEncoder.pcm16bits,
      samplingRate: 44100,
    );

    // 실시간 버퍼 스트림 처리
    _streamSubscription = _recorder.onAmplitudeChanged().listen((buffer) {
      final audioBuffer = buffer.sublist(44); // WAV 헤더 제거
      final result = _pitchDetector.getPitchFromIntBuffer(audioBuffer);
      if (result.pitched) {
        _detectedNotes.add(result.note);
      }
    });
  }

  /// 녹음 종료 및 중심 음역대 계산
  Future<String?> stopRecording() async {
    await _streamSubscription?.cancel();
    final path = await _recorder.stop();

    // 가장 빈번한 음정 계산
    if (_detectedNotes.isNotEmpty) {
      final frequencyMap = _detectedNotes.fold<Map<String, int>>(
          {},
              (map, note) => map..[note] = (map[note] ?? 0) + 1
      );

      return frequencyMap.entries.reduce(
              (a, b) => a.value > b.value ? a : b
      ).key;
    }
    return null;
  }

  void dispose() {
    _recorder.dispose();
  }
}
