import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/cora_api_service.dart';
import '../services/session.dart';
import '../theme/cora_theme.dart';
import '../widgets/cora_scaffold.dart';
import '../widgets/glass_surface.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _api = CoraApiService();
  final _displayName = TextEditingController();
  final _bio = TextEditingController();
  String? _avatarUrl;
  bool _saving = false;
  String _status = '';

  @override
  void initState() {
    super.initState();
    final current = Session.currentUser;
    _displayName.text = current?.displayName ?? '';
    _bio.text = current?.bio ?? '';
    _avatarUrl = current?.avatarUrl;
  }

  @override
  void dispose() {
    _displayName.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _changePhoto() async {
    try {
      File? selected;

      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        final picker = ImagePicker();
        final file = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
        );
        if (file != null) selected = File(file.path);
      } else {
        final picked = await FilePicker.platform.pickFiles(type: FileType.image);
        final path = picked?.files.single.path;
        if (path != null) selected = File(path);
      }

      if (selected == null) return;

      setState(() {
        _saving = true;
        _status = 'Uploading avatar...';
      });

      final uploadedUrl = await _api.uploadAvatar(selected);
      if (!mounted) return;

      setState(() {
        _avatarUrl = uploadedUrl;
        _saving = false;
        _status = 'Photo uploaded. Save profile to apply.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _status = 'Failed to upload photo: $error';
      });
    }
  }

  Future<void> _saveProfile() async {
    final current = Session.currentUser;
    if (current == null) {
      setState(() => _status = 'Please log in first.');
      return;
    }

    setState(() {
      _saving = true;
      _status = 'Saving profile...';
    });

    try {
      final updated = await _api.updateProfile(
        email: current.email, // used for auth/lookup, but NOT displayed
        displayName: _displayName.text.trim(),
        bio: _bio.text.trim(),
        avatarUrl: _avatarUrl,
      );

      await Session.setCurrentUser(updated);
      if (!mounted) return;

      setState(() {
        _saving = false;
        _status = 'Profile saved';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _status = 'Failed to save profile: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = Session.currentUser;

    return CoraScaffold(
      title: 'Profile',
      currentIndex: 3,
      child: ListView(
        padding: const EdgeInsets.all(CoraTokens.spaceMd),
        children: [
          GlassCard(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundImage: _avatarUrl != null && _avatarUrl!.isNotEmpty
                      ? NetworkImage(_avatarUrl!)
                      : null,
                  child: (_avatarUrl == null || _avatarUrl!.isEmpty)
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                const SizedBox(height: CoraTokens.spaceMd),
                if (current != null)
                  Text(
                    'Friend Code: ${current.friendCode}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                const SizedBox(height: CoraTokens.spaceSm),
                TextField(
                  controller: _displayName,
                  decoration: const InputDecoration(labelText: 'Display name'),
                ),
                const SizedBox(height: CoraTokens.spaceSm),
                TextField(
                  controller: _bio,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Bio'),
                ),
                const SizedBox(height: CoraTokens.spaceMd),
                OutlinedButton(
                  onPressed: _saving ? null : _changePhoto,
                  child: const Text('Change photo'),
                ),
                const SizedBox(height: CoraTokens.spaceSm),
                FilledButton(
                  onPressed: _saving ? null : _saveProfile,
                  child: const Text('Save profile'),
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
