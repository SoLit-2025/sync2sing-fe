import 'dart:async';
import 'dart:io';
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
  final bool enableRhythmDetection;
  final void Function(double pitch)? onPitchDetected;

  late final FlutterSoundRecorder _recorder;
  IOSink? _fileSink;
  StreamController<PitchData>? _pitchStreamController;
  late final PitchDetector _pitchDetector;

  AudioRecorderUtil({
    this.isFileSave = false,
    this.isPitchDetection = false,
    this.onPitchDetected,
    this.enableRhythmDetection = false,
  });

  Future<void> init() async {
    _recorder = FlutterSoundRecorder();
    await _recorder.openRecorder();

    if (isPitchDetection) {
      _pitchDetector = PitchDetector(audioSampleRate: 44100, bufferSize: 1024);
      _pitchStreamController = StreamController<PitchData>.broadcast();
    }
  }

  Stream<PitchData>? get pitchStream => _pitchStreamController?.stream;

  Future<void> startOrResumeRecorder() async {
    if (_recorder.isPaused) {
      _recorder.resumeRecorder();
    } else {
      startRecorder();
    }
  }

  Future<void> startRecorder() async {
    if (isFileSave) {
      _fileSink = await _createFileSink();
    }

    final controller = StreamController<Uint8List>();
    controller.stream.listen((buffer) async {
      if (isFileSave) {
        _fileSink?.add(buffer);
      }

      if (isPitchDetection) {
        final result = await _pitchDetector.getPitchFromIntBuffer(buffer);
        if (result.pitched) {
          _pitchStreamController?.add(
            PitchData(pitch: result.pitch, probability: result.probability),
          );
        }
      }

      // TODO: enableRhythmDetection 추가 구현 예정
    });

    await _recorder.startRecorder(
      toStream: controller.sink,
      codec: Codec.pcm16,
      sampleRate: 44100,
      numChannels: 1,
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

  Future<IOSink> _createFileSink() async {
    final tempDir = await getTemporaryDirectory();
    final file = File(
      '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.pcm',
    );
    if (file.existsSync()) await file.delete();
    return file.openWrite();
  }
}
