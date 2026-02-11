import 'package:flutter/material.dart';

import '../main.dart';
import '../services/cora_api_service.dart';

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

  @override
  Widget build(BuildContext context) {
    return LiquidGlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, title: const Text('Log in')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: GlassCard(
            child: Column(
              children: [
                TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
                TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () async {
                    final user = await _api.login(_email.text, _password.text);
                    setState(() => _status = 'Welcome ${user.displayName} (${user.friendCode})');
                    if (mounted) Navigator.pushReplacementNamed(context, '/chats');
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
