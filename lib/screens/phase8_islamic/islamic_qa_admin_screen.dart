import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/islamic_qa_service.dart';
import '../../providers/auth_provider.dart';

class IslamicQaAdminScreen extends StatelessWidget {
  const IslamicQaAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final qa = context.watch<IslamicQaService>();
    final cs = Theme.of(context).colorScheme;

    if (!auth.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Q&A Admin')),
        body: const Center(
          child: Text('Admin only area.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Islamic Q&A – Admin'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: qa.questions.length,
        itemBuilder: (context, index) {
          final q = qa.questions[index];
          return Card(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.95),
            child: ListTile(
              title: Text(
                q.question,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                q.isAnswered
                    ? 'Answered: ${q.answer}'
                    : 'Not answered yet',
              ),
              trailing: Icon(
                q.isAnswered ? Icons.check_circle : Icons.edit,
                color: q.isAnswered ? cs.secondary : cs.primary,
              ),
              onTap: () async {
                final textController =
                    TextEditingController(text: q.answer ?? '');
                final res = await showDialog<String>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Write answer'),
                      content: TextField(
                        controller: textController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Type answer here...',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              Navigator.pop(context, textController.text),
                          child: const Text('Save'),
                        ),
                      ],
                    );
                  },
                );
                if (res != null && res.trim().isNotEmpty) {
                  qa.answerQuestion(q.id, res.trim());
                }
              },
            ),
          );
        },
      ),
    );
  }
}