import 'package:flutter/material.dart';

import '../services/api_config.dart';
import '../services/session.dart';
import '../theme/cora_theme.dart';
import '../widgets/cora_scaffold.dart';
import '../widgets/glass_surface.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _apiBaseUrl;
  String _status = '';

  @override
  void initState() {
    super.initState();
    _apiBaseUrl = TextEditingController(text: ApiConfig.instance.baseUrl);
  }

  @override
  void dispose() {
    _apiBaseUrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final email = Session.currentUser?.email ?? 'Not signed in';

    return CoraScaffold(
      title: 'Settings',
      currentIndex: 3,
      child: ListView(
        children: [
          GlassSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Account', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: CoraTokens.spaceSm),
                Text('Email: $email'),
                const SizedBox(height: CoraTokens.spaceMd),
                FilledButton.tonal(
                  onPressed: () => Navigator.pushNamed(context, '/profile'),
                  child: const Text('Edit profile'),
                ),
              ],
            ),
          ),
          const SizedBox(height: CoraTokens.spaceMd),
          GlassSurface(
            child: Column(
              children: [
                TextField(
                  controller: _apiBaseUrl,
                  decoration: const InputDecoration(
                    labelText: 'Cora API base URL',
                    hintText: 'http://127.0.0.1:8080',
                  ),
                ),
                const SizedBox(height: CoraTokens.spaceSm),
                if (_status.isNotEmpty) Text(_status),
              ],
            ),
          ),
          const SizedBox(height: CoraTokens.spaceMd),
          FilledButton(
            onPressed: () async {
              await ApiConfig.instance.saveBaseUrl(_apiBaseUrl.text);
              if (!mounted) return;
              setState(() => _status = 'Saved API URL');
            },
            child: const Text('Save changes'),
          ),
        ],
      ),
    );
  }
}
