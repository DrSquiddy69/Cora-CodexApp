import 'package:flutter/material.dart';

import 'screens/about_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/chats_list_screen.dart';
import 'screens/connect_screen.dart';
import 'screens/friends_screen.dart';
import 'screens/group_create_screen.dart';
import 'screens/group_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/welcome_screen.dart';

import 'services/api_config.dart';
import 'services/cora_api_service.dart';
import 'services/session.dart';

import 'theme/cora_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiConfig.instance.load();
  await Session.load();
  await Session.refreshFromBackend(CoraApiService());
  runApp(const CoraApp());
}

class CoraApp extends StatelessWidget {
  const CoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cora',
      debugShowCheckedModeBanner: false,
      theme: buildCoraTheme(),
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeScreen(),
        '/welcome': (_) => const WelcomeScreen(),
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
