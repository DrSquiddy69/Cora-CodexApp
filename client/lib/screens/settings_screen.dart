import 'package:flutter/material.dart';

import '../services/api_config.dart';
import '../services/app_settings.dart';
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
  bool _enterToSend = AppSettings.enterToSend;
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

  Future<void> _saveApiUrl() async {
    final url = _apiBaseUrl.text.trim();
    await ApiConfig.instance.saveBaseUrl(url);
    if (!mounted) return;
    setState(() => _status = 'Saved API URL');
  }

  Future<void> _setEnterToSend(bool value) async {
    await AppSettings.setEnterToSend(value);
    if (!mounted) return;
    setState(() {
      _enterToSend = value;
      _status = 'Saved message input preference';
    });
  }

  @override
  Widget build(BuildContext context) {
    final current = Session.currentUser;

    return CoraScaffold(
      title: 'Settings',
      currentIndex: 3,
      child: ListView(
        padding: const EdgeInsets.all(CoraTokens.spaceMd),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Account', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: CoraTokens.spaceSm),
                Text(
                  current != null
                      ? 'Signed in as: ${current.displayName}'
                      : 'Not signed in',
                ),
                if (current != null) ...[
                  const SizedBox(height: CoraTokens.spaceSm),
                  Text('Friend Code: ${current.friendCode}'),
                ],
                const SizedBox(height: CoraTokens.spaceMd),
                FilledButton.tonal(
                  onPressed: () => Navigator.pushNamed(context, '/profile'),
                  child: const Text('Edit profile'),
                ),
              ],
            ),
          ),
          const SizedBox(height: CoraTokens.spaceMd),
          GlassCard(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Enter to send'),
              subtitle: const Text('Desktop Enter sends, Shift+Enter adds newline.'),
              value: _enterToSend,
              onChanged: _setEnterToSend,
            ),
          ),
          const SizedBox(height: CoraTokens.spaceMd),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _apiBaseUrl,
                  decoration: const InputDecoration(
                    labelText: 'Cora API base URL',
                    hintText: 'http://127.0.0.1:8080',
                  ),
                ),
                const SizedBox(height: CoraTokens.spaceSm),
                FilledButton(
                  onPressed: _saveApiUrl,
                  child: const Text('Save settings'),
                ),
                if (_status.isNotEmpty) ...[
                  const SizedBox(height: CoraTokens.spaceSm),
                  Text(_status),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
