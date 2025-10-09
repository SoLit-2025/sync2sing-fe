import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/features/home_hub/views/main_tab_screen.dart';
import 'package:sync2sing/features/my/views/license_page.dart';
import 'package:sync2sing/features/my/views/settings_page.dart';
import 'package:sync2sing/features/report/views/detail_vocal_analyssis_report_page.dart';
import 'package:sync2sing/features/report/views/vocal_analysis_report_page.dart';
import 'package:sync2sing/features/shared/logics/analysis_type.dart';
import 'package:sync2sing/features/shared/logics/training_mode.dart';

final List<GoRoute> myRoutes = [
  GoRoute(
    path: AppRoutePaths.my,
    name: AppRouteNames.my,
    builder: (context, state) => const MainTabScreen(initialTabIndex: 3),
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
  GoRoute(
    path: "${AppRoutePaths.detailReportPage}/:id",
    name: AppRouteNames.detailReportPage,
    builder: (context, state) {
      final trainingMode = TrainingMode.values.firstWhere(
        (e) => e.name == state.uri.queryParameters['trainingMode'],
      );
      final reportIdStr = state.pathParameters['id'];
      final reportId = int.tryParse(reportIdStr!);
      return DetailVocalAnalysisReportPage(reportId: reportId!, trainingMode: trainingMode);
    },
  ),
  GoRoute(
    path: AppRoutePaths.license,
    name: AppRouteNames.license,
    builder: (context, state) => const LicensePage(),
  ),
];
