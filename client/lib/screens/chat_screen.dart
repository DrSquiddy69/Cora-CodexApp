import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/cora_theme.dart';
import '../widgets/glass_surface.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

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
    if (event is! KeyDownEvent ||
        event.logicalKey != LogicalKeyboardKey.enter) {
      return KeyEventResult.ignored;
    }

    // Shift+Enter => newline
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

    // Enter => send
    _sendMessage();
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final desktopEmojiHint =
        defaultTargetPlatform == TargetPlatform.windows ||
                defaultTargetPlatform == TargetPlatform.macOS ||
                defaultTargetPlatform == TargetPlatform.linux
            ? 'Tip: press Win + . for emoji'
            : 'Use your keyboard emoji button';

    return LiquidGlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('DM chat'),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(CoraTokens.spaceMd),
                itemCount: _messages.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Align(
                    alignment: index.isEven
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: GlassSurface(child: Text(_messages[index])),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(CoraTokens.spaceMd),
              child: Row(
                children: [
                  Tooltip(
                    message: desktopEmojiHint,
                    child: IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(desktopEmojiHint),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.emoji_emotions_outlined),
                    ),
                  ),
                  Expanded(
                    child: Focus(
                      onKeyEvent: _onKey,
                      child: TextField(
                        controller: _controller,
                        focusNode: _inputFocus,
                        minLines: 1,
                        maxLines: 5,
                        decoration:
                            const InputDecoration(hintText: 'Type a message'),
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
        ),
      ),
    );
  }
}
