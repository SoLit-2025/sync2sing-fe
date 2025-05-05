import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/features/dual_training/presentation/pages/dual_training_home_page.dart';

final List<GoRoute> dualTrainingRoutes = [
  GoRoute(
    path: AppRoutePaths.dualTrainingHome,
    name: AppRouteNames.dualTrainingHome,
    builder: (context, state) => const DualTrainingHomePage(),
  ),
];
