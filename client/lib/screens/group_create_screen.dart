import 'package:flutter/material.dart';

import '../widgets/glass_surface.dart';

class GroupCreateScreen extends StatefulWidget {
  const GroupCreateScreen({super.key});

  @override
  State<GroupCreateScreen> createState() => _GroupCreateScreenState();
}

class _GroupCreateScreenState extends State<GroupCreateScreen> {
  final _name = TextEditingController();
  final _friendCode = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return LiquidGlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, title: const Text('Create private group')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: GlassCard(
            child: Column(
              children: [
                TextField(controller: _name, decoration: const InputDecoration(labelText: 'Group name')),
                TextField(
                  controller: _friendCode,
                  decoration: const InputDecoration(labelText: 'Invite friend code (optional)'),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/group-chat'),
                  child: const Text('Create invite-only room'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
