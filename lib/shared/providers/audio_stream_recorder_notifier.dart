import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';

final audioStreamRecorderProvider =
    StateNotifierProvider.autoDispose<AudioStreamRecorderNotifier, bool>((ref) {
      final notifier = AudioStreamRecorderNotifier();

      ref.onDispose(() {
        notifier.stop(); // 녹음 중이면 멈추고
        notifier.disposeRecorder(); // 리소스 해제
      });
      return notifier;
    });

class AudioStreamRecorderNotifier extends StateNotifier<bool> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final StreamController<List<Int16List>> _audioStreamController =
      StreamController<List<Int16List>>.broadcast();
  final List<Int16List> _recordedChunks = [];
  final pitchDetector = PitchDetector(audioSampleRate: 44100, bufferSize: 8192);
  bool _isInitialized = false;
  late String _filePath;
  IOSink? _fileSink;
  File? _outputFile;

  AudioStreamRecorderNotifier() : super(false);

  Future<void> init() async {
    if (_isInitialized) return;
    await _recorder.openRecorder();
    await _recorder.setSubscriptionDuration(const Duration(milliseconds: 10));
    _audioStreamController.stream.listen((chunks) {
      final monoBuffer = chunks[0];

      // 파일에 쓰기 - 문제: 파일이 깨지는 듯..
      _fileSink?.add(monoBuffer.buffer.asUint8List());

      // pitch 분석 처리 가능
    });

    _isInitialized = true;
  }

  Future<void> start() async {
    // 녹음 시작: init() 부분도 포함됨

    await init();
    if (state) return;
    _recordedChunks.clear();

    // final dir = await getApplicationDocumentsDirectory();
    final dir =
        await getTemporaryDirectory(); // 접근 권한 문제로 다른 경로 설정 : app의 cache 부분에 저장됨

    final fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}.pcm';
    _filePath = '${dir.path}/$fileName';
    _outputFile = File(_filePath);
    _fileSink = _outputFile!.openWrite();

    try {
      if (_recorder.isRecording) {
        await _recorder.stopRecorder();
      }

      await _recorder.startRecorder(
        codec: Codec.pcm16,
        sampleRate: 44100,
        bufferSize: 4096,
        numChannels: 1,
        // toFile: _filePath,
        toStreamInt16: _audioStreamController.sink,
        audioSource: AudioSource.microphone,
      );
    } catch (e, stack) {
      print('❌ [Recorder] startRecorder() 실패: $e');
      print(stack);
      return;
    }

    state = true;
  }

  Future<void> pause() async {
    if (_recorder.isPaused) return;
    await _recorder.pauseRecorder();
    state = false;
  }

  Future<void> resume() async {
    // 추후 삭제될 수도 (startOrResume에 해당 부분이 삽입됨)
    if (!_recorder.isPaused) return;
    await _recorder.resumeRecorder();
    state = true;
  }

  Future<void> startOrResume() async {
    if (_recorder.isPaused) {
      await resume();
    } else {
      await start();
    }
  }

  Future<void> stop() async {
    // if (!state) return;
    await _recorder.stopRecorder();
    await _fileSink?.flush();
    await _fileSink?.close();
    _fileSink = null;
    // state = false;
  }

  Future<void> disposeRecorder() async {
    await _recorder.closeRecorder();
    await _audioStreamController.close();
    _isInitialized = false;
  }
}
