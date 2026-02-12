import 'package:flutter/material.dart';

import '../main.dart';
import '../screens/chats_list_screen.dart';
import '../screens/friends_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';

class CoraScaffold extends StatelessWidget {
  const CoraScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.currentIndex = 0,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final int currentIndex;

  void _switchTab(BuildContext context, int index) {
    if (index == currentIndex) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) => _destinationScreen(index),
        transitionDuration: const Duration(milliseconds: 180),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        transitionsBuilder: (_, animation, __, page) =>
            FadeTransition(opacity: animation, child: page),
      ),
    );
  }

  Widget _destinationScreen(int index) {
    switch (index) {
      case 0:
        return const ChatsListScreen();
      case 1:
        return const FriendsScreen();
      case 2:
        return const ProfileScreen();
      case 3:
      default:
        return const SettingsScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktopLayout = width >= 900;
    final contentPadding = isDesktopLayout ? 12.0 : 16.0;

    final content = SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Padding(
            padding: EdgeInsets.all(contentPadding),
            child: child,
          ),
        ),
      ),
    );

    return LiquidGlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Colors.transparent,
          actions: actions,
        ),
        body: isDesktopLayout
            ? Row(
                children: [
                  NavigationRail(
                    selectedIndex: currentIndex,
                    onDestinationSelected: (index) => _switchTab(context, index),
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.chat_bubble_outline),
                        label: Text('Chats'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.people_outline),
                        label: Text('Friends'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.person_outline),
                        label: Text('Profile'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.settings_outlined),
                        label: Text('Settings'),
                      ),
                    ],
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: content),
                ],
              )
            : content,
        bottomNavigationBar: isDesktopLayout
            ? null
            : NavigationBar(
                backgroundColor: Colors.black.withValues(alpha: 0.2),
                selectedIndex: currentIndex,
                onDestinationSelected: (index) => _switchTab(context, index),
                destinations: const [
                  NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Chats'),
                  NavigationDestination(icon: Icon(Icons.people_outline), label: 'Friends'),
                  NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
                  NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
                ],
              ),
      ),
    );
  }
}
