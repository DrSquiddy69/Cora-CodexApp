import 'package:flutter/material.dart';

import '../main.dart';
import '../services/api_config.dart';

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
              padding: const EdgeInsets.all(24),
              child: GlassCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.forum_rounded, size: 74, color: Color(0xFF81EDFF)),
                    const SizedBox(height: 16),
                    Text('Cora', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text('Server: $_serverLabel', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 8),
                    const Text(
                      'Private-first chat for friends and invite-only groups.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
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
