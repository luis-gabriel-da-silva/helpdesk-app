import 'package:go_router/go_router.dart';

import '../../screens/home/home_screen.dart';
import '../../screens/login/login_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/ticket_detail/ticket_detail_screen.dart';
import '../../screens/ticket_form/ticket_form_screen.dart';
import 'app_routes.dart';

abstract class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.loginPath,
    routes: [
      GoRoute(
        path: AppRoutes.loginPath,
        name: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.homePath,
        name: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.ticketFormPath,
        name: AppRoutes.ticketForm,
        builder: (context, state) => const TicketFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.ticketDetailPath,
        name: AppRoutes.ticketDetail,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '0';
          return TicketDetailScreen(ticketId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.profilePath,
        name: AppRoutes.profile,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ProfileScreen(userId: id);
        },
      ),
    ],
  );
}
