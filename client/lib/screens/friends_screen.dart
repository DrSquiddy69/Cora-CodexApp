import 'package:flutter/material.dart';

import '../main.dart';
import '../services/cora_api_service.dart';
import '../services/session.dart';
import '../widgets/cora_scaffold.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final _code = TextEditingController();
  final _api = CoraApiService();
  String _result = '';

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _sendFriendRequest() async {
    final normalizedCode = _code.text.trim().toUpperCase();
    if (normalizedCode.length != 5) {
      setState(() => _result = 'Friend code must be 5 characters.');
      return;
    }

    try {
      final matrixId = await _api.resolveFriendCode(normalizedCode);
      final currentUser = Session.currentUser;
      if (currentUser == null) {
        setState(() => _result = 'Please log in before sending friend requests.');
        return;
      }

      await _api.createFriendRequest(
        fromMatrixUserId: currentUser.matrixUserId,
        toMatrixUserId: matrixId,
      );
      if (!mounted) return;
      setState(() => _result = 'Request sent to $matrixId');
    } catch (error) {
      if (!mounted) return;
      setState(() => _result = 'Could not send request: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CoraScaffold(
      title: 'Friends',
      currentIndex: 1,
      child: ListView(
        children: [
          GlassCard(
            child: Column(
              children: [
                TextField(
                  controller: _code,
                  decoration: const InputDecoration(labelText: 'Add by Friend Code'),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _sendFriendRequest,
                  child: const Text('Send friend request'),
                ),
                if (_result.isNotEmpty) Text(_result),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pending requests'),
                ListTile(
                  title: Text('AB2CD'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [Icon(Icons.check), Icon(Icons.close)],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}