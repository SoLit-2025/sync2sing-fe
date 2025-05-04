import 'package:flutter/material.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';

class AudioEnvironmentCheckPage extends StatefulWidget {
  const AudioEnvironmentCheckPage({super.key});

  @override
  State<AudioEnvironmentCheckPage> createState() =>
      _AudioEnvironmentCheckPageState();
}

class _AudioEnvironmentCheckPageState extends State<AudioEnvironmentCheckPage> {
  bool _canMakeSound = false;
  bool _canUseEarphones = false;
  bool _showAlertA = false; // 소리를 낼 수 없는 환경 알림
  bool _showAlertB = false; // 이어폰 권장 알림

  bool get _isButtonEnabled => _canMakeSound;

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
        if (_showAlertA || _showAlertB) _buildAlertBackground(),
        if (_showAlertA) _buildAlertA(),
        if (_showAlertB) _buildAlertB(),
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

  Widget _buildCheckboxContainer() {
    return Container(
      width: 327,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.neutralGhost,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _buildCheckbox('소리를 낼 수 있는 환경인가요?', _canMakeSound, (value) {
            setState(() {
              _canMakeSound = value!;
            });
          }),
          const SizedBox(height: 20),
          _buildCheckbox('이어폰을 사용할 수 있나요?', _canUseEarphones, (value) {
            setState(() {
              _canUseEarphones = value!;
              // 오류 수정: 여기서 알림창을 띄우지 않음
            });
          }),
        ],
      ),
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
        onPressed:
            _isButtonEnabled
                ? () {
                  // 소리를 낼 수 있지만 이어폰을 사용할 수 없는 경우 알림 표시
                  if (_canMakeSound && !_canUseEarphones) {
                    setState(() {
                      _showAlertB = true;
                    });
                    return;
                  }
                  // 소리를 낼 수 없는 경우 알림 표시
                  if (!_canMakeSound) {
                    setState(() {
                      _showAlertA = true;
                    });
                    return;
                  }
                  // 다음 페이지로 이동
                  // context.pushNamed(AppRouteNames.userBirthInfoInput);
                }
                : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _isButtonEnabled ? AppColors.primaryRed : AppColors.primaryPink,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: Text(
          '보컬 분석 시작하기',
          style:
              _isButtonEnabled
                  ? AppTextStyles.body1BoldWhite
                  : AppTextStyles.body1White.copyWith(
                    color: AppColors.neutralWhite.withOpacity(0.5),
                  ),
        ),
      ),
    );
  }

  Widget _buildAlertBackground() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showAlertA = false;
          _showAlertB = false;
        });
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black.withOpacity(0.3),
      ),
    );
  }

  Widget _buildAlertA() {
    return Center(
      child: Container(
        width: 270,
        height: 142,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '보컬 분석을 진행할 수 없어요',
              style: AppTextStyles.body1Bold,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '소리를 낼 수 있는 곳으로 이동한 뒤\n다시 접속해주세요',
              style: AppTextStyles.body4,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                setState(() {
                  _showAlertA = false;
                });
              },
              child: Text('확인', style: AppTextStyles.body1Bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertB() {
    return Center(
      child: Container(
        width: 270,
        height: 142,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '이어폰 착용을 권장하고 있어요',
              style: AppTextStyles.body1Bold,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '더욱 정확한 분석 결과를 위해\n이어폰 마이크를 사용해주세요',
              style: AppTextStyles.body4,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                setState(() {
                  _showAlertB = false;
                });
                // 체크박스 A가 선택되었다면 다음 페이지로 이동
                if (_canMakeSound) {
                  // context.pushNamed(AppRouteNames.userBirthInfoInput);
                }
              },
              child: Text('확인', style: AppTextStyles.body1Bold),
            ),
          ],
        ),
      ),
    );
  }
}
