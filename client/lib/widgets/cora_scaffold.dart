import 'package:flutter/material.dart';

import '../screens/chats_list_screen.dart';
import '../screens/friends_screen.dart';
import '../screens/home_screen.dart';
import '../screens/settings_screen.dart';
import '../theme/cora_theme.dart';
import 'glass_surface.dart';

class CoraScaffold extends StatelessWidget {
  const CoraScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.currentIndex = 0,
    this.sidePanel,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final int currentIndex;
  final Widget? sidePanel;

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
        return const HomeScreen();
      case 1:
        return const ChatsListScreen();
      case 2:
        return const FriendsScreen();
      case 3:
      default:
        return const SettingsScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final desktop = width >= 1024;
    final tablet = width >= 600 && width < 1024;

    final mainPanel = GlassSurface(
      opacity: 0.14,
      child: child,
    );

    return LiquidGlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(title),
          actions: [
            if (tablet && sidePanel != null)
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.view_sidebar_outlined),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                ),
              ),
            ...?actions,
          ],
        ),
        endDrawer: tablet && sidePanel != null
            ? Drawer(
                backgroundColor: C
