import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/features/onboarding/voice_analysis/presentation/widgets/onboarding_page_indicator.dart';

class UserBirthInfoInputPage extends StatefulWidget {
  const UserBirthInfoInputPage({super.key});

  @override
  State<UserBirthInfoInputPage> createState() => _UserBirthInfoInputPageState();
}

class _UserBirthInfoInputPageState extends State<UserBirthInfoInputPage> {
  String? _selectedGender;
  String? _selectedYear;
  bool _isYearPickerVisible = false;
  bool _isButtonActive = false;
  int _pickerTempIndex = 0;
  final List<String> _years = List.generate(
    DateTime.now().year - 1899,
    (index) => (1900 + index).toString(),
  );

  void _selectGender(String gender) {
    setState(() {
      _selectedGender = gender;
      _updateButtonState();
    });
  }

  void _toggleYearPicker() {
    setState(() {
      _isYearPickerVisible = !_isYearPickerVisible;
      _pickerTempIndex =
          _selectedYear != null
              ? _years.indexOf(_selectedYear!)
              : (_years.length - 21);
    });
  }

  void _onYearChanged(int index) {
    setState(() {
      _pickerTempIndex = index;
    });
  }

  void _confirmYear() {
    setState(() {
      _selectedYear = _years[_pickerTempIndex];
      _isYearPickerVisible = false;
      _updateButtonState();
    });
  }

  void _updateButtonState() {
    setState(() {
      _isButtonActive = _selectedGender != null && _selectedYear != null;
    });
  }

  void _navigateToVoiceSamplePage() {
    if (_isButtonActive) {
      context.go('/onboarding/voice_sample');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.grayscale7,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 32.h),
              Center(child: OnboardingPageIndicator(currentPage: 0)),
              SizedBox(height: 40.h),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 40.h),
                    Text(
                      '맞춤형 보컬 분석을 시작합니다',
                      style: TextStyle(
                        color: AppColors.grayscale1,
                        fontSize: 22.sp,
                        fontFamily: 'Pretendard Variable',
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                        decoration: TextDecoration.none,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      '입력된 정보를 통해\n음역대를 더 정확하게 측정할 수 있어요',
                      style: TextStyle(
                        color: AppColors.grayscale1,
                        fontSize: 20.sp,
                        fontFamily: 'Pretendard Variable',
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                        decoration: TextDecoration.none,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 40.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildGenderButton(
                          text: '남성',
                          isSelected: _selectedGender == '남성',
                          onTap: () => _selectGender('남성'),
                        ),
                        SizedBox(width: 18.w),
                        _buildGenderButton(
                          text: '여성',
                          isSelected: _selectedGender == '여성',
                          onTap: () => _selectGender('여성'),
                        ),
                      ],
                    ),
                    SizedBox(height: 28.h),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: _toggleYearPicker,
                          child: Container(
                            width: 326.w,
                            height: 50.h,
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              color: AppColors.grayscale8,
                              borderRadius:
                                  _isYearPickerVisible
                                      ? BorderRadius.only(
                                        topLeft: Radius.circular(10.r),
                                        topRight: Radius.circular(10.r),
                                      )
                                      : BorderRadius.circular(10.r),
                              border: Border.all(
                                color: AppColors.grayscale4,
                                width: 1.0,
                                strokeAlign: BorderSide.strokeAlignInside,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _selectedYear ?? '태어난 연도를 선택해주세요',
                              style: TextStyle(
                                color:
                                    _selectedYear == null
                                        ? AppColors.grayscale3
                                        : AppColors.grayscale1,
                                fontSize: 17.sp,
                                fontFamily: 'Pretendard Variable',
                                fontWeight: FontWeight.w400,
                                height: 1.4,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                        if (_isYearPickerVisible)
                          Container(
                            width: 326.w,
                            decoration: BoxDecoration(
                              color: AppColors.grayscale7,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10.r),
                                bottomRight: Radius.circular(10.r),
                              ),
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 180.h,
                                  child: CupertinoPicker(
                                    backgroundColor: AppColors.grayscale7,
                                    scrollController:
                                        FixedExtentScrollController(
                                          initialItem: _pickerTempIndex,
                                        ),
                                    itemExtent: 40.h,
                                    onSelectedItemChanged: _onYearChanged,
                                    children:
                                        _years
                                            .map(
                                              (year) => Center(
                                                child: Text(
                                                  year,
                                                  style: TextStyle(
                                                    fontSize: 22.sp,
                                                    fontFamily:
                                                        'Pretendard Variable',
                                                    fontWeight: FontWeight.w400,
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
                                    style: TextStyle(
                                      color: AppColors.primaryPink,
                                      fontSize: 17.sp,
                                      fontFamily: 'Pretendard Variable',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  onPressed: _confirmYear,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              Column(
                children: [
                  Center(
                    child: CupertinoButton(
                      onPressed:
                          _isButtonActive ? _navigateToVoiceSamplePage : null,
                      padding: EdgeInsets.zero,
                      child: Container(
                        width: 327.w,
                        height: 50.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color:
                              _isButtonActive
                                  ? AppColors.primaryPink
                                  : AppColors.grayscale5,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          '확인',
                          style: TextStyle(
                            color:
                                _isButtonActive
                                    ? AppColors.grayscale8
                                    : AppColors.grayscale2,
                            fontSize: 17.sp,
                            fontFamily: 'Pretendard Variable',
                            fontWeight:
                                _isButtonActive
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 50.h),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderButton({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      onPressed: onTap,
      padding: EdgeInsets.zero,
      child: Container(
        width: 154.w,
        height: 50.h,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryPink : AppColors.grayscale5,
          borderRadius: BorderRadius.circular(10.r),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? AppColors.grayscale8 : AppColors.grayscale2,
            fontSize: 17.sp,
            fontFamily: 'Pretendard Variable',
            fontWeight: FontWeight.w400,
            height: 1.4,
            decoration: TextDecoration.none,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
