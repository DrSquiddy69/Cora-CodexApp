 import 'package:flutter/material.dart';

import '../main.dart';
import '../services/api_config.dart';
import '../widgets/cora_scaffold.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _displayName = TextEditingController();
  final _bio = TextEditingController();
  final _avatar = TextEditingController();
  late final TextEditingController _apiBaseUrl;
  String _status = '';

  @override
  void initState() {
    super.initState();
    _apiBaseUrl = TextEditingController(text: ApiConfig.instance.baseUrl);
  }

  @override
  void dispose() {
    _displayName.dispose();
    _bio.dispose();
    _avatar.dispose();
    _apiBaseUrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CoraScaffold(
      title: 'Settings',
      currentIndex: 3,
      child: ListView(
        children: [
          GlassCard(
            child: Column(
              children: [
                TextField(
                  controller: _displayName,
                  decoration: const InputDecoration(labelText: 'Display name'),
                ),
                TextField(
                  controller: _bio,
                  decoration: const InputDecoration(labelText: 'Bio'),
                ),
                TextField(
                  controller: _avatar,
                  decoration: const InputDecoration(labelText: 'Avatar URL'),
                ),
                TextField(
                  controller: _apiBaseUrl,
                  decoration: const InputDecoration(
                    labelText: 'Cora API base URL',
                    hintText: 'http://10.0.2.2:8080',
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Default: E2EE enabled for DMs and private groups.'),
                if (_status.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(_status),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () async {
              await ApiConfig.instance.saveBaseUrl(_apiBaseUrl.text);
              if (!mounted) return;
              setState(() => _status = 'Saved API URL: ${ApiConfig.instance.baseUrl}');
            },
            child: const Text('Save changes'),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pushNamed(context, '/about'),
            child: const Text('About / Legal'),
          ),
        ],
      ),
    );
  }
}