// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_routes.dart';
import '../../core/ui_feedback.dart';
import '../../providers/auth_provider.dart';
import '../../services/local_notification_service.dart';
import '../../services/prayer_auto_scheduler_service.dart';
import '../../services/prayer_time_service.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _pendingPrayerNotifications = 0;
  String _nextPrayer = '--';
  String _nextPrayerTime = '--';

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    await PrayerTimeService.instance.loadFromAssets();

    final pending = await LocalNotificationService.instance.pending();
    final now = DateTime.now();
    final nextName = PrayerTimeService.instance.nextPrayerName(now: now) ?? '--';
    final nextDate = PrayerTimeService.instance.nextPrayerDateTime(now: now);

    if (!mounted) return;

    setState(() {
      _pendingPrayerNotifications = pending.length;
      _nextPrayer = nextName;
      _nextPrayerTime = nextDate == null
          ? '--'
          : '${nextDate.hour.toString().padLeft(2, '0')}:${nextDate.minute.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _reschedulePrayerNotifications() async {
    await PrayerAutoSchedulerService.instance.refreshSchedules();
    await _loadSummary();
    if (!mounted) return;
    UIFeedback.successSnack(
      context,
      'Prayer notifications refreshed successfully.',
    );
  }

  Future<void> _logout() async {
    final auth = context.read<AuthProvider>();
    await auth.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (_) => false,
    );
  }

  Future<void> _openEditor({
    String? docId,
    String initialTitle = '',
    String initialBody = '',
    bool initialPinned = false,
  }) async {
    final auth = context.read<AuthProvider>();
    final titleCtrl = TextEditingController(text: initialTitle);
    final bodyCtrl = TextEditingController(text: initialBody);
    bool pinned = initialPinned;
    bool saving = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 18,
                bottom: MediaQuery.of(context).viewInsets.bottom + 18,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFF8F3EC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      docId == null ? 'New Announcement' : 'Edit Announcement',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        prefixIcon: Icon(Icons.title_rounded),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: bodyCtrl,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        labelText: 'Body',
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.edit_note_rounded),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      value: pinned,
                      onChanged: (value) {
                        setSheetState(() => pinned = value);
                      },
                      title: const Text('Pin this announcement'),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: saving
                            ? null
                            : () async {
                                if (titleCtrl.text.trim().isEmpty ||
                                    bodyCtrl.text.trim().isEmpty) {
                                  UIFeedback.errorSnack(
                                    context,
                                    'Title and body are required.',
                                  );
                                  return;
                                }

                                try {
                                  setSheetState(() => saving = true);

                                  final db = FirebaseFirestore.instance;
                                  final authorUid = auth.user?.uid ?? '';
                                  final authorName = auth.displayName;

                                  final payload = {
                                    'title': titleCtrl.text.trim(),
                                    'body': bodyCtrl.text.trim(),
                                    'pinned': pinned,
                                    'authorUid': authorUid,
                                    'authorName': authorName,
                                    'updatedAt': FieldValue.serverTimestamp(),
                                  };

                                  if (docId == null) {
                                    await db.collection('announcements').add({
                                      ...payload,
                                      'createdAt': FieldValue.serverTimestamp(),
                                    });
                                  } else {
                                    await db
                                        .collection('announcements')
                                        .doc(docId)
                                        .set(payload, SetOptions(merge: true));
                                  }

                                  if (!context.mounted) return;
                                  Navigator.pop(context);
                                  UIFeedback.successSnack(
                                    this.context,
                                    docId == null
                                        ? 'Announcement created and saved.'
                                        : 'Announcement updated and saved.',
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;
                                  UIFeedback.errorSnack(
                                    this.context,
                                    'Save failed: $e',
                                  );
                                } finally {
                                  if (context.mounted) {
                                    setSheetState(() => saving = false);
                                  }
                                }
                              },
                        icon: saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.save_rounded),
                        label: Text(saving ? 'Saving...' : 'Save'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteAnnouncement(String id) async {
    await FirebaseFirestore.instance.collection('announcements').doc(id).delete();
    if (!mounted) return;
    UIFeedback.successSnack(context, 'Announcement deleted.');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cs = Theme.of(context).colorScheme;

    if (!auth.isLoggedIn || !auth.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin Dashboard')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Access denied. Login with an admin account.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Masjid Admin'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadSummary,
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Announcement'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: cs.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Admin Control Board',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text('Logged in as: ${auth.displayName}'),
                  const SizedBox(height: 4),
                  Text('Next prayer: $_nextPrayer at $_nextPrayerTime'),
                  const SizedBox(height: 4),
                  Text('Scheduled notifications: $_pendingPrayerNotifications'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _reschedulePrayerNotifications,
                        icon: const Icon(Icons.notifications_active_rounded),
                        label: const Text('Refresh Prayer Alerts'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.prayerTimes);
                        },
                        icon: const Icon(Icons.access_time_rounded),
                        label: const Text('Prayer Timetable'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.settings);
                        },
                        icon: const Icon(Icons.settings_rounded),
                        label: const Text('Settings'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.adminReservations);
                        },
                        icon: const Icon(Icons.fact_check_rounded),
                        label: const Text('Service Requests'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Manage Announcements',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('announcements')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No announcements yet.'),
                  ),
                );
              }

              return Column(
                children: docs.map((doc) {
                  final data = doc.data();
                  final title = data['title']?.toString() ?? '';
                  final body = data['body']?.toString() ?? '';
                  final pinned = data['pinned'] == true;
                  final author = data['authorName']?.toString() ?? 'Admin';

                  String dateText = '';
                  final createdAt = data['createdAt'];
                  if (createdAt is Timestamp) {
                    final dt = createdAt.toDate();
                    dateText =
                        '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: pinned
                        ? Colors.amber.withValues(alpha: 0.12)
                        : cs.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              if (pinned)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    color: Colors.amber.withValues(alpha: 0.25),
                                  ),
                                  child: const Text(
                                    'Pinned',
                                    style: TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(body),
                          const SizedBox(height: 10),
                          Text(
                            'By $author${dateText.isEmpty ? '' : ' • $dateText'}',
                            style: TextStyle(
                              color: Colors.black.withValues(alpha: 0.65),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => _openEditor(
                                  docId: doc.id,
                                  initialTitle: title,
                                  initialBody: body,
                                  initialPinned: pinned,
                                ),
                                icon: const Icon(Icons.edit_rounded),
                                label: const Text('Edit'),
                              ),
                              const SizedBox(width: 10),
                              OutlinedButton.icon(
                                onPressed: () => _deleteAnnouncement(doc.id),
                                icon: const Icon(Icons.delete_rounded),
                                label: const Text('Delete'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}