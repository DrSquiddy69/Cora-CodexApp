import 'package:flutter/material.dart';

import '../services/api_config.dart';
import '../theme/cora_theme.dart';
import '../widgets/glass_surface.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String get _serverLabel =>
      ApiConfig.instance.hasBaseUrl ? ApiConfig.instance.baseUrl : 'Not connected';

  Future<void> _openConnect() async {
    await Navigator.pushNamed(context, '/connect');
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LiquidGlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              tooltip: 'Connect',
              onPressed: _openConnect,
              icon: const Icon(Icons.link),
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(CoraTokens.spaceLg),
              child: GlassCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.forum_rounded,
                      size: 74,
                      color: Color(0xFF81EDFF),
                    ),
                    const SizedBox(height: CoraTokens.spaceMd),
                    Text('Cora', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: CoraTokens.spaceSm),
                    Text(
                      'Server: $_serverLabel',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: CoraTokens.spaceSm),
                    const Text(
                      'Private-first chat for friends and invite-only groups.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: CoraTokens.spaceLg),
                    FilledButton(
                      onPressed: () => Navigator.pushNamed(context, '/signup'),
                      child: const Text('Create account'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      child: const Text('I already have an account'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
