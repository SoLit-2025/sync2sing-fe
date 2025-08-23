import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/features/my/views/my_page.dart';
import 'package:sync2sing/features/my/views/settings_page.dart';
import 'package:sync2sing/features/report/views/vocal_analysis_report_page.dart';
import 'package:sync2sing/features/shared/logics/analysis_type.dart';
import 'package:sync2sing/features/shared/logics/training_mode.dart';

final List<GoRoute> myRoutes = [
  GoRoute(
    path: AppRoutePaths.my,
    name: AppRouteNames.my,
    builder: (context, state) => const MyPage(),
  ),
  GoRoute(
    path: AppRoutePaths.settings,
    name: AppRouteNames.settings,
    builder: (context, state) => const SettingsPage(),
  ),
  GoRoute(
    path: "${AppRoutePaths.vocalAnalysisReport}/:trainingMode/:analysisType",
    name: AppRouteNames.vocalAnalysisReport,
    builder: (context, state) {
      final trainingMode = TrainingMode.values.firstWhere(
        (e) => e.name == state.pathParameters['trainingMode'],
      );
      final analysisType = AnalysisType.values.firstWhere(
        (e) => e.name == state.pathParameters['analysisType'],
      );
      return VocalAnalysisReportPage(trainingMode: trainingMode, analysisType: analysisType);
    },
  ),
];
