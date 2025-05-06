import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/features/training_common/presentation/pages/vocal_analysis_loading_page.dart';
import 'package:sync2sing/shared/providers/vocal_analysis_submit_provider.dart';

class VocalAnalysisLoadingHandler extends ConsumerWidget {
  const VocalAnalysisLoadingHandler({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submitState = ref.watch(vocalAnalysisSubmitProvider);

    return submitState.when(
      loading: () => VocalAnalysisLoadingPage(), // 로딩 중 페이지 보여줌
      error: (e, _) => Center(child: Text('에러 발생: $e')),
      data: (_) {
        // 응답(현재 기준 2초 후) 받으면 다음 페이지로 이동
        Future.microtask(() {
          context.goNamed(AppRouteNames.onboardingQuestion); // 임의로 이동 페이지 설정
        });
        return const SizedBox.shrink();
      },
    );
  }
}
