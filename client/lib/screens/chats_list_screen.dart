import 'package:flutter/material.dart';

import '../main.dart';
import '../widgets/cora_scaffold.dart';

class ChatsListScreen extends StatelessWidget {
  const ChatsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CoraScaffold(
      title: 'Chats',
      currentIndex: 0,
      actions: [
        IconButton(
          onPressed: () => Navigator.pushNamed(context, '/group-create'),
          icon: const Icon(Icons.group_add_outlined),
        ),
      ],
      child: ListView(
        children: [
          const GlassCard(child: ListTile(title: Text('DM: Nova'), subtitle: Text('Encrypted chat ready'))),
          const SizedBox(height: 12),
          const GlassCard(child: ListTile(title: Text('Group: Project Cora'), subtitle: Text('Invite-only room'))),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () => Navigator.pushNamed(context, '/chat'),
            child: const Text('Open DM sample'),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pushNamed(context, '/group-chat'),
            child: const Text('Open Group sample'),
          ),
        ],
      ),
    );
  }
}
