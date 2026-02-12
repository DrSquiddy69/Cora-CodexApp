import 'package:flutter/material.dart';

import '../main.dart';
import '../services/api_config.dart';
import '../services/cora_api_service.dart';
import '../services/session.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _api = CoraApiService();
  String _status = '';

  String get _serverLabel =>
      ApiConfig.instance.hasBaseUrl ? ApiConfig.instance.baseUrl : 'Not connected';

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

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
          title: const Text('Log in'),
          actions: [
            IconButton(
              tooltip: 'Connect',
              onPressed: _openConnect,
              icon: const Icon(Icons.link),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: GlassCard(
            child: Column(
              children: [
                Text('Server: $_serverLabel', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
                TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () async {
                    try {
                      final user = await _api.login(_email.text, _password.text);
                      await Session.setCurrentUser(user);
                      setState(() => _status = 'Welcome ${user.displayName} (${user.friendCode})');
                      if (mounted) Navigator.pushReplacementNamed(context, '/chats');
                    } catch (_) {
                      setState(
                        () => _status =
                            'Login failed. Not connected? Tap Connect in the top-right.',
                      );
                    }
                  },
                  child: const Text('Log in'),
                ),
                if (_status.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_status)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
