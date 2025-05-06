import 'package:flutter/material.dart';

class AppColors {
  // 주요 색상(Primary Colors)
  static const Color primaryGreen = Color(0xFF037F56);        // 녹색
  static const Color primaryRed = Color(0xFFEF4452);          // 빨간색
  static const Color primaryPink = Color(0xFFF56570);         // 분홍색
  static const Color primaryPinkDisabled = Color(0xFFF8D6DA); // 비활성화된 분홍색

  // 중립 색상(Grayscale Colors)
  static const Color grayscale1 = Color(0xFF1A1A1C);  // 거의 검정색
  static const Color grayscale2 = Color(0xFF4D4D4D);  // 어두운 회색
  static const Color grayscale3 = Color(0xFF707070);  // 중간 회색
  static const Color grayscale4 = Color(0xFFC0C0C0);  // 중간-밝은 회색
  static const Color grayscale5 = Color(0xFFD9D9D9);  // 밝은 회색
  static const Color grayscale6 = Color(0xFFECECEC);  // 더 밝은 회색
  static const Color grayscale7 = Color(0xFFF5F5F5);  // 거의 흰색 (배경용)
  static const Color grayscale8 = Color(0xFFFFFFFF);  // 흰색

  // 시스템 색상(System Colors) - 위험(Danger), 빨간색
  static const Color systemDangerText = Color(0xFFD50136);  // 위험 텍스트 색상
  static const Color systemDanger = Color(0xFFEB003B);      // 위험 배경/아이콘 색상

  // 시스템 색상(System Colors) - 경고(Warning), 노란색
  static const Color systemWarningText = Color(0xFF98690A); // 경고 텍스트 색상
  static const Color systemWarning = Color(0xFFFFB724);     // 경고 배경/아이콘 색상

  // 시스템 색상(System Colors) - 성공(Success), 녹색
  static const Color systemSuccessText = Color(0xFF006E18); // 성공 텍스트 색상
  static const Color systemSuccess = Color(0xFF008A1E);     // 성공 배경/아이콘 색상

  // 시스템 색상(System Colors) - 정보(Information), 파란색
  static const Color systemInfoText = Color(0xFF1F53CC);    // 정보 텍스트 색상
  static const Color systemInfo = Color(0xFF2768FF);        // 정보 배경/아이콘 색상
}