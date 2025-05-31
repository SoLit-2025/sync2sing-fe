// import 'dart:io';
// import 'package:ffmpeg_kit_flutter_audio/ffmpeg_kit.dart';
//
// /// m4a 파일을 wav 파일로 변환
// class M4aToWavConverter {
//   Future<String> convert(String inputPath) async {
//     // 확장자만 .wav로 변경
//     final outputPath = inputPath.replaceAll(RegExp(r'\.m4a$', caseSensitive: false), '.wav');
//     // FFmpeg를 사용해 변환 실행
//     await FFmpegKit.execute('-i "$inputPath" "$outputPath"');
//     // 변환된 파일이 실제로 생성되었는지 확인
//     if (!File(outputPath).existsSync()) {
//       throw Exception('파일 변환 실패: $outputPath');
//     }
//     return outputPath;
//   }
// }
