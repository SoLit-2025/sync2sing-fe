import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/features/home_hub/views/duet_training_home_page.dart';
import 'package:sync2sing/features/home_hub/views/main_tab_screen.dart';
import 'package:sync2sing/features/home_hub/views/solo_training_home_page.dart';

final List<GoRoute> homeHubRoutes = [
  GoRoute(
    path: AppRoutePaths.mainHome,
    name: AppRouteNames.mainHome,
    builder: (context, state) => const MainTabScreen(),
  ),
  GoRoute(
    path: AppRoutePaths.soloTrainingHome,
    name: AppRouteNames.soloTrainingHome,
    builder: (context, state) => const SoloTrainingHomePage(),
  ),
  GoRoute(
    path: AppRoutePaths.duetTrainingHome,
    name: AppRouteNames.duetTrainingHome,
    builder: (context, state) => const DuetTrainingHomePage(),
  ),
];
