import 'package:flutter/material.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';
import 'package:sync2sing/config/theme/app_colors.dart';

class EarphoneAlertDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onDismiss;
  final bool showAlert;

  const EarphoneAlertDialog({
    super.key,
    required this.showAlert,
    required this.onConfirm,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (!showAlert) return const SizedBox.shrink();

    return Stack(
      children: [
        GestureDetector(
          onTap: onDismiss,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.3),
          ),
        ),
        Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 270,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '이어폰 착용을 권장하고 있어요',
                    style: AppTextStyles.body1Bold.copyWith(
                      color: const Color(0xFF1A1A1C),
                      height: 1.7,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '더욱 정확한 분석 결과를 위해\n이어폰 마이크를 사용해주세요',
                    style: AppTextStyles.body4.copyWith(
                      color: const Color(0xFF1A1A1C),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: const Color(0xFFE5E5E8), // 연한 회색
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: TextButton(
                      onPressed: onConfirm,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF1A1A1C),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      child: Text(
                        '확인',
                        style: AppTextStyles.body1Bold.copyWith(
                          color: const Color(0xFF1A1A1C),
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
