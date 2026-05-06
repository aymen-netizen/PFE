import 'package:flutter/material.dart';

class AssistantChatScreen extends StatelessWidget {
  final String conversationId;

  const AssistantChatScreen({
    super.key,
    required this.conversationId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with $conversationId'),
      ),
      body: const Center(
        child: Text('Chat coming soon...'),
      ),
    );
  }
}