import 'package:flutter/material.dart';
import 'package:youmi_dev/features/analytics/analytics.dart';
import 'package:youmi_dev/features/dashboard/dashboard.dart';
import 'package:youmi_dev/features/library/library.dart';
import 'package:youmi_dev/features/planner/planner.dart';
import 'package:youmi_dev/features/settings/settings.dart';
import 'package:youmi_dev/style/paper_widgets.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() {
    return _AppShellState();
  }
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  final Set<int> _visitedIndices = {0};

  void _goToSettings() {
    setState(() {
      _currentIndex = 4;
      _visitedIndices.add(4);
    });
  }

  late final List<_ShellDestination> _destinations = [
    _ShellDestination(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
      builder: () {
        return DashboardView(onOpenSettings: _goToSettings);
      },
    ),
    _ShellDestination(
      label: 'Planner',
      icon: Icons.event_outlined,
      selectedIcon: Icons.event_rounded,
      builder: () {
        return const PlannerView();
      },
    ),
    _ShellDestination(
      label: 'Library',
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book_rounded,
      builder: () {
        return const LibraryView();
      },
    ),
    _ShellDestination(
      label: 'Analytics',
      icon: Icons.insights_outlined,
      selectedIcon: Icons.insights_rounded,
      builder: () {
        return const AnalyticsView();
      },
    ),
    _ShellDestination(
      label: 'Settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings_rounded,
      builder: () {
        return const SettingsView();
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> views = [];
    for (int i = 0; i < _destinations.length; i++) {
      if (_visitedIndices.contains(i)) {
        views.add(_destinations[i].builder());
      } else {
        views.add(const SizedBox.shrink());
      }
    }
    final items = [
      for (final destination in _destinations)
        PillNavItem(
          label: destination.label,
          icon: destination.icon,
          selectedIcon: destination.selectedIcon,
        ),
    ];
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.surfaceContainerLowest,
            colorScheme.surface,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: IndexedStack(
          index: _currentIndex,
          children: views,
        ),
        bottomNavigationBar: PillNavBar(
          currentIndex: _currentIndex,
          items: items,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
              _visitedIndices.add(index);
            });
          },
        ),
      ),
    );
  }
}

class _ShellDestination {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget Function() builder;

  const _ShellDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.builder,
  });
}
  