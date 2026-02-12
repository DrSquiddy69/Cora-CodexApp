import 'package:flutter/material.dart';

import '../main.dart';
import '../services/cora_api_service.dart';
import '../services/session.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _displayName = TextEditingController();
  final _api = CoraApiService();
  String _status = '';

  @override
  Widget build(BuildContext context) {
    return LiquidGlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Sign up'),
          actions: [
            IconButton(
              onPressed: () => Navigator.pushNamed(context, '/settings'),
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: GlassCard(
            child: Column(
              children: [
                TextField(controller: _displayName, decoration: const InputDecoration(labelText: 'Display name')),
                TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
                TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () async {
                    final user = await _api.signup(_email.text, _password.text, _displayName.text);
                    Session.currentUser = user;
                    setState(() => _status = 'Friend code: ${user.friendCode}');
                    if (mounted) Navigator.pushReplacementNamed(context, '/chats');
                  },
                  child: const Text('Create account'),
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
