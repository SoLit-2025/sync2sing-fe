import 'dart:io';
import 'dart:typed_data';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:sync2sing/features/training_common/data/services/pitch_to_note_converter.dart';

// 음성 파일에서 주파수(Hz) 리스트 추출
class VoicePitchFinder {
  final PitchToNoteConverter _noteConverter = PitchToNoteConverter();

  // 평균 노트명 반환
  Future<String> findAverageNote(String wavFilePath) async {
    final pitches = await _extractPitches(wavFilePath);
    if (pitches.isEmpty) throw Exception('음정 데이터가 없습니다.');
    // 평균 주파수(Hz) 계산
    final avgHz = pitches.reduce((a, b) => a + b) / pitches.length;
    // 평균 주파수를 노트명으로 변환
    final averageNote = _noteConverter.hzToNote(avgHz);
    return averageNote;
  }

  // 최고 노트명 반환
  Future<String> findMaxNote(String wavFilePath) async {
    final pitches = await _extractPitches(wavFilePath);
    if (pitches.isEmpty) throw Exception('음정 데이터가 없습니다.');
    // 최고 주파수(Hz) 계산
    final maxHz = pitches.reduce((a, b) => a > b ? a : b);
    // 최고 주파수를 노트명으로 변환
    final maxNote = _noteConverter.hzToNote(maxHz);
    return maxNote;
  }

  // 최저 노트명 반환
  Future<String> findMinNote(String wavFilePath) async {
    final pitches = await _extractPitches(wavFilePath);
    if (pitches.isEmpty) throw Exception('음정 데이터가 없습니다.');
    // 최저 주파수(Hz) 계산
    final minHz = pitches.reduce((a, b) => a < b ? a : b);
    // 최저 주파수를 노트명으로 변환
    final minNote = _noteConverter.hzToNote(minHz);
    return minNote;
  }

  // wav 파일의 일정 구간마다 음정 분석
  Future<List<double>> _extractPitches(String wavFilePath) async {
    final file = File(wavFilePath);
    if (!file.existsSync()) throw Exception('파일 없음: $wavFilePath');

    // STEP1. 모든 데이터 불러오기
    final bytes = await file.readAsBytes();

    // STEP2. wav 파일 헤더(=44byte) 이후의 PCM 데이터 추출
    const headerSize = 44;
    if (bytes.length <= headerSize) throw Exception('PCM 데이터 없음');
    final pcmBytes = bytes.sublist(headerSize);

    // STEP3. PCM 데이터를 16비트 정수 리스트로 변환
    final pcmBuffer = Int16List.view(Uint8List.fromList(pcmBytes).buffer);

    // STEP4. 변환된 정수 리스트 데이터를 -1.0 ~ 1.0 범위의 실수로 변환
    final floatBuffer = pcmBuffer.map((e) => e / 32768.0).toList();

    // STEP5. PitchDetector 객체 생성
    final pitchDetector = PitchDetector();

    // STEP6. 일정 구간(2048 샘플씩, 50% 겹치게)마다 음정 분석이 진행되도록 구간 설정
    final bufferSize = 2048;
    final hopSize = 1024;
    List<double> pitches = [];
    for (int i = 0; i + bufferSize <= floatBuffer.length; i += hopSize) {
      // STEP7. 분석할 구간 분리
      final window = floatBuffer.sublist(i, i + bufferSize);

      // STEP8. 해당 구간의 음정 분석
      final result = await pitchDetector.getPitchFromFloatBuffer(window);

      // STEP9. 사람이 낼 수 있는 범위(50~2000Hz) 내의 유효한 음정만 저장
      if (result.pitched && result.pitch > 50 && result.pitch < 2000) {
        pitches.add(result.pitch);
      }
    }
    // STEP10. 분석된 모든 음정 리스트 반환
    return pitches;
  }
}