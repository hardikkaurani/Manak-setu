import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'theme/app_theme.dart';
import 'widgets/app_shell.dart';
import 'screens/home_screen.dart';
import 'screens/tender_scrutiny_screen.dart';
import 'screens/specification_builder_screen.dart';
import 'screens/standards_explorer_screen.dart';
import 'screens/knowledge_graph_screen.dart';
import 'screens/work_screen.dart';
import 'screens/more_screen.dart';

/// Main application widget with GoRouter configuration across all 5 workbenches.
class ManakSetuApp extends StatelessWidget {
  final String initialLocation;

  const ManakSetuApp({super.key, this.initialLocation = '/home'});

  static GoRouter createRouter({String initialLocation = '/home'}) => GoRouter(
        initialLocation: initialLocation,
        routes: [
          ShellRoute(
            builder: (context, state, child) {
              return AppShell(location: state.matchedLocation, child: child);
            },
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
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
              GoRoute(
                path: '/standards',
                builder: (context, state) => const StandardsExplorerScreen(),
              ),
              GoRoute(
                path: '/graph',
                builder: (context, state) => KnowledgeGraphScreen(
                  standardCode: state.uri.queryParameters['standard'],
                  presetId: state.uri.queryParameters['preset'],
                ),
              ),
              GoRoute(
                path: '/work',
                builder: (context, state) => const WorkScreen(),
              ),
              GoRoute(
                path: '/more',
                builder: (context, state) => const MoreScreen(),
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
      routerConfig: createRouter(initialLocation: initialLocation),
    );
  }
}
