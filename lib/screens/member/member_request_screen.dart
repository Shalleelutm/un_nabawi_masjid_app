import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/request_provider.dart';

class MemberRequestScreen extends StatefulWidget {
  const MemberRequestScreen({super.key});

  @override
  State<MemberRequestScreen> createState() => _MemberRequestScreenState();
}

class _MemberRequestScreenState extends State<MemberRequestScreen> {
  final _messageController = TextEditingController();

  String _type = 'General Support';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RequestProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Member Requests')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: _type,
              items: const [
                DropdownMenuItem(
                  value: 'Financial Help',
                  child: Text('Financial Help'),
                ),
                DropdownMenuItem(
                  value: 'Zakat Assistance',
                  child: Text('Zakat Assistance'),
                ),
                DropdownMenuItem(
                  value: 'General Support',
                  child: Text('General Support'),
                ),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _type = v);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Message',
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await provider.createRequest(
                  _type,
                  _messageController.text,
                );

                _messageController.clear();
              },
              child: const Text('Submit Request'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: provider.requests.length,
                itemBuilder: (_, i) {
                  final r = provider.requests[i];

                  return Card(
                    child: ListTile(
                      title: Text(r.type),
                      subtitle: Text(r.message),
                      trailing: Text(r.status),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}