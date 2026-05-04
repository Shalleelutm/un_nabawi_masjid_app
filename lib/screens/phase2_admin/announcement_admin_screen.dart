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

            // ✅ FIXED: activeColor → activeThumbColor (deprecated fix)
            SwitchListTile(
              value: _important,
              activeThumbColor: Colors.red,  // ✅ REPLACED activeColor with activeThumbColor
              inactiveThumbColor: Colors.grey,
              onChanged: (v) => setState(() => _important = v),
              title: Text(
                'Important Announcement',
                style: TextStyle(
                  color: _important ? Colors.red : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Send Announcement'),
              onPressed: _loading
                  ? null
                  : () async {

                      try {
                        setState(() => _loading = true);

                        await AnnouncementService.createAnnouncement(
                          title: _titleController.text.trim(),
                          message: _messageController.text.trim(),
                        );

                        if (!mounted) return;

                        _titleController.clear();
                        _messageController.clear();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Broadcast sent to all users'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Something went wrong'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } finally {
                        if (mounted) setState(() => _loading = false);
                      }
                    },
            )
          ],
        ),
      ),
    );
  }
}