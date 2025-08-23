import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/features/curriculum/logics/curriculum_generation_request.dart';
import 'package:sync2sing/features/shared/logics/training_mode.dart';

import '../logics/curriculum_create_loading_provider.dart';
import '../logics/training_grade.dart';

class TrainingGenerationLoadingPage extends ConsumerWidget {
  // final CurriculumGenerationRequest curriculumGenerationRequest = CurriculumGenerationRequest(
  //   trainingMode: TrainingMode.solo,
  //   pitch: TrainingGrade.low,
  //   rhythm: TrainingGrade.medium,
  //   pronunciation: TrainingGrade.high,
  //   breath: TrainingGrade.high,
  //   trainingDays: 3,
  // ); // api 연결을 위한 객체.

  // TrainingGenerationLoadingPage({super.key});

  // extra로 정보 전달 시::
  final CurriculumGenerationRequest curriculumGenerationRequest;
  const TrainingGenerationLoadingPage(this.curriculumGenerationRequest, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // debugPrint("트레이닝 모드: ${curriculumCreateData.trainingMode.name}");
    debugPrint("request: ${curriculumGenerationRequest.toUpperJson()}");
    final state = ref.watch(curriculumCreateLoadingProvider);

    return state.when(
      loading: () => _buildLoadingPage(), // 로딩 중 -> 로딩 중 페이지
      error: (e, _) => Center(child: Text('에러 발생: $e')),
      data: (_) {
        // 응답(현재 기준 2초 후) 받으면 다음 페이지로 이동
        Future.microtask(() {
          context.goNamed(AppRouteNames.mainHome); // 임의로 이동 페이지 설정
        });
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoadingPage() {
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
                "맞춤형 훈련 생성 중입니다...",
                style: TextStyle(
                  fontSize: 15.w,
                  color: AppColors.grayscale1,
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
