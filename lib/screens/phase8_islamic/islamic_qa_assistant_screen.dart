import 'package:flutter/material.dart';

class IslamicQaAssistantScreen extends StatefulWidget {
  const IslamicQaAssistantScreen({super.key});

  @override
  State<IslamicQaAssistantScreen> createState() => _IslamicQaAssistantScreenState();
}

class _IslamicQaAssistantScreenState extends State<IslamicQaAssistantScreen> {
  final _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _ask() {
    final q = _controller.text.trim();
    if (q.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': q});
      _messages.add({
        'role': 'assistant',
        'text': 'Your question has been saved. Please ask the imam/admin for a verified Islamic answer.'
      });
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Islamic Q&A')),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(child: Text('Ask a question about Islam.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final m = _messages[index];
                      final isUser = m['role'] == 'user';
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          constraints: const BoxConstraints(maxWidth: 320),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.green.shade100 : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(m['text']!),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type your question',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _ask,
                  child: const Text('Send'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}