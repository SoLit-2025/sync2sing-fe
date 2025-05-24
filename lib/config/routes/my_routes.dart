import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/features/my/presentation/pages/my_page.dart';
import 'package:sync2sing/features/my/presentation/pages/vocal_analysis_report_page.dart';

final List<GoRoute> myRoutes = [
  GoRoute(
    path: AppRoutePaths.my,
    name: AppRouteNames.my,
    builder: (context, state) => const MyPage(),
  ),
  GoRoute(
    path: AppRoutePaths.vocalAnalysisReport,
    name: AppRouteNames.vocalAnalysisReport,
    builder: (context, state) => const VocalAnalysisReportPage(),
  ),
];
