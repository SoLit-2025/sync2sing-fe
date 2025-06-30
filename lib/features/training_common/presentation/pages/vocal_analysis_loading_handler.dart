import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/features/training_common/presentation/pages/vocal_analysis_loading_page.dart';
import 'package:sync2sing/shared/providers/vocal_analysis_submit_provider.dart';
import 'dart:io';

class VocalAnalysisLoadingHandler extends ConsumerWidget {
  const VocalAnalysisLoadingHandler({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submitState = ref.watch(vocalAnalysisSubmitProvider);

    return Scaffold(
      body: submitState.when(
        loading: () => const VocalAnalysisLoadingPage(),
        error: (error, _) => _buildErrorUI(error),
        data: (responseData) {
          // API 응답 데이터 직접 수신
          Future.microtask(() {
            if (context.mounted) {
              context.goNamed(
                AppRouteNames.vocalAnalysisReport,
                extra: responseData, // JSON 데이터 직접 전달
              );
            }
          });
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildErrorUI(Object error) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.red),
            const SizedBox(height: 20),
            Text('분석 실패: ${_getErrorMessage(error)}'),
          ],
        ),
      ),
    );
  }

  String _getErrorMessage(Object error) {
    if (error is HttpException) return error.message;
    if (error is SocketException) return '인터넷 연결 오류';
    return '알 수 없는 오류';
  }
}
