import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../main.dart';
import '../../dev/dev_config.dart';
import 'onboarding_routes.dart';


final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
      initialLocation: myDevRoute,
      routes: [
        GoRoute(path: '/', builder: (context, state) => const MyWidget()),
        ...onboardingRoutes
      ],
  );
});
