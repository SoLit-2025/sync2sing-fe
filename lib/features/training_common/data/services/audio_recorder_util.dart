import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';

class PitchData {
  final double pitch;
  final double probability;

  PitchData({required this.pitch, required this.probability});
}

class AudioRecorderUtil {
  final bool isFileSave;
  final bool isPitchDetection;
  final bool isRhythmDetection;
  final void Function(double pitch)? onPitchDetected;
  static const int _bufferSize = 2048;

  late final FlutterSoundRecorder _recorder;
  IOSink? _fileSink;
  StreamController<PitchData>? _pitchStreamController;
  late final PitchDetector _pitchDetector;

  AudioRecorderUtil({
    this.isFileSave = false,
    this.isPitchDetection = false,
    this.onPitchDetected,
    this.isRhythmDetection = false,
  });

  // 초기화: flutterSoundRecorder pitchDetector
  Future<void> init() async {
    _recorder = FlutterSoundRecorder();
    await _recorder.openRecorder();

    if (isPitchDetection) {
      _pitchDetector = PitchDetector(
        audioSampleRate: 44100,
        bufferSize: _bufferSize,
      );
      _pitchStreamController = StreamController<PitchData>.broadcast();
    }
  }

  Stream<PitchData>? get pitchStream => _pitchStreamController?.stream;

  // 녹음 시작 여부에 따라 녹음 시작/재생
  Future<void> startOrResumeRecorder() async {
    if (_recorder.isPaused && !_recorder.isStopped) {
      _recorder.resumeRecorder();
    } else {
      startRecorder();
    }
  }

  // 녹음 시작
  Future<void> startRecorder() async {
    if (isFileSave) {
      _fileSink = await _createFileSink();
    }

    final controller = StreamController<Uint8List>();
    controller.stream.listen((buffer) async {
      if (isFileSave) {
        // 파일에 저장해야 하는 경우
        _fileSink?.add(buffer);
      }

      if (isPitchDetection) {
        // 음정 탐지해야 하는 경우 버퍼에 추가
        _addBufferUtilBufferSize(buffer);
      }

      if (isRhythmDetection) {
        // TODO: 박자 처리 관련 로직
        //  실시간으로 처리할 필요 없는 경우 삭제
      }
    });

    await _recorder.startRecorder(
      toStream: controller.sink,
      codec: Codec.pcm16,
      sampleRate: 44100,
      numChannels: 1,
      bufferSize: _bufferSize,
    );
  }

  Future<void> pauseRecorder() async {
    await _recorder.pauseRecorder();
  }

  Future<void> stopRecorder() async {
    await _recorder.stopRecorder();
    await _fileSink?.close();
  }

  Future<void> dispose() async {
    await stopRecorder();
    await _recorder.closeRecorder();
    await _pitchStreamController?.close();
  }

  // 파일 형태로 저장
  Future<IOSink> _createFileSink() async {
    final tempDir = await getTemporaryDirectory();
    final file = File(
      '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.pcm',
    );
    if (file.existsSync()) await file.delete();
    return file.openWrite();
  }

  // 실시간 음정탐지 로직
  // 누적 버퍼 변수
  List<int> _accumulatedBuffer = [];
  int requiredBytes = _bufferSize * 2;

  void _addBufferUtilBufferSize(Uint8List newData) async {
    // 1. 새 데이터 누적
    _accumulatedBuffer.addAll(newData);

    // 2. 충분한 데이터가 모일 때까지 반복 처리
    while (_accumulatedBuffer.length >= requiredBytes) {
      // 3. 필요한 만큼 데이터 추출 (4096 bytes)
      final chunk = Uint8List.fromList(
        _accumulatedBuffer.sublist(0, requiredBytes),
      );

      // 4. 남은 데이터 유지
      _accumulatedBuffer = _accumulatedBuffer.sublist(requiredBytes);

      // 5. 피치 감지 로직 실행
      if (chunk.length / 2 < _pitchDetector.bufferSize) return;

      final result = await _pitchDetector.getPitchFromIntBuffer(chunk);
      if (result.pitched) {
        _pitchStreamController?.add(
          PitchData(pitch: result.pitch, probability: result.probability),
        );
      }
    }
  }
}
