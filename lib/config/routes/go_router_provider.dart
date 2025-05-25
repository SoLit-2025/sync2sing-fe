import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_routes.dart';
import 'duet_training_routes.dart';
import 'my_routes.dart';
import 'solo_training_routes.dart';
import '../../main.dart';
import '../../dev/dev_config.dart';
import 'main_routes.dart';
import 'onboarding_routes.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: myDevRoute,
    routes: [
      GoRoute(path: '/', builder: (context, state) => const MyWidget()),
      ...onboardingRoutes,
      ...authRoutes,
      ...mainRoutes,
      ...soloTrainingRoutes,
      ...duetTrainingRoutes,
      ...myRoutes,
    ],
  );
});
