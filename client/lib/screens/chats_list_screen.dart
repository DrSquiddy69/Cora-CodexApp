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
      child: Center(
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No messages yet'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => Navigator.pushNamed(context, '/chat'),
                child: const Text('Start DM'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
