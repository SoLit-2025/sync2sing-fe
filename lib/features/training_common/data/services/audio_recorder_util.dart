import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sync2sing/features/training_common/data/services/save_wav_file.dart';

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
  static const int _sampleRate = 44100;
  static const int _numberOfChannel = 1;
  late final FlutterSoundRecorder _recorder;

  StreamController<PitchData>? _pitchStreamController;
  late final PitchDetector _pitchDetector;

  String? _recordingFilePath; // 파일 경로
  RandomAccessFile? _wavFile; // file 저장
  int _totalDataSize = 0; // 누적 PCM 데이터 크기 추적

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
      await _createWavFile();
      _totalDataSize = 0;
    }

    final controller = StreamController<Uint8List>();
    controller.stream.listen((buffer) async {
      if (isFileSave) {
        // 파일에 저장해야 하는 경우
        await _wavFile!.writeFrom(buffer);
        _totalDataSize += buffer.length; // 데이터 크기 누적
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
      sampleRate: _sampleRate,
      numChannels: _numberOfChannel,
      bufferSize: _bufferSize,
    );
  }

  Future<void> pauseRecorder() async {
    await _recorder.pauseRecorder();
  }

  Future<void> stopRecorder() async {
    await _recorder.stopRecorder();

    // 헤더 덮어쓰기
    if (isFileSave && _recordingFilePath != null) {
      // 헤더 업데이트
      await _wavFile!.setPosition(0);
      final updatedHeader = SaveWavFile.buildHeader(
        sampleRate: 44100,
        channels: 1,
        bitsPerSample: 16,
        pcmDataSize: _totalDataSize, // 실제 데이터 크기 반영
      );
      await _wavFile!.writeFrom(updatedHeader);
      await _wavFile!.close();
      _wavFile = null;
    }
  }

  Future<void> dispose() async {
    await stopRecorder();
    await _recorder.closeRecorder();
    await _pitchStreamController?.close();
  }

  // 파일 생성 및 헤더 초기화
  Future<void> _createWavFile() async {
    final tempDir = await getTemporaryDirectory();
    _recordingFilePath =
        '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';

    final header = SaveWavFile.buildHeader(
      sampleRate: 44100,
      channels: 1,
      bitsPerSample: 16,
      pcmDataSize: 0,
    );

    _wavFile = await SaveWavFile.createFile(
      path:
          '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav',
      header: header,
    );

    // final file = File(_recordingFilePath!);
    // if (file.existsSync()) await file.delete();
    //
    // _wavFile = await file.open(mode: FileMode.write);
    //
    // // 초기 헤더 작성 (데이터 크기 0으로 임시 설정)
    // final header = buildWavHeader(
    //   sampleRate: 44100,
    //   channels: 1,
    //   bitsPerSample: 16,
    //   pcmDataSize: 0,
    // );
    // await _wavFile!.writeFrom(header);
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
        // print("flutter: pitch: ${result.pitch}");
        _pitchStreamController?.add(
          PitchData(pitch: result.pitch, probability: result.probability),
        );
      }
    }
  }
}
