import 'package:flutter/material.dart';

import '../main.dart';

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

  static const _routes = ['/chats', '/friends', '/profile', '/settings'];

  @override
  Widget build(BuildContext context) {
    return LiquidGlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Colors.transparent,
          actions: actions,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
        bottomNavigationBar: NavigationBar(
          backgroundColor: Colors.black.withValues(alpha: 0.2),
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            if (index == currentIndex) return;
            Navigator.pushReplacementNamed(context, _routes[index]);
          },
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
