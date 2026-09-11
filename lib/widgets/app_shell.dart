import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import 'app_header.dart';

/// App shell providing the top persistent government header
/// and bottom navigation bar for all 5 core mobile workbenches.
class AppShell extends StatelessWidget {
  final Widget child;
  final String location;

  const AppShell({super.key, required this.child, required this.location});

  int _calculateSelectedIndex() {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/tender-scrutiny') ||
        location.startsWith('/specification-builder')) {
      return 1;
    }
    if (location.startsWith('/standards') || location.startsWith('/graph')) {
      return 2;
    }
    if (location.startsWith('/work')) return 3;
    if (location.startsWith('/more')) return 4;
    return 0;
  }

  String get _breadcrumbSection {
    if (location.startsWith('/home')) return 'Command';
    if (location.startsWith('/specification-builder')) return 'Authoring';
    if (location.startsWith('/tender-scrutiny')) return 'Scrutiny';
    if (location.startsWith('/standards')) return 'Library';
    if (location.startsWith('/graph')) return 'Ontology';
    if (location.startsWith('/work')) return 'Workspace';
    if (location.startsWith('/more')) return 'System';
    return 'Scrutiny';
  }

  String get _breadcrumbTitle {
    if (location.startsWith('/home')) return 'Command Center';
    if (location.startsWith('/specification-builder')) {
      return 'Specification Builder';
    }
    if (location.startsWith('/tender-scrutiny')) {
      return 'Tender Scrutiny & Ingestion';
    }
    if (location.startsWith('/standards')) return 'Standards & QCO Explorer';
    if (location.startsWith('/graph')) return 'BIS Knowledge Graph';
    if (location.startsWith('/work')) return 'Saved Tenders & Analyses';
    if (location.startsWith('/more')) return 'Credentials & Statutory Rules';
    return 'Command Center';
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex();

    return Scaffold(
      appBar: AppHeader(
        breadcrumbSection: _breadcrumbSection,
        breadcrumbTitle: _breadcrumbTitle,
      ),
      body: SafeArea(child: child),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.outlineVariant, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) {
            switch (index) {
              case 0:
                context.go('/home');
                break;
              case 1:
                context.go('/tender-scrutiny');
                break;
              case 2:
                context.go('/standards');
                break;
              case 3:
                context.go('/work');
                break;
              case 4:
                context.go('/more');
                break;
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard, color: AppColors.primary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.troubleshoot_outlined),
              selectedIcon: Icon(Icons.troubleshoot, color: AppColors.primary),
              label: 'Analyze',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book, color: AppColors.primary),
              label: 'Standards',
            ),
            NavigationDestination(
              icon: Icon(Icons.folder_copy_outlined),
              selectedIcon: Icon(Icons.folder_copy, color: AppColors.primary),
              label: 'Work',
            ),
            NavigationDestination(
              icon: Icon(Icons.more_horiz_outlined),
              selectedIcon: Icon(Icons.more_horiz, color: AppColors.primary),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }
}
