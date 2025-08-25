import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/features/shared/views/page_indicator.dart';
import 'package:sync2sing/features/shared/logics/dio_factory.dart';
import 'package:sync2sing/features/auth/logics/auth_api.dart';

import '../logics/nickname_provider.dart';

class SignupIdPasswordPage extends ConsumerStatefulWidget {
  const SignupIdPasswordPage({super.key});
  @override
  ConsumerState<SignupIdPasswordPage> createState() => _SignupIdPasswordPageState();
}

class _SignupIdPasswordPageState extends ConsumerState<SignupIdPasswordPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final FocusNode _idFocusNode = FocusNode();
  final FocusNode _pwFocusNode = FocusNode();

  String id = '';
  String pw = '';
  bool idValid = false;
  bool pwValid = false;
  String? idMessage, pwMessage;
  String? idErrorType, pwErrorType;

  final dioFactory = DioFactory(FlutterSecureStorage());
  late final AuthApi _authApi;

  @override
  void initState() {
    super.initState();
    _authApi = AuthApi(dioFactory.createDio());
  }

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    _idFocusNode.dispose();
    _pwFocusNode.dispose();
    super.dispose();
  }

  void validateId(String value) {
    setState(() {
      id = value;
      idValid = false;
      idMessage = null;
      idErrorType = null;
      if (id.isEmpty) return;

      if (id.contains(' ')) {
        idMessage = "아이디에 공백은 포함할 수 없습니다";
        idErrorType = 'space_error';
        return;
      }
      final regExp = RegExp(r'^[a-z0-9]+$');
      if (id.length < 6) {
        idMessage = "아이디는 영문 6글자 이상이어야 합니다";
        idErrorType = 'length_short';
      } else if (id.length >= 15) {
        idMessage = "아이디는 영문 15글자 미만이어야 합니다";
        idErrorType = 'length_long';
      } else if (!regExp.hasMatch(id)) {
        idMessage = "아이디에는 영문 소문자와 숫자만 사용가능합니다";
        idErrorType = 'invalid_char';
      } else {
        idValid = true;
        idMessage = "사용가능한 아이디입니다";
        idErrorType = 'success';
      }
    });
  }

  void validatePw(String value) {
    setState(() {
      pw = value;
      pwValid = false;
      pwMessage = null;
      pwErrorType = null;
      if (pw.isEmpty) return;

      if (RegExp(r'\s').hasMatch(pw)) {
        pwMessage = "비밀번호에 공백은 포함할 수 없습니다";
        pwErrorType = 'space_error';
        return;
      }

      final hasAlphabet = RegExp(r'[a-zA-Z]').hasMatch(pw);
      final hasDigit = RegExp(r'\d').hasMatch(pw);
      final hasSpecial = RegExp(r'[^a-zA-Z0-9]').hasMatch(pw);

      int count = 0;
      if (hasAlphabet) count++;
      if (hasDigit) count++;
      if (hasSpecial) count++;

      if (pw.length < 8) {
        pwMessage = "비밀번호는 영문 8글자 이상이어야 합니다";
        pwErrorType = 'length_short';
      } else if (count < 2) {
        pwMessage = "영문자, 숫자, 특수문자 중 2가지 이상을 조합해주세요";
        pwErrorType = 'type_mismatch';
      } else {
        pwValid = true;
        pwMessage = null;
        pwErrorType = 'success';
      }
    });
  }

  Widget? getIdIcon() {
    if (id.isEmpty) return null;
    if (idErrorType == 'success') {
      return Padding(
        padding: EdgeInsets.only(right: 10.w),
        child: Icon(
          Icons.check_circle,
          size: 18.w,
          color: AppColors.systemSuccess,
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.only(right: 10.w),
        child: Icon(
          Icons.cancel,
          size: 18.w,
          color: AppColors.systemDanger,
        ),
      );
    }
  }

  Widget? getPwIcon() {
    if (pw.isEmpty) return null;
    if (pwErrorType != null && pwErrorType != 'success') {
      return Padding(
        padding: EdgeInsets.only(right: 10.w),
        child: Icon(
          Icons.cancel,
          size: 18.w,
          color: AppColors.systemDanger,
        ),
      );
    }
    return null;
  }

  Future<void> _doSignUp() async {
    final nickname = ref.watch(nicknameProvider) ?? '';
    try {
      final response = await _authApi.signUp(
        username: id,
        password: pw,
        nickname: nickname,
      );

      if (response['status'] == 201) {
        context.go(AppRoutePaths.signupComplete);
      } else {
        final message = response['message'] ?? '회원가입에 실패했습니다.';
        _showError(message);
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ① 상단 페이지네이션
              Center(
                child: PageIndicator(
                  currentPage: 0,
                  pageCount: 2,
                ),
              ),
              // ② 본문 입력영역 (중간, Expanded로 감싸기)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 27.h),
                    Text(
                      '환영합니다!',
                      style: AppTextStyles.heading2Bold,
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Sync2Sing 회원가입을 시작합니다',
                      style: AppTextStyles.body1,
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 44.h),
                    // 아이디 입력 영역
                    Center(
                      child: SizedBox(
                        width: 327.w,
                        height: 45.h,
                        child: TextField(
                          controller: _idController,
                          focusNode: _idFocusNode,
                          onChanged: validateId,
                          style: AppTextStyles.body1,
                          decoration: InputDecoration(
                            hintText: "사용할 아이디를 입력해주세요",
                            hintStyle: AppTextStyles.body1.copyWith(color: AppColors.grayscale4),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide(
                                color: idErrorType == null || idErrorType == 'success'
                                    ? AppColors.grayscale4
                                    : AppColors.systemDanger,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide(
                                color: idErrorType == null || idErrorType == 'success'
                                    ? AppColors.grayscale4
                                    : AppColors.systemDanger,
                              ),
                            ),
                            suffixIcon: getIdIcon(),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Center(
                      child: SizedBox(
                        width: 326.w,
                        child: id.isEmpty
                            ? const SizedBox.shrink()
                            : Text(
                          idMessage ?? "",
                          style: AppTextStyles.body6.copyWith(
                            color: idErrorType == 'success'
                                ? AppColors.systemSuccessText
                                : AppColors.systemDangerText,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    // 비밀번호 입력 영역
                    Center(
                      child: SizedBox(
                        width: 327.w,
                        height: 45.h,
                        child: TextField(
                          controller: _pwController,
                          focusNode: _pwFocusNode,
                          onChanged: validatePw,
                          obscureText: true,
                          style: AppTextStyles.body1,
                          decoration: InputDecoration(
                            hintText: "사용할 비밀번호를 입력해주세요",
                            hintStyle: AppTextStyles.body1.copyWith(color: AppColors.grayscale4),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide(
                                color: pwErrorType == null || pwErrorType == 'success'
                                    ? AppColors.grayscale4
                                    : AppColors.systemDanger,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide(
                                color: pwErrorType == null || pwErrorType == 'success'
                                    ? AppColors.grayscale4
                                    : AppColors.systemDanger,
                                width: 1,
                              ),
                            ),
                            suffixIcon: getPwIcon(),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Center(
                      child: SizedBox(
                        width: 326.w,
                        height: 15.h,
                        child: pw.isEmpty || pwErrorType == 'success'
                            ? const SizedBox.shrink()
                            : Text(
                          pwMessage ?? "",
                          style: AppTextStyles.body6.copyWith(
                            color: AppColors.systemDangerText,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // ③ 하단 버튼 (하단 고정)
              Center(
                child: SizedBox(
                  width: 327.w,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: idValid && pwValid ? _doSignUp : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: idValid && pwValid
                          ? AppColors.primaryPink
                          : AppColors.primaryPinkDisabled,
                      disabledForegroundColor: AppColors.grayscale8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      '확인',
                      textAlign: TextAlign.center,
                      style: idValid && pwValid
                          ? AppTextStyles.body1White
                          : AppTextStyles.body1.copyWith(color: AppColors.grayscale4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
