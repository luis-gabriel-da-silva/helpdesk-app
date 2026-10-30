import 'package:flutter/material.dart';

import 'core/constants/app_strings.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'screens/home/home_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/ticket_detail/ticket_detail_screen.dart';
import 'screens/ticket_form/ticket_form_screen.dart';

final _appRouter = AppRouter.create(
  loginBuilder: () => const LoginScreen(),
  homeBuilder: () => const HomeScreen(),
  ticketFormBuilder: () => const TicketFormScreen(),
  ticketDetailBuilder: (id) => TicketDetailScreen(ticketId: id),
  ticketEditBuilder: (id) => TicketFormScreen(ticketId: id),
  profileBuilder: (id) => ProfileScreen(userId: id),
);

class HelpDeskApp extends StatelessWidget {
  const HelpDeskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: _appRouter,
    );
  }
}
