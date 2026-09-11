import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'theme/app_theme.dart';
import 'widgets/app_shell.dart';
import 'screens/tender_scrutiny_screen.dart';
import 'screens/specification_builder_screen.dart';

/// Main application widget with GoRouter configuration.
class ManakSetuApp extends StatelessWidget {
  const ManakSetuApp({super.key});

  static final GoRouter _router = GoRouter(
    initialLocation: '/tender-scrutiny',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(location: state.matchedLocation, child: child);
        },
        routes: [
          GoRoute(
            path: '/tender-scrutiny',
            builder: (context, state) => const TenderScrutinyScreen(),
          ),
          GoRoute(
            path: '/specification-builder',
            builder: (context, state) => SpecificationBuilderScreen(
              presetId: state.uri.queryParameters['preset'],
            ),
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ManakSetu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: _router,
    );
  }
}
