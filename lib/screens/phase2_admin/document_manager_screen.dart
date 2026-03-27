// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/ui_feedback.dart';

class DocumentManagerScreen extends StatefulWidget {
  const DocumentManagerScreen({super.key});

  @override
  State<DocumentManagerScreen> createState() => _DocumentManagerScreenState();
}

class _DocumentManagerScreenState extends State<DocumentManagerScreen> {
  static const _kKey = 'offline_documents_v1';

  bool _loading = true;
  final List<Map<String, String>> _docs = [];

  final _title = TextEditingController();
  final _path = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _title.dispose();
    _path.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw != null && raw.isNotEmpty) {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      _docs
        ..clear()
        ..addAll(list.map((e) => {
              'title': (e['title'] ?? '').toString(),
              'asset': (e['asset'] ?? '').toString(),
            }));
    }
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKey, jsonEncode(_docs));
  }

  Future<void> _add() async {
    final t = _title.text.trim();
    final p = _path.text.trim();

    if (t.isEmpty || p.isEmpty) {
      UIFeedback.errorSnack(context, 'Enter title + asset path.');
      return;
    }

    _docs.insert(0, {'title': t, 'asset': p});
    await _save();

    _title.clear();
    _path.clear();

    setState(() {});
    UIFeedback.successSnack(context, 'Document added (offline).');
    UIFeedback.showConfetti(context);
  }

  Future<void> _remove(int i) async {
    final removed = _docs.removeAt(i);
    await _save();
    setState(() {});
    UIFeedback.successSnack(context, "Removed: ${removed["title"]}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin — Documents Manager')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '📄 Offline Documents',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Add documents that exist in assets.\nExample asset: assets/prayer_times/membership_form.pdf',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        TextField(
                          controller: _title,
                          decoration: const InputDecoration(
                            labelText: 'Document title',
                            prefixIcon: Icon(Icons.title),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _path,
                          decoration: const InputDecoration(
                            labelText: 'Asset path (inside assets/...)',
                            prefixIcon: Icon(Icons.folder_open),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Add Document'),
                            onPressed: _add,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                if (_docs.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No documents yet.\nAdd membership form, withdrawal form, rules, election notice.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ..._docs.asMap().entries.map((entry) {
                  final i = entry.key;
                  final doc = entry.value;
                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0x220E5E4E),
                        child: Icon(Icons.picture_as_pdf,
                            color: Color(0xFF0E5E4E)),
                      ),
                      title: Text(doc['title'] ?? ''),
                      subtitle: Text(doc['asset'] ?? ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _remove(i),
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}
