import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import 'app_header.dart';

/// App shell providing the top persistent government header
/// and bottom navigation bar for mobile workbenches.
class AppShell extends StatelessWidget {
  final Widget child;
  final String location;

  const AppShell({super.key, required this.child, required this.location});

  int _calculateSelectedIndex() {
    if (location.startsWith('/specification-builder')) return 1;
    return 0; // Default to Tender Scrutiny
  }

  String get _breadcrumbSection {
    if (location.startsWith('/specification-builder')) {
      return 'Authoring';
    }
    return 'Scrutiny';
  }

  String get _breadcrumbTitle {
    if (location.startsWith('/specification-builder')) {
      return 'Specification Builder';
    }
    return 'Tender Scrutiny & Ingestion';
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
            if (index == 0) {
              context.go('/tender-scrutiny');
            } else if (index == 1) {
              context.go('/specification-builder');
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.troubleshoot_outlined),
              selectedIcon: Icon(Icons.troubleshoot, color: AppColors.primary),
              label: 'Tender Scrutiny',
            ),
            NavigationDestination(
              icon: Icon(Icons.edit_note_outlined),
              selectedIcon: Icon(Icons.edit_note, color: AppColors.primary),
              label: 'Spec Builder',
            ),
          ],
        ),
      ),
    );
  }
}
