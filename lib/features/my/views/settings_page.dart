import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isNotificationEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkNotificationPermission();
  }

  Future<void> _checkNotificationPermission() async {
    // todo: 알림 권한 확인 로직 추가
  }

  void _showLeaveDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          child: SizedBox(
            width: 270.w,
            height: 142.h,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '모든 성장 기록이 함께 삭제돼요',
                        style: AppTextStyles.body1Bold.copyWith(color: AppColors.grayscale1),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '탈퇴시 보컬 분석 리포트 기록을 영구적으로 삭제됩니다\n불편한 점이 있으시다면 언제든 의견을 들려주세요',
                        style: AppTextStyles.body6.copyWith(
                          color: AppColors.grayscale2,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, thickness: 1, color: AppColors.grayscale5),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            // todo: 1:1 문의 연결
                          },
                          child: Center(
                            child: Text(
                              '1:1 문의하기',
                              style: AppTextStyles.body1Bold.copyWith(color: AppColors.primaryPink),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      Container(width: 1, height: double.infinity, color: AppColors.grayscale5),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            context.go(AppRoutePaths.login);
                          },
                          child: Center(
                            child: Text(
                              '탈퇴하기',
                              style: AppTextStyles.body1Bold.copyWith(color: AppColors.grayscale1),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _divider() =>
      Divider(height: 1, thickness: 1, color: AppColors.grayscale6, indent: 24.w, endIndent: 24.w);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grayscale8,
      appBar: AppBar(
        backgroundColor: AppColors.grayscale8,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Image.asset(
            'assets/images/left_arrow_icon.png',
            width: 14.w,
            height: 24.h,
            errorBuilder:
                (context, error, stackTrace) => Icon(Icons.arrow_back, color: AppColors.grayscale2),
          ),
        ),
        title: Text('설정', style: AppTextStyles.heading4Bold.copyWith(color: AppColors.grayscale1)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 28.h),
            _buildSettingItem(
              icon: 'assets/images/alarm_icon.png',
              iconWidth: 30.w,
              iconHeight: 28.h,
              title: '알림 설정',
              titleTextStyle: AppTextStyles.heading4.copyWith(color: AppColors.grayscale1),
              trailing: CupertinoSwitch(
                value: _isNotificationEnabled,
                onChanged: (value) {
                  setState(() => _isNotificationEnabled = value);
                },
                activeColor: AppColors.primaryPink,
                trackColor: AppColors.grayscale4,
              ),
            ),
            _divider(),
            _buildSettingItem(
              icon: 'assets/images/logout_icon.png',
              iconWidth: 30.w,
              iconHeight: 30.h,
              title: '로그아웃',
              titleTextStyle: AppTextStyles.heading4.copyWith(color: AppColors.grayscale1),
              onTap: () => context.go(AppRoutePaths.login),
            ),
            _divider(),
            _buildSettingItem(
              icon: 'assets/images/leave_icon.png',
              iconWidth: 28.w,
              iconHeight: 30.h,
              title: '회원탈퇴',
              titleTextStyle: AppTextStyles.heading4.copyWith(color: AppColors.grayscale1),
              onTap: _showLeaveDialog,
            ),
            _divider(),
            _buildSettingItem(
              icon: 'assets/images/cherry.png',
              iconWidth: 30.w,
              iconHeight: 30.h,
              title: '1:1 문의',
              titleTextStyle: AppTextStyles.heading4.copyWith(color: AppColors.grayscale1),
              onTap: () {
                // todo: 1:1 문의 연결
              },
            ),
            SizedBox(height: 240.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'flutter_sound',
                    style: AppTextStyles.heading4Bold.copyWith(color: AppColors.grayscale1),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'License: Mozilla Public License, Version 2.0 (MPL 2.0)',
                    style: AppTextStyles.body3.copyWith(color: AppColors.grayscale2),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Copyright © 2025 Canardoux',
                    style: AppTextStyles.body3.copyWith(color: AppColors.grayscale2),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    '원본 소스: https://github.com/canardoux/flutter_sound\n\n'
                    '본 앱에서는 이 소스를 수정하지 않고 사용했습니다.\n\n'
                    'MPL 2.0 전문: https://mozilla.org/MPL/2.0/',
                    style: AppTextStyles.body4.copyWith(color: AppColors.grayscale2, height: 1.5),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required String icon,
    required double iconWidth,
    required double iconHeight,
    required String title,
    required TextStyle titleTextStyle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Container(
        width: 327.w,
        height: 60.h,
        padding: EdgeInsets.only(left: 30.w, right: 30.w),
        child: Row(
          children: [
            Image.asset(
              icon,
              width: iconWidth,
              height: iconHeight,
              fit: BoxFit.contain,
              errorBuilder:
                  (context, error, stackTrace) =>
                      Icon(Icons.error, color: Colors.red, size: iconHeight),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: titleTextStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}
