import 'package:flutter/material.dart';

import '../main.dart';
import '../widgets/cora_scaffold.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CoraScaffold(
      title: 'Profile',
      currentIndex: 2,
      child: ListView(
        children: [
          const GlassCard(
            child: Column(
              children: [
                CircleAvatar(radius: 38, child: Icon(Icons.person, size: 40)),
                SizedBox(height: 12),
                Text('Display Name'),
                Text('Friend Code: QK82M'),
                SizedBox(height: 8),
                Text('Bio: Building private chats with Cora.'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            child: const Text('Edit profile'),
          ),
        ],
      ),
    );
  }
}
