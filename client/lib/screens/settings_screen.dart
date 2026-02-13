import 'package:flutter/material.dart';

import '../services/api_config.dart';
import '../services/app_settings.dart';
import '../services/session.dart';
import '../theme/cora_theme.dart';
import '../widgets/glass_surface.dart';

class SettingsPanel extends StatefulWidget {
  const SettingsPanel({super.key});

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
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

  @override
  Widget build(BuildContext context) {
    final email = Session.currentUser?.email ?? 'Not signed in';

    return ListView(
      padding: const EdgeInsets.all(CoraTokens.spaceMd),
      children: [
        GlassCard(
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
        GlassCard(
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Enter to send'),
            subtitle: const Text('Desktop Enter sends, Shift+Enter adds newline.'),
            value: _enterToSend,
            onChanged: (value) async {
              await AppSettings.setEnterToSend(value);
              if (!mounted) return;
              setState(() {
                _enterToSend = value;
                _status = 'Saved message input preference';
              });
            },
          ),
        ),
        const SizedBox(height: CoraTokens.spaceMd),
        GlassCard(
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
              FilledButton(
                onPressed: () async {
                  await ApiConfig.instance.saveBaseUrl(_apiBaseUrl.text);
                  if (!mounted) return;
                  setState(() => _status = 'Saved API URL');
                },
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
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LiquidGlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, title: const Text('Settings')),
        body: const SettingsPanel(),
      ),
    );
  }
}
