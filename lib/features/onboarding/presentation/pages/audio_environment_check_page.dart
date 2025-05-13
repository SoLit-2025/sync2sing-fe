import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  bool _showEarphoneCheckAlert = false;
  bool _shouldNavigateAfterEarphoneCheckAlert = false;

  void _onStartButtonPressed() {
    if (_canUseEarphones) {
      // 바로 이동
      // context.pushNamed(AppRouteNames.userBirthInfoInput);
    } else {
      // 알림창 띄우고, 확인 누르면 이동
      setState(() {
        _showEarphoneCheckAlert = true;
        _shouldNavigateAfterEarphoneCheckAlert = true;
      });
    }
  }

  void _onEarphoneCheckAlertConfirmed() {
    setState(() {
      _showEarphoneCheckAlert = false;
    });
    if (_shouldNavigateAfterEarphoneCheckAlert) {
      _shouldNavigateAfterEarphoneCheckAlert = false;
      // context.pushNamed(AppRouteNames.userBirthInfoInput);
    }
  }

  void _onEarphoneCheckAlertDismissed() {
    setState(() {
      _showEarphoneCheckAlert = false;
      _shouldNavigateAfterEarphoneCheckAlert = false;
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
                  SizedBox(height: 12.h),
                  _buildSubtitle(),
                  SizedBox(height: 24.h),
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
          showAlert: _showEarphoneCheckAlert,
          onConfirm: _onEarphoneCheckAlertConfirmed,
          onDismiss: _onEarphoneCheckAlertDismissed,
        ),
      ],
    );
  }

  Widget _buildMainTitle() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Text(
        '노래로 연결되는 순간,\nSync2Sing',
        style: AppTextStyles.heading2Bold.copyWith(
          fontSize: AppTextStyles.heading2Bold.fontSize?.sp,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Text(
        '맞춤형 커리큘럼 설계를 위한\n보컬 분석을 시작합니다\n아래 내용에 해당하는지 확인해주세요',
        style: AppTextStyles.body1.copyWith(
          fontSize: AppTextStyles.body1.fontSize?.sp,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildEnvironmentNotice() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Text(
        '※ 소리를 낼 수 있는 환경이어야 합니다.',
        style: AppTextStyles.body4.copyWith(
          color: AppColors.primaryRed,
          fontSize: AppTextStyles.body4.fontSize?.sp,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCheckboxContainer() {
    return Container(
      width: 327.w,
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: AppColors.neutralGhost,
        borderRadius: BorderRadius.circular(10.r),
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
          width: 24.w,
          height: 24.h,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            shape: CircleBorder(
              side: BorderSide(width: 0, style: BorderStyle.none),
            ),
            activeColor: AppColors.primaryRed,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body1.copyWith(
              fontSize: AppTextStyles.body1.fontSize?.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton() {
    return SizedBox(
      width: 327.w,
      height: 50.h,
      child: ElevatedButton(
        onPressed: _onStartButtonPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          elevation: 0,
        ),
        child: Text(
          '보컬 분석 시작하기',
          style: AppTextStyles.body1BoldWhite.copyWith(
            fontSize: AppTextStyles.body1BoldWhite.fontSize?.sp,
          ),
        ),
      ),
    );
  }
}
