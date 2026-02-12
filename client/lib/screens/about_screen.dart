import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/glass_surface.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LiquidGlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, title: const Text('About / Legal')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cora 1.0', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                const Text('Licensed under GNU AGPLv3. You can run, study, share, and modify this software under the AGPL terms.'),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => launchUrl(Uri.parse('https://github.com/your-org/Cora-CodexApp')),
                  child: const Text('Source Code'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
