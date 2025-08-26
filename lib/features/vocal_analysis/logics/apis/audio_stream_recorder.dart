import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import '../tools/save_wav_file.dart';

class PitchData {
  final double pitch;
  final double probability;
  static const double minPitch = 100; // 사용자의 음정으로 수집할 최소 주파수
  static const double maxPitch = 1046; // 사용자의 음정으로 수집할 최대 주파수

  PitchData({required this.pitch, required this.probability});
}

class AudioStreamRecorder {
  final bool isFileSave; // 파일로 저장할 것인가
  final bool isPitchDetection; // 음정 탐지를 할 것인가
  final bool isRhythmDetection; // 박자 분석을 할 것인가
  final void Function(double pitch)? onPitchDetected; // 추후 삭제될 수도 있음

  static const int _bufferSize = 2048;
  static const int _sampleRate = 44100;
  static const int _numberOfChannel = 1;
  late final FlutterSoundRecorder _recorder;
  bool get isPaused => _recorder.isPaused; // _recorder의 상태변수들.
  bool get isRecording => _recorder.isRecording;
  bool get isStopped => _recorder.isStopped;

  StreamController<PitchData>? _pitchStreamController;
  late final PitchDetector _pitchDetector;

  String? recordingFilePath; // 파일 경로
  RandomAccessFile? _wavFile; // file 저장
  int _totalDataSize = 0; // 누적 PCM 데이터 크기 추적

  AudioStreamRecorder({
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
        audioSampleRate: _sampleRate.toDouble(),
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
        _accumulateBufferAndDetectPitch(buffer);
      }
    });

    // 녹음 시작 (다시 재생과 구분됨)
    await _recorder.startRecorder(
      toStream: controller.sink,
      codec: Codec.pcm16,
      sampleRate: _sampleRate,
      numChannels: _numberOfChannel,
      bufferSize: _bufferSize,
    );
  }

  // 녹음 일시 중지
  Future<void> pauseRecorder() async {
    await _recorder.pauseRecorder();
  }

  // 녹음 종료 (다시 시작하려면 startRecorder() 호출)
  Future<void> stopRecorder() async {
    await _recorder.stopRecorder();

    // 헤더 덮어쓰기: 파일 크기 업데이트 필요
    if (isFileSave && _wavFile != null) {
      // 헤더 업데이트
      await _wavFile!.setPosition(0);
      final updatedHeader = SaveWavFile.buildHeader(
        sampleRate: 44100,
        channels: 1,
        bitsPerSample: 16,
        pcmDataSize: _totalDataSize, // 실제 데이터 크기 반영
      );
      await _wavFile!.writeFrom(updatedHeader);
      debugPrint("헤더 붙이기 완료");
      await _wavFile!.close();
      _wavFile = null;
    }

    if (isFileSave) {
      // 파일 최종 검증 로그 추가
      final savedFile = File(recordingFilePath!);
      debugPrint('''
    ▤ 녹음 완료 파일 정보
    → 경로: ${savedFile.path}
    → 존재: ${await savedFile.exists()}
    → 크기: ${(await savedFile.length()) / 1024} KB
    → 수정 시간: ${await savedFile.lastModified()}
    ''');
    }

    debugPrint("recorder dispose");
  }

  Future<void> dispose() async {
    await stopRecorder();
    await _recorder.closeRecorder();
    await _pitchStreamController?.close();
  }

  // wav 파일 생성 및 헤더 초기화
  Future<void> _createWavFile() async {
    final tempDir = await getTemporaryDirectory();
    recordingFilePath = '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';
    debugPrint('▷ WAV 파일 생성 경로: $recordingFilePath');

    final header = SaveWavFile.buildHeader(
      sampleRate: _sampleRate,
      channels: _numberOfChannel,
      bitsPerSample: 16,
      pcmDataSize: 0,
    );

    _wavFile = await SaveWavFile.createFile(path: recordingFilePath!, header: header);
    debugPrint('▷ WAV 파일 초기화 완료: ${_wavFile != null}');
  }

  // 실시간 음정탐지 로직
  // 누적 버퍼 변수
  List<int> _accumulatedBuffer = [];
  int requiredBytes = _bufferSize * 2; // 필요한 바이트 수는 버퍼 사이즈의 두 배

  // 음성 데이터 버퍼 누적 및 음정 탐지 함수
  void _accumulateBufferAndDetectPitch(Uint8List newData) async {
    // 1. 새 데이터 누적
    _accumulatedBuffer.addAll(newData);

    // 2. 충분한 크기의 데이터가 모이면:
    while (_accumulatedBuffer.length >= requiredBytes) {
      // 3. 필요한 만큼 데이터 추출
      final chunk = Uint8List.fromList(_accumulatedBuffer.sublist(0, requiredBytes));

      // 4. 남은 데이터 유지
      _accumulatedBuffer = _accumulatedBuffer.sublist(requiredBytes);

      // 5. 피치 감지 로직 실행
      if (chunk.length / 2 < _pitchDetector.bufferSize) return;
      final result = await _pitchDetector.getPitchFromIntBuffer(chunk);

      // 음정이 추출되고 / 그 음정이 범위 이내면 pitchStreamController에 PitchData를 보냄
      if (result.pitched &&
          result.pitch >= PitchData.minPitch &&
          result.pitch <= PitchData.maxPitch) {
        _pitchStreamController?.add(
          PitchData(pitch: result.pitch, probability: result.probability),
        );
      } else {
        // *** 음정이 감지되지 않으면 가짜 데이터 (pitch: 0, probability: 0) 을 보냄
        _pitchStreamController?.add(PitchData(pitch: 0, probability: 0));
      }
    }
  }
}
