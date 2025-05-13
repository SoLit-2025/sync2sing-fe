import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/features/auth/presentation/pages/login_page.dart';
import 'package:sync2sing/features/auth/presentation/pages/signup_complete_page.dart';
import 'package:sync2sing/features/auth/presentation/pages/signup_id_password_page.dart';
import 'package:sync2sing/features/auth/presentation/pages/signup_profile_info_page.dart';

final List<GoRoute> authRoutes = [
  GoRoute(
    path: AppRoutePaths.signupIdPassword,
    name: AppRouteNames.signupIdPassword,
    builder: (context, state) => const SignupIdPasswordPage(),
  ),
  GoRoute(
    path: AppRoutePaths.signupProfileInfo,
    name: AppRouteNames.signupProfileInfo,
    builder: (context, state) => const SignupProfileInfoPage(),
  ),
  GoRoute(
    path: AppRoutePaths.signupComplete,
    name: AppRouteNames.signupComplete,
    builder: (context, state) => const SignupCompletePage(),
  ),
  GoRoute(
    path: AppRoutePaths.login,
    name: AppRouteNames.login,
    builder: (context, state) => const Loginpage(),
  ),
];
