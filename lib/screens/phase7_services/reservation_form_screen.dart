import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/ui_feedback.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reservation_provider.dart';

class ReservationFormScreen extends StatefulWidget {
  const ReservationFormScreen({super.key});

  @override
  State<ReservationFormScreen> createState() => _ReservationFormScreenState();
}

class _ReservationFormScreenState extends State<ReservationFormScreen> {
  String _type = 'Zakaat';
  final TextEditingController _messageController = TextEditingController();

  final List<String> _types = const [
    'Zakaat',
    'Masjid Help',
    'Khatam Request',
    'Imam Help',
    'Nikah Items',
    'Chairs',
    'Tables',
    'Cooking Items',
    'Tent',
    'Food Help',
    'Finance Help',
    'Mayyat',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final provider = context.read<ReservationProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Service Request')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: _type,
              items: _types
                  .map(
                    (e) => DropdownMenuItem<String>(
                      value: e,
                      child: Text(e),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() => _type = v);
              },
              decoration: const InputDecoration(
                labelText: 'Request type',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _messageController,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Explain your request',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                final message = _messageController.text.trim();

                if (message.isEmpty) {
                  UIFeedback.errorSnack(
                    context,
                    'Please write your request.',
                  );
                  return;
                }

                await provider.submit(
                  userId: auth.user?.uid ?? '',
                  userEmail: auth.email,
                  type: _type,
                  message: message,
                );

                if (!context.mounted) return;

                UIFeedback.successSnack(
                  context,
                  'Request sent successfully.',
                );
                UIFeedback.showConfetti(context);
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.send),
              label: const Text('Send Request'),
            ),
          ],
        ),
      ),
    );
  }
}