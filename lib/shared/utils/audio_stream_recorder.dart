import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';

class AudioStreamRecorder {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final StreamController<Uint8List> _audioStreamController =
      StreamController.broadcast();
  final List<Uint8List> _recordedChunks = [];

  bool _isRecording = false;
  bool get isRecording => _isRecording;

  Future<void> init() async {
    await _recorder.openRecorder();
    _audioStreamController.stream.listen((data) {
      _recordedChunks.add(data);
    });
  }

  Future<void> startRecording() async {
    if (_isRecording) return;
    _recordedChunks.clear();
    await _recorder.startRecorder(
      codec: Codec.pcm16,
      sampleRate: 44100,
      numChannels: 1,
      toStream: _audioStreamController.sink,
    );
    _isRecording = true;
  }

  Future<void> stopRecording() async {
    if (!_isRecording) return;
    await _recorder.stopRecorder();
    _isRecording = false;
  }

  Future<File> saveToFile({String? fileName}) async {
    final dir = await getApplicationDocumentsDirectory();
    final name =
        fileName ?? 'recorded_${DateTime.now().millisecondsSinceEpoch}.pcm';
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(
      _recordedChunks.expand((e) => e).toList(),
      flush: true,
    );
    return file;
  }

  Future<File> convertPcmToWav(File pcmFile) async {
    // .PCM -> .WAV
    return convertPcmToWav(pcmFile);
  }

  void dispose() {
    _recorder.closeRecorder();
    _audioStreamController.close();
  }
}
