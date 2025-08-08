import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';
import 'package:sync2sing/config/routes/route_names.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  bool get _isLoginButtonEnabled =>
      _idController.text.isNotEmpty && _pwController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _idController.addListener(_onTextChanged);
    _pwController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() { // 버튼 활성화 상태 갱신
    });
  }

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    // 로그인 API 처리 필요

    // 임시 처리: 로그인 성공 시 홈 화면으로 이동
    context.go(AppRoutePaths.mainHome);
  }

  void _onSignUpPressed() {
    context.push(AppRoutePaths.signupIdPassword);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 1. 로고
                SizedBox(
                  width: 85.w,
                  height: 85.h,
                  child: Center(
                    child: Image.asset(
                      'assets/images/sync2sing_logo_v1.png',
                      width: 85.w,
                      height: 85.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),


                SizedBox(height: 45.h),

                // 2. 아이디 입력 영역
                SizedBox(
                  width: 327.w,
                  height: 45.h,
                  child: TextField(
                    controller: _idController,
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.grayscale1,
                    ),
                    decoration: InputDecoration(
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                      hintText: '아이디를 입력해주세요',
                      hintStyle: AppTextStyles.body1.copyWith(
                        color: AppColors.grayscale4,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide:
                        BorderSide(color: AppColors.grayscale4, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide:
                        BorderSide(color: AppColors.grayscale4, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: AppColors.grayscale4, width: 1),
                      ),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),

                SizedBox(height: 16.h),

                // 3. 비밀번호 입력 영역
                SizedBox(
                  width: 327.w,
                  height: 45.h,
                  child: TextField(
                    controller: _pwController,
                    obscureText: true,
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.grayscale1,
                    ),
                    decoration: InputDecoration(
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                      hintText: '비밀번호를 입력해주세요',
                      hintStyle: AppTextStyles.body1.copyWith(
                        color: AppColors.grayscale4,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide:
                        BorderSide(color: AppColors.grayscale4, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide:
                        BorderSide(color: AppColors.grayscale4, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: AppColors.grayscale4, width: 1),
                      ),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),

                SizedBox(height: 24.h),

                // 4. 로그인 버튼
                SizedBox(
                  width: 327.w,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: _isLoginButtonEnabled ? _onLoginPressed : null,
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                        if (states.contains(WidgetState.disabled)) {
                          return AppColors.primaryPinkDisabled;
                        }
                        return AppColors.primaryPink;
                      }),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),

                  child: Text(
                      '로그인',
                      style: AppTextStyles.body1White,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // 5. 회원가입 텍스트
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '아직 계정이 없으신가요? ',
                      style: AppTextStyles.body3.copyWith(
                        color: AppColors.grayscale1,
                      ),
                    ),
                    GestureDetector(
                      onTap: _onSignUpPressed,
                      child: Text(
                        '회원가입',
                        style: AppTextStyles.body2Bold.copyWith(
                          color: AppColors.grayscale1,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
