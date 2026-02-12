import 'package:flutter/material.dart';

import '../theme/cora_theme.dart';
import '../widgets/cora_scaffold.dart';
import '../widgets/glass_surface.dart';

class ChatsListScreen extends StatelessWidget {
  const ChatsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CoraScaffold(
      title: 'Chats',
      currentIndex: 1,
      sidePanel: const _ConversationListPanel(),
      child: Center(
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No messages yet'),
              const SizedBox(height: CoraTokens.spaceMd),
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

class _ConversationListPanel extends StatelessWidget {
  const _ConversationListPanel();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Conversations',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: CoraTokens.spaceMd),
        Container(
          padding: const EdgeInsets.all(CoraTokens.spaceSm),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(CoraTokens.radiusMd),
            border: Border(
              left: BorderSide(
                color: const Color(0xFF44D8FF).withValues(alpha: 0.8),
                width: 3,
              ),
            ),
          ),
          child: const Text('No active conversations'),
        ),
      ],
    );
  }
}
