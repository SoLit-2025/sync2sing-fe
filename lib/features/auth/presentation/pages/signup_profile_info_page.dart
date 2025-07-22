import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/shared/widgets/page_indicator.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync2sing/shared/providers/birth_info_provider.dart';


class SignupProfileInfoPage extends ConsumerStatefulWidget {
  const SignupProfileInfoPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SignupProfileInfoPage> createState() => _SignupProfileInfoPageState();
}

class _SignupProfileInfoPageState extends ConsumerState<SignupProfileInfoPage> {
  String? gender;
  int? birthYear;
  final TextEditingController nicknameController = TextEditingController();
  String? nicknameValidationMsg;
  bool isNicknameValid = false;
  Timer? _debounce;

  bool _showYearPicker = false;
  int _selectedYearIndex = 0;
  late final List<String> _years;

  @override
  void initState() {
    super.initState();
    // 1900년부터 올해까지 연도 리스트 생성
    _years = List.generate(
      DateTime.now().year - 1899,
          (index) => (1900 + index).toString(),
    );

    final birthInfo = ref.read(birthInfoProvider);
    gender = birthInfo.gender;
    birthYear = birthInfo.birthYear != null ? int.tryParse(birthInfo.birthYear!) : null;

    if (birthYear != null) {
      _selectedYearIndex = _years.indexOf(birthYear.toString());
    } else {
      _selectedYearIndex = _years.indexOf('2005');
    }
  }

  final FocusNode _nicknameFocusNode = FocusNode();
  @override
  void dispose() {
    _debounce?.cancel();
    _nicknameFocusNode.dispose();
    super.dispose();
  }

  void validateNickname(String value) {
    // 1. 허용 문자: 한글+영문만, 공백 불가
    final isValidCharacters = RegExp(r'^[가-힣a-zA-Z]+$').hasMatch(value);
    final hasSpace = value.contains(' ');
    // 2. 길이 제한: 8자 이내
    final isLengthValid = value.length <= 8;

    if (value.isEmpty) {
      setState(() {
        nicknameValidationMsg = null;
        isNicknameValid = false;
      });
    } else if (hasSpace) {
      setState(() {
        nicknameValidationMsg = "닉네임에 공백은 사용할 수 없습니다";
        isNicknameValid = false;
      });
    } else if (!isValidCharacters) {
      setState(() {
        nicknameValidationMsg = "닉네임은 한글과 영문만 사용 가능합니다";
        isNicknameValid = false;
      });
    } else if (!isLengthValid) {
      setState(() {
        nicknameValidationMsg = "닉네임은 8자 이내여야 합니다";
        isNicknameValid = false;
      });
    } else {
      setState(() {
        nicknameValidationMsg = "사용가능한 닉네임입니다";
        isNicknameValid = true;
      });
    }
  }

  void _onNicknameChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      validateNickname(value);
    });
  }

  bool get isFormValid =>
      gender != null &&
          birthYear != null &&
          isNicknameValid &&
          !_showYearPicker;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPagination(),
              SizedBox(height: 20.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),
                      _buildMainText(),
                      SizedBox(height: 32.h),
                      _buildGenderButtons(),
                      SizedBox(height: 24.h),
                      _buildYearInputSection(),
                      SizedBox(height: 24.h),
                      _buildNicknameInput(),
                      _buildNicknameValidation(),
                    ],
                  ),
                ),
              ),
              _buildConfirmButton(),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      margin: EdgeInsets.only(top: 20.h),
      alignment: Alignment.center,
      child: PageIndicator(currentPage: 1, pageCount: 2),
    );
  }

  Widget _buildMainText() {
    return Text(
      "기본정보를 입력해주세요",
      style: AppTextStyles.heading2Bold.copyWith(color: AppColors.grayscale1),
      textAlign: TextAlign.left,
    );
  }

  Widget _buildGenderButtons() {
    return Container(
      width: 326.w,
      child: Row(
        children: [
          Expanded(child: _buildGenderButton("남성", gender == "남성")),
          SizedBox(width: 18.w),
          Expanded(child: _buildGenderButton("여성", gender == "여성")),
        ],
      ),
    );
  }

  Widget _buildGenderButton(String label, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() => gender = label);
        ref.read(birthInfoProvider.notifier).update(
                (state) => state.copyWith(gender: label)
        );
      },
      child: Container(
        width: 154.sp,
        height: 50.sp,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryPink : AppColors.grayscale6,
          borderRadius: BorderRadius.circular(10.sp),
        ),
        child: Text(
          label,
          style: AppTextStyles.body1.copyWith(
            color: isSelected ? AppColors.grayscale8 : AppColors.grayscale3,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildYearInputSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _showYearPicker = !_showYearPicker),
          child: Container(
            width: 326.w,
            height: 50.w,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grayscale4),
              borderRadius: BorderRadius.circular(10.r),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              birthYear?.toString() ?? "태어난 연도를 선택해주세요",
              style: AppTextStyles.body1Bold.copyWith(
                color:
                birthYear == null
                    ? AppColors.grayscale4
                    : AppColors.grayscale1,
              ),
            ),
          ),
        ),
        if (_showYearPicker)
          Container(
            width: 326.w,
            decoration: BoxDecoration(
              color: AppColors.grayscale7,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(10.r),
              ),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 180.h,
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                      initialItem: _selectedYearIndex,
                    ),
                    itemExtent: 40.h,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _selectedYearIndex = index;
                      });
                    },
                    children:
                    _years
                        .map(
                          (year) => Center(
                        child: Text(
                          year,
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.grayscale1,
                          ),
                        ),
                      ),
                    )
                        .toList(),
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Text(
                    '확인',
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.primaryPink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      birthYear = int.parse(_years[_selectedYearIndex]);
                      _showYearPicker = false;

                      ref.read(birthInfoProvider.notifier).update(
                              (state) => state.copyWith(birthYear: _years[_selectedYearIndex])
                      );
                    });
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildNicknameInput() {
    return SizedBox(
      width: 326.w,
      height: 50.w,
      child: TextField(
        focusNode: _nicknameFocusNode,
        controller: nicknameController,
        decoration: InputDecoration(
          hintText: "사용할 닉네임을 입력해주세요 (8자 이내)",
          hintStyle: AppTextStyles.body1Bold.copyWith(
            color: AppColors.grayscale4,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(
              color:
              nicknameValidationMsg != null && !isNicknameValid
                  ? AppColors.systemDanger
                  : AppColors.grayscale4,
              width: 1.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(
              color:
              nicknameValidationMsg != null && !isNicknameValid
                  ? AppColors.systemDanger
                  : AppColors.grayscale4,
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(
              color:
              nicknameValidationMsg != null && !isNicknameValid
                  ? AppColors.systemDanger
                  : AppColors.grayscale4,
              width: 1.0,
            ),
          ),
          suffixIcon:
          nicknameValidationMsg == null
              ? null
              : Icon(
            isNicknameValid ? Icons.check_circle : Icons.error,
            color:
            isNicknameValid
                ? AppColors.systemSuccess
                : AppColors.systemDanger,
          ),
        ),
        style: AppTextStyles.body1Bold,
        onTap: () {
          _nicknameFocusNode.requestFocus();
        },
        onChanged: _onNicknameChanged,
      ),
    );
  }

  Widget _buildNicknameValidation() {
    return Container(
      width: 326.w,
      height: 15.h,
      alignment: Alignment.centerLeft,
      child:
      nicknameValidationMsg != null
          ? Text(
        nicknameValidationMsg!,
        style: AppTextStyles.body6.copyWith(
          color:
          isNicknameValid
              ? AppColors.systemSuccessText
              : AppColors.systemDangerText,
        ),
        textAlign: TextAlign.left,
      )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: 327.w,
      height: 50.h,
      child: ElevatedButton(
        onPressed:
        isFormValid
            ? () {
          context.go(AppRoutePaths.signupComplete);
        }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
          isFormValid
              ? AppColors.primaryPink
              : AppColors.primaryPinkDisabled,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        child: Text(
          "확인",
          style: AppTextStyles.body1White,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
