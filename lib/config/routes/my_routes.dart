import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/features/my_page/presentation/pages/my_page.dart';

final List<GoRoute> myRoutes = [
  GoRoute(
    path: AppRoutePaths.my,
    name: AppRouteNames.my,
    builder: (context, state) => const MyPage(),
  ),
];
