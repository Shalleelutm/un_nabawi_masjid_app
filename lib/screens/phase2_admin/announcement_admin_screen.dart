// ignore_for_file: unused_import, sort_child_properties_last, use_build_context_synchronously

import 'package:flutter/material.dart';


import '../../services/announcement_service.dart';

class AnnouncementAdminScreen extends StatefulWidget {
  const AnnouncementAdminScreen({super.key});

  @override
  State<AnnouncementAdminScreen> createState() =>
      _AnnouncementAdminScreenState();
}

class _AnnouncementAdminScreenState
    extends State<AnnouncementAdminScreen> {

  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  bool _important = false;
  bool _loading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Broadcast')),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [

            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _messageController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Message'),
            ),

            SwitchListTile(
              value: _important,
              onChanged: (v) => setState(() => _important = v),
              title: const Text('Important'),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Send Announcement'),
              onPressed: _loading
                  ? null
                  : () async {

                      setState(() => _loading = true);

                      await AnnouncementService.createAnnouncement(
                        title: _titleController.text.trim(),
                        message: _messageController.text.trim(),
                      );

                      setState(() => _loading = false);

                      _titleController.clear();
                      _messageController.clear();

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Announcement sent')),
                      );
                    },
            )
          ],
        ),
      ),
    );
  }
}