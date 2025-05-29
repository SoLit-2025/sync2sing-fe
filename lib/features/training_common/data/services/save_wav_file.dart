import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class SaveWavFile {
  // 파일 생성 및 헤더 초기화
  static Future<RandomAccessFile> createFile({
    required String path,
    required Uint8List header,
  }) async {
    final file = File(path);
    if (file.existsSync()) await file.delete();
    final raf = await file.open(mode: FileMode.write);
    await raf.writeFrom(header);
    return raf;
  }

  static Uint8List buildHeader({
    required int sampleRate,
    required int channels,
    required int bitsPerSample,
    required int pcmDataSize,
  }) {
    final byteData = ByteData(44);
    // RIFF 헤더
    byteData.setUint32(0, 0x46464952, Endian.little); // "RIFF"
    byteData.setUint32(4, pcmDataSize + 36, Endian.little);
    byteData.setUint32(8, 0x45564157, Endian.little); // "WAVE"
    // fmt 청크
    byteData.setUint32(12, 0x20746D66, Endian.little); // "fmt "
    byteData.setUint32(16, 16, Endian.little); // Subchunk1Size
    byteData.setUint16(20, 1, Endian.little); // PCM
    byteData.setUint16(22, channels, Endian.little);
    byteData.setUint32(24, sampleRate, Endian.little);
    byteData.setUint32(
      28,
      (sampleRate * channels * bitsPerSample) ~/ 8,
      Endian.little,
    );
    byteData.setUint16(32, (channels * bitsPerSample) ~/ 8, Endian.little);
    byteData.setUint16(34, bitsPerSample, Endian.little);
    // data 청크
    byteData.setUint32(36, 0x61746164, Endian.little); // "data"
    byteData.setUint32(40, pcmDataSize, Endian.little);

    return byteData.buffer.asUint8List();
  }
}
