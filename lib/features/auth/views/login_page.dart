import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sync2sing/features/shared/logics/dio_factory.dart';
import 'package:sync2sing/features/auth/logics/auth_api.dart';

class Loginpage extends ConsumerStatefulWidget {
  const Loginpage({super.key});

  @override
  ConsumerState<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends ConsumerState<Loginpage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  final dioFactory = DioFactory(FlutterSecureStorage());
  late final AuthApi _authApi;
  final _storage = FlutterSecureStorage();

  Future<void> printAccessToken() async {
    String? accessToken = await _storage.read(key: 'ACCESS_TOKEN');
    print('Stored ACCESS_TOKEN: $accessToken');
  }

  Future<void> printRefreshToken() async {
    String? refreshToken = await _storage.read(key: 'REFRESH_TOKEN');
    print('Stored REFRESH_TOKEN: $refreshToken');
  }


  bool get _isLoginButtonEnabled =>
      _idController.text.isNotEmpty && _pwController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _authApi = AuthApi(dioFactory.createDio());
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

  Future<void> _doLogin() async {
    final username = _idController.text.trim();
    final password = _pwController.text.trim();

    print("username: $username, password: $password");

    try {
      final response = await _authApi.login(
        username: _idController.text.trim(),
        password: _pwController.text.trim(),
      );

      if (response['status'] == 200) {
        final accessToken = response['data']['access_token'] as String;
        final refreshToken = response['data']['refresh_token'] as String;

        // 토큰을 안전 저장소에 저장
        await _storage.write(key: 'ACCESS_TOKEN', value: accessToken);
        await _storage.write(key: 'REFRESH_TOKEN', value: refreshToken);

        await printAccessToken();
        await printRefreshToken();

        // 로그인 성공 후 메인 홈 화면으로 이동
        context.go(AppRoutePaths.mainHome);
      } else {
        _showError(response['message'] ?? '로그인에 실패했습니다.');
      }
    } catch (e) {
      print(e);
      _showError('로그인 중 오류가 발생했습니다.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
                    onPressed: _isLoginButtonEnabled ? _doLogin : null,
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
