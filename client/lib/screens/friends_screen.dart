import 'package:flutter/material.dart';

import '../services/cora_api_service.dart';
import '../services/session.dart';
import '../theme/cora_theme.dart';
import '../widgets/cora_scaffold.dart';
import '../widgets/glass_surface.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final _code = TextEditingController();
  final _api = CoraApiService();

  String _result = '';
  bool _loadingRequests = false;
  List<FriendRequestItem> _pendingRequests = const [];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    final currentUser = Session.currentUser;
    if (currentUser == null) {
      setState(() {
        _pendingRequests = const [];
        _result = 'Please log in before managing friend requests.';
      });
      return;
    }

    setState(() => _loadingRequests = true);
    try {
      final requests = await _api.listFriendRequests(currentUser.matrixUserId);
      if (!mounted) return;
      setState(() => _pendingRequests = requests);
    } catch (error) {
      if (!mounted) return;
      setState(() => _result = 'Could not load friend requests: $error');
    } finally {
      if (mounted) setState(() => _loadingRequests = false);
    }
  }

  Future<void> _sendFriendRequest() async {
    final normalizedCode = _code.text.trim().toUpperCase();
    if (normalizedCode.length != 5) {
      setState(() => _result = 'Friend code must be 5 characters.');
      return;
    }

    final currentUser = Session.currentUser;
    if (currentUser == null) {
      setState(() => _result = 'Please log in before sending friend requests.');
      return;
    }

    try {
      final matrixId = await _api.resolveFriendCode(normalizedCode);

      // Prevent sending a request to yourself (frontend guard).
      if (matrixId == currentUser.matrixUserId) {
        setState(() => _result = 'You cannot send a friend request to yourself.');
        return;
      }

      await _api.createFriendRequest(
        fromMatrixUserId: currentUser.matrixUserId,
        toMatrixUserId: matrixId,
      );

      if (!mounted) return;
      setState(() => _result = 'Request sent to $matrixId');
      await _loadRequests();
    } catch (error) {
      if (!mounted) return;
      setState(() => _result = 'Could not send request: $error');
    }
  }

  Future<void> _updateRequest(int requestId, String status) async {
    try {
      await _api.updateFriendRequest(requestId: requestId, status: status);
      if (!mounted) return;
      setState(() => _result = 'Request $status');
      await _loadRequests();
    } catch (error) {
      if (!mounted) return;
      setState(() => _result = 'Could not update request: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CoraScaffold(
      title: 'Friends',
      currentIndex: 2,
      sidePanel: const _FriendsSidePanel(),
      child: ListView(
        children: [
          GlassCard(
            child: Column(
              children: [
                TextField(
                  controller: _code,
                  decoration: const InputDecoration(
                    labelText: 'Add by Friend Code',
                  ),
                ),
                const SizedBox(height: CoraTokens.spaceMd),
                FilledButton(
                  onPressed: _sendFriendRequest,
                  child: const Text('Send friend request'),
                ),
                if (_result.isNotEmpty) ...[
                  const SizedBox(height: CoraTokens.spaceSm),
                  Text(_result),
                ],
              ],
            ),
          ),
          const SizedBox(height: CoraTokens.spaceMd),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pending requests'),
                const SizedBox(height: CoraTokens.spaceSm),
                if (_loadingRequests)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_pendingRequests.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('No pending requests'),
                  )
                else
                  ..._pendingRequests.map(
                    (request) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(request.fromMatrixUserId),
                      subtitle: Text('Received ${request.createdAt}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check),
                            onPressed: () =>
                                _updateRequest(request.id, 'accepted'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () =>
                                _updateRequest(request.id, 'denied'),
                          ),
                        ],
                      ),
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

class _FriendsSidePanel extends StatelessWidget {
  const _FriendsSidePanel();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('People', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: CoraTokens.spaceMd),
        Container(
          padding: const EdgeInsets.all(CoraTokens.spaceSm),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(CoraTokens.radiusMd),
            border: Border(
              left: BorderSide(color: const Color(0xFF44D8FF), width: 3),
            ),
          ),
          child: const Text('Use friend code to connect'),
        ),
      ],
    );
  }
}
