import 'package:flutter/material.dart';

import '../main.dart';
import '../widgets/cora_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CoraScaffold(
      title: 'Settings',
      currentIndex: 3,
      child: ListView(
        children: [
          const GlassCard(
            child: Column(
              children: [
                TextField(decoration: InputDecoration(labelText: 'Display name')),
                TextField(decoration: InputDecoration(labelText: 'Bio')),
                TextField(decoration: InputDecoration(labelText: 'Avatar URL')),
                SizedBox(height: 8),
                Text('Default: E2EE enabled for DMs and private groups.'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: () {}, child: const Text('Save changes')),
          OutlinedButton(
            onPressed: () => Navigator.pushNamed(context, '/about'),
            child: const Text('About / Legal'),
          ),
        ],
      ),
    );
  }
}
