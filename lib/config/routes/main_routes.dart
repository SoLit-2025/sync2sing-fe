import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/features/main_home/presentation/pages/main_home_page.dart';

final List<GoRoute> mainRoutes = [
  GoRoute(
    path: AppRoutePaths.mainHome,
    name: AppRouteNames.mainHome,
    builder: (context, state) => const MainHomePage(),
  ),
];
