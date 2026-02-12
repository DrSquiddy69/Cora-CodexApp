import 'dart:ui';

import 'package:flutter/material.dart';

import 'screens/about_screen.dart';
import 'services/api_config.dart';
import 'screens/chat_screen.dart';
import 'screens/connect_screen.dart';
import 'screens/chats_list_screen.dart';
import 'screens/friends_screen.dart';
import 'screens/group_create_screen.dart';
import 'screens/group_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiConfig.instance.load();
  runApp(const CoraApp());
}

class CoraApp extends StatelessWidget {
  const CoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6AE6FF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF091326),
        useMaterial3: true,
      ),
      initialRoute: ApiConfig.instance.hasBaseUrl ? '/' : '/connect',
      routes: {
        '/': (_) => const WelcomeScreen(),
        '/connect': (_) => const ConnectScreen(),
        '/signup': (_) => const SignupScreen(),
        '/login': (_) => const LoginScreen(),
        '/chats': (_) => const ChatsListScreen(),
        '/chat': (_) => const ChatScreen(),
        '/group-create': (_) => const GroupCreateScreen(),
        '/group-chat': (_) => const GroupScreen(),
        '/friends': (_) => const FriendsScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/about': (_) => const AboutScreen(),
      },
    );
  }
}

class LiquidGlassBackground extends StatelessWidget {
  const LiquidGlassBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF081025),
                Color(0xFF10335D),
                Color(0xFF0B5FA3),
              ],
            ),
          ),
        ),
        Opacity(
          opacity: 0.07,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 0.4, sigmaY: 0.4),
            child: CustomPaint(painter: _NoisePainter()),
          ),
        ),
        child,
      ],
    );
  }
}

class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
            boxShadow: [
              BoxShadow(
                blurRadius: 22,
                spreadRadius: 0,
                color: const Color(0xFF53C7FF).withValues(alpha: 0.25),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _NoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.08);
    for (var i = 0; i < 1600; i++) {
      final dx = (i * 73) % size.width;
      final dy = (i * 37) % size.height;
      canvas.drawCircle(Offset(dx, dy), 0.55, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
