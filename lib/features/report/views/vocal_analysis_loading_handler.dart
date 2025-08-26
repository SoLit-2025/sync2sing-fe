import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/features/report/logics/analysis_params.dart';
import 'package:sync2sing/features/shared/logics/analysis_type.dart';
import 'package:sync2sing/features/shared/logics/training_mode.dart';
import 'vocal_analysis_loading_page.dart';
import '../logics/vocal_analysis_submit_provider.dart';
import 'dart:io';

class VocalAnalysisLoadingHandler extends ConsumerWidget {
  final TrainingMode trainingMode;
  final AnalysisType analysisType;

  const VocalAnalysisLoadingHandler({
    super.key,
    required this.trainingMode,
    required this.analysisType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<Map<String, dynamic>>>(
      vocalAnalysisSubmitProvider(
        AnalysisParams(trainingMode: trainingMode, analysisType: analysisType),
      ),
      (previous, next) {
        if (next.hasValue && context.mounted) {
          // 응답을 정상적으로 받으면
          context.go(
            "${AppRoutePaths.vocalAnalysisReport}/${trainingMode.name}/${analysisType.name}",
            extra: next.value,
          );
        }
      },
    );
    // 나머지는 로딩/에러만 UI로 표현
    return Scaffold(
      body: ref
          .watch(
            vocalAnalysisSubmitProvider(
              AnalysisParams(trainingMode: trainingMode, analysisType: analysisType),
            ),
          )
          .when(
            loading: () => const VocalAnalysisLoadingPage(),
            error: (error, _) => _buildErrorUI(error),
            data: (_) => const SizedBox.shrink(),
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
