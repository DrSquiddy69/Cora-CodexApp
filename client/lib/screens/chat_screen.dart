import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/cora_theme.dart';
import '../widgets/glass_surface.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    this.title = 'Chat',
    this.enterToSend = true,
  });

  final String title;
  final bool enterToSend;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _messages = <String>[];
  final _inputFocus = FocusNode();

  bool get _isMobile =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  @override
  void dispose() {
    _controller.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final trimmed = _controller.text.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _messages.add(trimmed);
      _controller.clear();
    });
    _inputFocus.requestFocus();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (_isMobile || event is! KeyDownEvent || event.logicalKey != LogicalKeyboardKey.enter) {
      return KeyEventResult.ignored;
    }

    if (!widget.enterToSend) {
      return KeyEventResult.ignored;
    }

    if (HardwareKeyboard.instance.isShiftPressed) {
      final value = _controller.value;
      final start = value.selection.start >= 0 ? value.selection.start : value.text.length;
      final end = value.selection.end >= 0 ? value.selection.end : value.text.length;
      final updated = value.text.replaceRange(start, end, '\n');
      _controller.value = TextEditingValue(
        text: updated,
        selection: TextSelection.collapsed(offset: start + 1),
      );
      return KeyEventResult.handled;
    }

    _sendMessage();
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _messages.isEmpty
              ? Center(
                  child: GlassCard(
                    child: Text(
                      'No messages yet. Start chatting!',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(CoraTokens.spaceMd),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Align(
                      alignment: index.isEven ? Alignment.centerLeft : Alignment.centerRight,
                      child: GlassCard(child: Text(_messages[index])),
                    ),
                  ),
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(CoraTokens.spaceMd),
          child: Row(
            children: [
              Expanded(
                child: Focus(
                  onKeyEvent: _onKey,
                  child: TextField(
                    controller: _controller,
                    focusNode: _inputFocus,
                    minLines: 1,
                    maxLines: 5,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) {
                      if (_isMobile || widget.enterToSend) {
                        _sendMessage();
                      }
                    },
                    decoration: const InputDecoration(hintText: 'Message...'),
                  ),
                ),
              ),
              IconButton(onPressed: _sendMessage, icon: const Icon(Icons.send)),
            ],
          ),
        ),
      ],
    );
  }
}
