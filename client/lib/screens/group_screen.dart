import 'package:flutter/material.dart';

import '../widgets/glass_surface.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LiquidGlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, title: const Text('Private group')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            GlassCard(child: Text('E2EE enabled by default in private rooms (Matrix capable clients).')),
            SizedBox(height: 10),
            GlassCard(child: Text('Invite-only members:\n• You\n• QK82M')), 
          ],
        ),
      ),
    );
  }
}
