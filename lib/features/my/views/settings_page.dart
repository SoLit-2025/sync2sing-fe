import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';
import 'package:sync2sing/features/shared/logics/dio_factory.dart';
import 'package:sync2sing/features/shared/logics/secure_storage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isNotificationEnabled = false;

  Future<void> logout() async {
    final secureStorage = SecureStorage();
    try {
      await DioFactory(secureStorage).post(
        '/user/logout',
        data: jsonEncode({'refresh_token': await secureStorage.readRefreshToken()}),
      );
    } on DioException catch (e) {
      debugPrint("logout error: ${e.response?.data}");
    } finally {
      secureStorage.deleteTokens();
      if (mounted) {
        context.go(AppRoutePaths.login);
      }
    }
  }

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
          backgroundColor: AppColors.grayscale8,
          child: SizedBox(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '모든 성장 기록이 함께 삭제돼요',
                        style: AppTextStyles.body1Bold,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '탈퇴시 보컬 분석 리포트 기록을 영구적으로 삭제합니다\n불편한 점이 있으시다면 언제든 의견을 들려주세요',
                        style: AppTextStyles.body6.copyWith(color: AppColors.grayscale1),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Divider(height: 0.7, thickness: 0.7, color: AppColors.grayscale4),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          style: ButtonStyle(
                            // 클릭 시 그림자가 원형 x, 부모 전체를 차지하게
                            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                              const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                            ),
                            overlayColor: WidgetStateProperty.resolveWith<Color?>((
                              Set<WidgetState> states,
                            ) {
                              if (states.contains(WidgetState.pressed)) {
                                return AppColors.grayscale1.withValues(alpha: 0.2); // 눌렸을 때 배경색
                              }
                              return null; // 기본값
                            }),
                          ),
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
                      Container(width: 0.7, height: double.infinity, color: AppColors.grayscale4),
                      Expanded(
                        child: TextButton(
                          style: ButtonStyle(
                            // 클릭 시 그림자가 원형 x, 부모 전체를 차지하게
                            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                              const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                            ),
                            overlayColor: WidgetStateProperty.resolveWith<Color?>((
                              Set<WidgetState> states,
                            ) {
                              if (states.contains(WidgetState.pressed)) {
                                return AppColors.grayscale1.withValues(alpha: 0.2); // 눌렸을 때 배경색
                              }
                              return null; // 기본값
                            }),
                          ),
                          onPressed: () {
                            // todo: 회원탈퇴 api 연결
                            context.go(AppRoutePaths.onboardingQuestion);
                          },
                          child: Center(
                            child: Text(
                              '탈퇴하기',
                              style: AppTextStyles.body1,
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
              iconAsset: 'assets/images/alarm_icon.png',
              iconWidth: 30.w,
              iconHeight: 28.h,
              title: '알림 설정',
              titleTextStyle: AppTextStyles.heading4.copyWith(color: AppColors.grayscale1),
              trailing: CupertinoSwitch(
                value: _isNotificationEnabled,
                onChanged: (value) {
                  setState(() => _isNotificationEnabled = value);
                },
                activeTrackColor: AppColors.primaryPink,
                inactiveTrackColor: AppColors.grayscale4,
              ),
            ),
            _divider(),
            _buildSettingItem(
              iconAsset: 'assets/images/logout_icon.png',
              iconWidth: 30.w,
              iconHeight: 30.h,
              title: '로그아웃',
              titleTextStyle: AppTextStyles.heading4.copyWith(color: AppColors.grayscale1),
              onTap: () async {
                await logout();
              },
            ),
            _divider(),
            _buildSettingItem(
              iconAsset: 'assets/images/leave_icon.png',
              iconWidth: 28.w,
              iconHeight: 30.h,
              title: '회원탈퇴',
              titleTextStyle: AppTextStyles.heading4,
              onTap: _showLeaveDialog,
            ),
            _divider(),
            _buildSettingItem(
              iconAsset: 'assets/images/cherry.png',
              iconWidth: 30.w,
              iconHeight: 30.h,
              title: '1:1 문의',
              titleTextStyle: AppTextStyles.heading4,
              onTap: () {
                // todo: 1:1 문의 연결
              },
            ),
            _divider(),
            _buildSettingItem(
              iconData: Icons.copyright,
              iconWidth: 30.w,
              iconHeight: 30.w,
              title: '라이센스 정보',
              titleTextStyle: AppTextStyles.heading4,
              onTap: () {
                context.push(AppRoutePaths.license);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    String? iconAsset,
    IconData? iconData,
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
            if (iconAsset != null)
              Image.asset(
                iconAsset,
                width: iconWidth,
                height: iconHeight,
                fit: BoxFit.contain,
                errorBuilder:
                    (context, error, stackTrace) =>
                        Icon(Icons.error, color: Colors.red, size: iconHeight),
              )
            else if (iconData != null)
              Icon(iconData, size: iconWidth, color: AppColors.grayscale3),
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
