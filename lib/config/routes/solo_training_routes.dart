import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/features/solo_training/presentation/pages/solo_training_home_page.dart';

final List<GoRoute> soloTrainingRoutes = [
  GoRoute(
    path: AppRoutePaths.soloTrainingHome,
    name: AppRouteNames.soloTrainingHome,
    builder: (context, state) => const SoloTrainingHomePage(),
  ),
];
