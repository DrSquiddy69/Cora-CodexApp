import 'package:flutter/material.dart';

import '../services/api_config.dart';
import '../services/cora_api_service.dart';
import '../services/session.dart';
import '../theme/cora_theme.dart';
import '../widgets/glass_surface.dart';

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

  Future<void> _login() async {
    setState(() => _status = '');

    try {
      final user = await _api.login(_email.text, _password.text);
      await Session.setCurrentUser(user);
      if (!mounted) return;

      setState(() => _status = 'Welcome ${user.displayName} (${user.friendCode})');

      // After login, go to Home (your "Welcome to Cora!" + patch notes screen).
      Navigator.pushReplacementNamed(context, '/');
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _status = 'Login failed. Not connected? Tap Connect in the top-right.',
      );
    }
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
          padding: const EdgeInsets.all(CoraTokens.spaceMd),
          child: GlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Server: $_serverLabel',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: CoraTokens.spaceSm),
                TextField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: CoraTokens.spaceMd),
                FilledButton(
                  onPressed: _login,
                  child: const Text('Log in'),
                ),
                if (_status.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: CoraTokens.spaceSm),
                    child: Text(_status),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
