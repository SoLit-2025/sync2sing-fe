import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

Future<File> convertPcmToWav(File pcmFile) async {
  final pcmBytes = await pcmFile.readAsBytes();

  final sampleRate = 44100;
  final channels = 1;
  final bitsPerSample = 16;

  int byteRate = sampleRate * channels * bitsPerSample ~/ 8;
  int blockAlign = channels * bitsPerSample ~/ 8;
  int dataSize = pcmBytes.length;

  final header = BytesBuilder();

  header.add(ascii.encode('RIFF'));
  header.add(_intToBytes(36 + dataSize, 4)); // ChunkSize
  header.add(ascii.encode('WAVE'));
  header.add(ascii.encode('fmt '));
  header.add(_intToBytes(16, 4)); // Subchunk1Size
  header.add(_intToBytes(1, 2)); // AudioFormat PCM = 1
  header.add(_intToBytes(channels, 2)); // NumChannels
  header.add(_intToBytes(sampleRate, 4)); // SampleRate
  header.add(_intToBytes(byteRate, 4)); // ByteRate
  header.add(_intToBytes(blockAlign, 2)); // BlockAlign
  header.add(_intToBytes(bitsPerSample, 2)); // BitsPerSample
  header.add(ascii.encode('data'));
  header.add(_intToBytes(dataSize, 4)); // Subchunk2Size
  header.add(pcmBytes);

  final wavBytes = header.toBytes();

  final wavFilePath = pcmFile.path.replaceAll('.pcm', '.wav');
  final wavFile = File(wavFilePath);
  await wavFile.writeAsBytes(wavBytes, flush: true);

  return wavFile;
}

// 정수 -> 리틀엔디언 바이트 변환 헬퍼
List<int> _intToBytes(int value, int byteCount) {
  final bytes = <int>[];
  for (var i = 0; i < byteCount; i++) {
    bytes.add(value & 0xFF);
    value >>= 8;
  }
  return bytes;
}
