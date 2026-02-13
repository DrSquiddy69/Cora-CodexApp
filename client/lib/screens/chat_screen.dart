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
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(text);
      _controller.clear();
    });

    _inputFocus.requestFocus();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    // Don't override mobile IME behavior.
    if (_isMobile) return KeyEventResult.ignored;

    // Only handle key-down Enter presses.
    if (event is! KeyDownEvent || event.logicalKey != LogicalKeyboardKey.enter) {
      return KeyEventResult.ignored;
    }

    // Shift+Enter => newline (always).
    if (HardwareKeyboard.instance.isShiftPressed) {
      final value = _controller.value;
      final text = value.text;
      final selection = value.selection;

      final start = selection.start >= 0 ? selection.start : text.length;
      final end = selection.end >= 0 ? selection.end : text.length;

      final updated = text.replaceRange(start, end, '\n');
      _controller.value = TextEditingValue(
        text: updated,
        selection: TextSelection.collapsed(offset: start + 1),
      );
      return KeyEventResult.handled;
    }

    // Enter => send (only if enabled)
    if (!widget.enterToSend) return KeyEventResult.ignored;

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
                      alignment: index.isEven
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
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
                    keyboardType: TextInputType.multiline,
                    textInputAction: widget.enterToSend
                        ? TextInputAction.send
                        : TextInputAction.newline,
                    onSubmitted: (_) {
                      if (_isMobile && widget.enterToSend) _sendMessage();
                    },
                    decoration: const InputDecoration(hintText: 'Message...'),
                  ),
                ),
              ),
              IconButton(
                onPressed: _sendMessage,
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
