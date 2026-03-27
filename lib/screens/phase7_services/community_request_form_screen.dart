import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/community_request_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/community_request_service.dart';
import '../../services/local_notification_service.dart';

class CommunityRequestFormScreen extends StatefulWidget {
  const CommunityRequestFormScreen({super.key});

  @override
  State<CommunityRequestFormScreen> createState() =>
      _CommunityRequestFormScreenState();
}

class _CommunityRequestFormScreenState
    extends State<CommunityRequestFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final descriptionController = TextEditingController();

  String category = 'Mayaat';
  bool _submitting = false;

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();

    final request = CommunityRequestModel(
      id: const Uuid().v4(),
      userName: auth.displayName,
      userEmail: auth.email.isEmpty ? 'guest@local.app' : auth.email,
      category: category,
      eventDate: DateTime.now(),
      chairs: 0,
      tables: 0,
      plates: 0,
      mats: 0,
      expectedGuests: 0,
      description: descriptionController.text.trim(),
      status: 'pending',
      adminNote: '',
      createdAt: DateTime.now(),
    );

    setState(() => _submitting = true);

    await CommunityRequestService.submit(request);

    await LocalNotificationService.instance.showNow(
      title: 'New Community Request',
      body: '$category request submitted.',
    );

    if (!mounted) return;
    setState(() => _submitting = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community Request')),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                initialValue: category,
                items: const [
                  DropdownMenuItem(value: 'Mayaat', child: Text('Mayaat')),
                  DropdownMenuItem(value: 'Marriage', child: Text('Marriage')),
                  DropdownMenuItem(value: 'Cleaning', child: Text('Cleaning')),
                  DropdownMenuItem(value: 'Event', child: Text('Event')),
                ],
                onChanged: (v) => setState(() => category = v!),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: descriptionController,
                minLines: 4,
                maxLines: 6,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter description' : null,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: Text(_submitting ? 'Submitting...' : 'Submit Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}