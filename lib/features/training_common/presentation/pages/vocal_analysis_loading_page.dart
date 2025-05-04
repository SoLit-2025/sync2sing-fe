import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync2sing/config/theme/app_colors.dart';

class VocalAnalysisLoadingPage extends StatelessWidget {
  const VocalAnalysisLoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(390, 844));

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CupertinoActivityIndicator(radius: 25.r),
            Container(
              margin: EdgeInsets.only(top: 20.h),
              child: Text(
                "보컬 분석 리포트 생성 중입니다...",
                style: TextStyle(
                  fontSize: 15.w,
                  color: AppColors.neutralBlack,
                  fontVariations: <FontVariation>[FontVariation('wght', 400)],
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
