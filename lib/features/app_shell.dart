import 'package:flutter/material.dart';
import 'package:youmi_dev/features/analytics/analytics.dart';
import 'package:youmi_dev/features/dashboard/dashboard.dart';
import 'package:youmi_dev/features/library/library.dart';
import 'package:youmi_dev/features/planner/planner.dart';
import 'package:youmi_dev/features/settings/settings.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() {
    return _AppShellState();
  }
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  void _goToSettings() {
    setState(() {
      _currentIndex = 4;
    });
  }

  late final List<_ShellDestination> _destinations = [
    _ShellDestination(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      view: DashboardView(onOpenSettings: _goToSettings),
    ),
    const _ShellDestination(
      label: 'Planner',
      icon: Icons.event_outlined,
      view: PlannerView(),
    ),
    const _ShellDestination(
      label: 'Library',
      icon: Icons.menu_book_outlined,
      view: LibraryView(),
    ),
    const _ShellDestination(
      label: 'Analytics',
      icon: Icons.insights_outlined,
      view: AnalyticsView(),
    ),
    const _ShellDestination(
      label: 'Settings',
      icon: Icons.settings_outlined,
      view: SettingsView(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> views = [];
    for (int i = 0; i < _destinations.length; i++) {
      views.add(_destinations[i].view);
    }
    final List<BottomNavigationBarItem> items = [];
    for (int i = 0; i < _destinations.length; i++) {
      final destination = _destinations[i];
      items.add(
        BottomNavigationBarItem(
          icon: Icon(destination.icon),
          label: destination.label,
        ),
      );
    }
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: views,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: items,
      ),
    );
  }
}

class _ShellDestination {
  final String label;
  final IconData icon;
  final Widget view;

  const _ShellDestination({
    required this.label,
    required this.icon,
    required this.view,
  });
}