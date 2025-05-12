import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/features/duet_training/presentation/pages/duet_training_home_page.dart';

final List<GoRoute> duetTrainingRoutes = [
  GoRoute(
    path: AppRoutePaths.duetTrainingHome,
    name: AppRouteNames.duetTrainingHome,
    builder: (context, state) => const DuetTrainingHomePage(),
  ),
];
