import 'package:flutter/material.dart';

class CommunityHelpScreen extends StatefulWidget {
  const CommunityHelpScreen({super.key});

  @override
  State<CommunityHelpScreen> createState() => _CommunityHelpScreenState();
}

class _CommunityHelpScreenState extends State<CommunityHelpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _details = TextEditingController();

  bool _submitted = false;

  @override
  void dispose() {
    _title.dispose();
    _details.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitted = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request submitted for admin review.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community Help')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _submitted
            ? const Center(
                child: Text(
                  'Your request has been sent.\nAdmin approval is required.',
                  textAlign: TextAlign.center,
                ),
              )
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _title,
                      decoration: const InputDecoration(
                        labelText: 'Request title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _details,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Details',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter details' : null,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _submit,
                      child: const Text('Send Request'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}