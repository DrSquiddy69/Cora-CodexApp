import 'package:flutter/material.dart';

import '../main.dart';
import '../services/cora_api_service.dart';
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

  static const _currentUserMatrixId = '@me:cora.local';

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
                TextField(controller: _code, decoration: const InputDecoration(labelText: 'Add by Friend Code')),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () async {
                    final matrixId = await _api.resolveFriendCode(_code.text.trim().toUpperCase());
                    await _api.createFriendRequest(
                      fromMatrixUserId: _currentUserMatrixId,
                      toMatrixUserId: matrixId,
                    );
                    setState(() => _result = 'Request sent to $matrixId');
                  },
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
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.check), Icon(Icons.close)]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
