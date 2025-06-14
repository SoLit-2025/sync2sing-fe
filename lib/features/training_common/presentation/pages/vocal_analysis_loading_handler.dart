import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/features/training_common/presentation/pages/vocal_analysis_loading_page.dart';
import 'package:sync2sing/shared/providers/vocal_analysis_submit_provider.dart';
import 'dart:io';
import 'package:sync2sing/shared/providers/vocal_result_provider.dart';

class VocalAnalysisLoadingHandler extends ConsumerWidget {
  const VocalAnalysisLoadingHandler({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submitState = ref.watch(vocalAnalysisSubmitProvider);

    return submitState.when(
      loading: () => const VocalAnalysisLoadingPage(),
      error: (error, _) => _buildErrorUI(error),
      data: (_) {
        Future.microtask(() {
          if (context.mounted) {
            // ✅ 프로바이더에서 데이터 읽기
            final resultData = ref.read(vocalResultProvider);
            context.goNamed(
              AppRouteNames.vocalAnalysisReport,
              extra: resultData, // ⚡ 실제 데이터 전달
            );
          }
        });
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildErrorUI(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 50, color: Colors.red),
          const SizedBox(height: 20),
          Text('분석 실패: ${_getErrorMessage(error)}'),
        ],
      ),
    );
  }

  String _getErrorMessage(Object error) {
    if (error is HttpException) return error.message;
    if (error is SocketException) return '인터넷 연결 오류';
    return error.toString();
  }
}
