import 'package:flutter/material.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';
import 'package:sync2sing/features/onboarding/presentation/widgets/earphone_alert_dialog.dart';

class AudioEnvironmentCheckPage extends StatefulWidget {
  const AudioEnvironmentCheckPage({super.key});

  @override
  State<AudioEnvironmentCheckPage> createState() =>
      _AudioEnvironmentCheckPageState();
}

class _AudioEnvironmentCheckPageState extends State<AudioEnvironmentCheckPage> {
  bool _canUseEarphones = false;
  bool _showAlertB = false;
  bool _shouldNavigateAfterAlert = false;

  void _onStartButtonPressed() {
    if (_canUseEarphones) {
      // 바로 이동
      // context.pushNamed(AppRouteNames.userBirthInfoInput);
    } else {
      // 알림창 띄우고, 확인 누르면 이동
      setState(() {
        _showAlertB = true;
        _shouldNavigateAfterAlert = true;
      });
    }
  }

  void _onAlertBConfirmed() {
    setState(() {
      _showAlertB = false;
    });
    if (_shouldNavigateAfterAlert) {
      _shouldNavigateAfterAlert = false;
      // context.pushNamed(AppRouteNames.userBirthInfoInput);
    }
  }

  void _onAlertDismissed() {
    setState(() {
      _showAlertB = false;
      _shouldNavigateAfterAlert = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: SafeArea(
            child: Center(
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  _buildMainTitle(),
                  const SizedBox(height: 12),
                  _buildSubtitle(),
                  const SizedBox(height: 24),
                  _buildEnvironmentNotice(),
                  const Spacer(flex: 1),
                  _buildCheckboxContainer(),
                  const Spacer(flex: 2),
                  _buildButton(),
                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ),
        EarphoneAlertDialog(
          showAlert: _showAlertB,
          onConfirm: _onAlertBConfirmed,
          onDismiss: _onAlertDismissed,
        ),
      ],
    );
  }

  Widget _buildMainTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        '노래로 연결되는 순간,\nSync2Sing',
        style: AppTextStyles.heading2Bold,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        '맞춤형 커리큘럼 설계를 위한\n보컬 분석을 시작합니다\n아래 내용에 해당하는지 확인해주세요',
        style: AppTextStyles.body1,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildEnvironmentNotice() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        '※ 소리를 낼 수 있는 환경이어야 합니다.',
        style: AppTextStyles.body4.copyWith(color: AppColors.primaryRed),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCheckboxContainer() {
    return Container(
      width: 327,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.neutralGhost,
        borderRadius: BorderRadius.circular(10),
      ),
      child: _buildCheckbox('이어폰을 사용할 수 있나요?', _canUseEarphones, (value) {
        setState(() {
          _canUseEarphones = value!;
        });
      }),
    );
  }

  Widget _buildCheckbox(
    String text,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            shape: const CircleBorder(),
            activeColor: AppColors.primaryRed,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: AppTextStyles.body1)),
      ],
    );
  }

  Widget _buildButton() {
    return SizedBox(
      width: 327,
      height: 50,
      child: ElevatedButton(
        onPressed: _onStartButtonPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: Text('보컬 분석 시작하기', style: AppTextStyles.body1BoldWhite),
      ),
    );
  }
}
