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
                backgroundColor: Colors.transparent,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(CoraTokens.spaceMd),
                    child: GlassSurface(opacity: 0.09, child: sidePanel!),
                  ),
                ),
              )
            : null,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(CoraTokens.spaceMd),
            child: desktop
                ? Row(
                    children: [
                      _NavRail(
                        currentIndex: currentIndex,
                        onTap: (i) => _switchTab(context, i),
                      ),
                      const SizedBox(width: CoraTokens.spaceMd),
                      SizedBox(
                        width: 260,
                        child: GlassSurface(
                          opacity: 0.09,
                          child: sidePanel ?? const _ListPlaceholder(),
                        ),
                      ),
                      const SizedBox(width: CoraTokens.spaceMd),
                      Expanded(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 820),
                            child: mainPanel,
                          ),
                        ),
                      ),
                    ],
                  )
                : tablet
                    ? Row(
                        children: [
                          _NavRail(
                            currentIndex: currentIndex,
                            onTap: (i) => _switchTab(context, i),
                            extended: false,
                          ),
                          const SizedBox(width: CoraTokens.spaceMd),
                          Expanded(
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 820),
                                child: mainPanel,
                              ),
                            ),
                          ),
                        ],
                      )
                    : mainPanel,
          ),
        ),
        bottomNavigationBar: width < 600
            ? NavigationBar(
                selectedIndex: currentIndex,
                onDestinationSelected: (index) => _switchTab(context, index),
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.chat_bubble_outline),
                    label: 'Chats',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.people_outline),
                    label: 'Friends',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.settings_outlined),
                    label: 'Settings',
                  ),
                ],
              )
            : null,
      ),
    );
  }
}

class _NavRail extends StatelessWidget {
  const _NavRail({
    required this.currentIndex,
    required this.onTap,
    this.extended = true,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      opacity: 0.06,
      child: NavigationRail(
        extended: extended,
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        indicatorColor: const Color(0xFF3ED9FF).withValues(alpha: 0.25),
        destinations: const [
          NavigationRailDestination(
            icon: Icon(Icons.home_outlined),
            label: Text('Home'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.chat_bubble_outline),
            label: Text('Chats'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.people_outline),
            label: Text('Friends'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.settings_outlined),
            label: Text('Settings'),
          ),
        ],
      ),
    );
  }
}

class _ListPlaceholder extends StatelessWidget {
  const _ListPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.topLeft,
      child: Text('Select a section to view details.'),
    );
  }
}
