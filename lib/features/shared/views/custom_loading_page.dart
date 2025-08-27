import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';

class CustomLoading extends StatelessWidget {
  final String text;
  const CustomLoading({super.key, this.text = "정보를 조회 중입니다"});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CupertinoActivityIndicator(radius: 25.r),
          Container(
            margin: EdgeInsets.only(top: 20.h),
            child: Text(text, style: AppTextStyles.body1),
          ),
        ],
      ),
    );
  }
}
