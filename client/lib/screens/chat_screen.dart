import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _messages = <String>['Welcome to your E2EE DM'];
  bool _emojiOpen = false;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, title: const Text('DM chat')),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
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
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => setState(() => _emojiOpen = !_emojiOpen),
                    icon: const Icon(Icons.emoji_emotions_outlined),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(hintText: 'Type a message'),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (_controller.text.isEmpty) return;
                      setState(() {
                        _messages.add(_controller.text);
                        _controller.clear();
                      });
                    },
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
            if (_emojiOpen)
              SizedBox(
                height: 260,
                child: EmojiPicker(
                  onEmojiSelected: (_, emoji) => _controller.text += emoji.emoji,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
