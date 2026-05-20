import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key, required this.child});

  final Widget child;

  static const List<_NavDestination> _destinations = [
    _NavDestination(
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      path: '/home',
    ),
    _NavDestination(
      label: 'Articles',
      icon: Icons.article_outlined,
      activeIcon: Icons.article,
      path: '/articles',
    ),
    _NavDestination(
      label: 'Appointment',
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today,
      path: '/appointments',
    ),
    _NavDestination(
      label: 'Polls',
      icon: Icons.poll_outlined,
      activeIcon: Icons.poll,
      path: '/polls',
    ),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _destinations.length; i++) {
      if (location.startsWith(_destinations[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => context.go(_destinations[index].path),
        destinations: _destinations
            .map(
              (destination) => NavigationDestination(
                label: destination.label,
                icon: Icon(destination.icon),
                selectedIcon: Icon(destination.activeIcon),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _NavDestination {
  const _NavDestination({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.path,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String path;
}
