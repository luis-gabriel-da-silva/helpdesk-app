import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';

typedef IdScreenBuilder = Widget Function(String id);

abstract class AppRouter {
  static GoRouter create({
    required Widget Function() loginBuilder,
    required Widget Function() homeBuilder,
    required Widget Function() ticketFormBuilder,
    required IdScreenBuilder ticketDetailBuilder,
    required IdScreenBuilder ticketEditBuilder,
    required IdScreenBuilder profileBuilder,
  }) {
    return GoRouter(
      initialLocation: AppRoutes.loginPath,
      routes: [
        GoRoute(
          path: AppRoutes.loginPath,
          name: AppRoutes.login,
          builder: (context, state) => loginBuilder(),
        ),
        GoRoute(
          path: AppRoutes.homePath,
          name: AppRoutes.home,
          builder: (context, state) => homeBuilder(),
        ),
        GoRoute(
          path: AppRoutes.ticketFormPath,
          name: AppRoutes.ticketForm,
          builder: (context, state) => ticketFormBuilder(),
        ),
        GoRoute(
          path: AppRoutes.ticketDetailPath,
          name: AppRoutes.ticketDetail,
          builder: (context, state) =>
              ticketDetailBuilder(state.pathParameters['id'] ?? '0'),
        ),
        GoRoute(
          path: AppRoutes.ticketEditPath,
          name: AppRoutes.ticketEdit,
          builder: (context, state) =>
              ticketEditBuilder(state.pathParameters['id'] ?? '0'),
        ),
        GoRoute(
          path: AppRoutes.profilePath,
          name: AppRoutes.profile,
          builder: (context, state) =>
              profileBuilder(state.pathParameters['id'] ?? ''),
        ),
      ],
    );
  }
}
