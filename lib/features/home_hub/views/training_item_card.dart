import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';

import '../logics/training_item.dart';

class TrainingItemCard extends StatelessWidget {
  final TrainingItem trainingItem;
  final int sessionId;
  final bool showButton;
  final bool isMicReq;
  final Color? backGroundColor;

  /// [isMicReq] 마이크가 필요한지 여부, 기본값: [true]
  /// [backGroundColor] 기본값: [AppColors.grayscale8]
  const TrainingItemCard({
    super.key,
    required this.trainingItem,
    required this.sessionId,
    required this.showButton,
    this.isMicReq = true,
    this.backGroundColor = AppColors.grayscale8,
  });

  Widget _trainingCardTop() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          trainingItem.category,
          style: AppTextStyles.body5Bold.copyWith(color: AppColors.primaryPink),
        ),

        if (isMicReq)
          Row(
            children: [
              Text("마이크 사용 필요 ", style: AppTextStyles.body6.copyWith(color: AppColors.grayscale4)),
              Image.asset(
                'assets/images/training_card_mic_icon.png',
                width: 15.r,
                height: 16.r,
                color: AppColors.grayscale4,
                fit: BoxFit.contain,
              ),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: showButton ? 150.h : 95.h,
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(12.w, 5.h, 12.w, 5.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: backGroundColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 5.h),
              _trainingCardTop(),
              SizedBox(height: 3.h),
              RichText(
                text: TextSpan(
                  style: AppTextStyles.body5,
                  children: [
                    TextSpan(
                      text: "${trainingItem.title}\n",
                      style: AppTextStyles.body1Bold.copyWith(fontSize: 18.sp),
                    ),
                    TextSpan(
                      text: trainingItem.description,
                      style: TextStyle(color: AppColors.grayscale3),
                    ),
                  ],
                ),
              ),
              if (showButton)
                Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: AppColors.primaryPink,
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  margin: EdgeInsets.only(top: 12.h),
                  child: CupertinoButton(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    onPressed: () {},
                    child: Text('연습하러 가기', style: AppTextStyles.body2BoldWhite),
                  ),
                ),
            ],
          ),
        ),
        if (trainingItem.progress >= 100)
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Image.asset(
              'assets/images/training_card_complete_cover.png', // 덮어씌울 이미지
              width: double.infinity,
              height: 95.h,
              fit: BoxFit.cover,
            ),
          ),
      ],
    );
  }
}
