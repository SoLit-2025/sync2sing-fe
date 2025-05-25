import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';

typedef _Fn = void Function();

class AudioRecorderUtil {
  FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();
  final PitchDetector _pitchDetector = PitchDetector(
    audioSampleRate: cstSAMPLERATE.toDouble(),
    bufferSize: 1024,
  );

  static const int cstSAMPLERATE = 44100;
  static const int cstCHANNELNB = 1;

  bool _mRecorderIsInited = false;
  bool mRecorderStarted = false;
  bool mRecordingIsRecording = false;
  String? _mPath;
  Codec codecSelected = Codec.pcm16;

  StreamSubscription? _mRecordingDataSubscription;

  void init() {
    _openRecorder();
  }

  Future<void> _openRecorder() async {
    await _mRecorder!.openRecorder();

    _mRecorderIsInited = true;
  }

  void closeAll() {
    stopRecorder();
    _mRecorder!.closeRecorder();
    _mRecorder = null;
  }

  Future<IOSink> createFile() async {
    var tempDir = await getTemporaryDirectory();
    var timeStamp = DateTime.now().millisecondsSinceEpoch;
    _mPath = '${tempDir.path}/flutter_sound_$timeStamp.pcm';
    var outputFile = File(_mPath!);
    if (outputFile.existsSync()) {
      await outputFile.delete();
    }
    return outputFile.openWrite();
  }

  Future<void> record() async {
    StreamSink<List<int>>? sink;
    sink = await createFile();

    var recordingDataController = StreamController<Uint8List>();
    _mRecordingDataSubscription = recordingDataController.stream.listen((
      buffer,
    ) {
      sink!.add(buffer);
      _pitchDetector.getPitchFromIntBuffer(buffer).then((result) {
        if (result.pitched) {
          // 오류: stream으로 받은 버퍼 크기가 pitchDetector 에 지정한 버퍼 사이즈보다 작음
          // TODO : 위젯에서 pitch를 받을 수 있게 수정
          print(
            "flutter - jhj: getPitch ${result.pitch} | probibility: ${result.probability}",
          );
        } else {
          print("flutter - jhj:result no pitched");
        }
      });
    });
    await _mRecorder!.startRecorder(
      toStream: recordingDataController.sink,
      codec: codecSelected,
      numChannels: cstCHANNELNB,
      sampleRate: cstSAMPLERATE,
      bufferSize: 8192,
      audioSource: AudioSource.defaultSource,
    );
    mRecorderStarted = true;
    mRecordingIsRecording = true;
    _mRecorderIsInited = true;
  }

  Future<void> pauseRecorder() async {
    await _mRecorder!.pauseRecorder();
    mRecordingIsRecording = false;
  }

  Future<void> resumeRecorder() async {
    await _mRecorder!.resumeRecorder();
    mRecordingIsRecording = true;
  }

  Future<void> startOrResumeRecorder() async {
    (mRecorderStarted && _mRecorder!.isPaused)
        ? await resumeRecorder()
        : await record();
  }

  _Fn? getRecorderFn() {
    if (!_mRecorderIsInited) {
      return null;
    }
    return _mRecorder!.isStopped
        ? record
        : () {
          stopRecorder().then((value) => (() {}));
        };
  }

  Future<void> stopRecorder() async {
    await _mRecorder!.stopRecorder();

    if (_mRecordingDataSubscription != null) {
      await _mRecordingDataSubscription!.cancel();
      _mRecordingDataSubscription = null;
    }

    mRecordingIsRecording = false;
  }
}
