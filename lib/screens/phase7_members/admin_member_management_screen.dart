import 'package:flutter/material.dart';

import '../../services/member_service.dart';
import '../../models/member_model.dart';

class AdminMemberManagementScreen extends StatefulWidget {
  const AdminMemberManagementScreen({super.key});

  @override
  State<AdminMemberManagementScreen> createState() =>
      _AdminMemberManagementScreenState();
}

class _AdminMemberManagementScreenState
    extends State<AdminMemberManagementScreen> {
  bool loading = true;
  List<MemberModel> members = [];

  final _username = TextEditingController();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _pin = TextEditingController(text: '1234');
  final _balance = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _username.dispose();
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _pin.dispose();
    _balance.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    members = await MemberService.list();
    setState(() => loading = false);
  }

  Future<void> _create() async {
    final u = _username.text.trim();
    final n = _name.text.trim();
    if (u.isEmpty || n.isEmpty) return;

    final bal = double.tryParse(_balance.text.trim()) ?? 0.0;

    await MemberService.create(
      username: u,
      fullName: n,
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      pin: _pin.text.trim(),
      initialBalanceDue: bal,
    );

    _username.clear();
    _name.clear();
    _email.clear();
    _phone.clear();
    _pin.text = '1234';
    _balance.text = '0';

    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Member created (offline-first).')),
    );
  }

  Future<void> _togglePaid(MemberModel m) async {
    await MemberService.setPaidStatus(m.id, !m.isPaid);
    await _load();
  }

  Future<void> _toggleBlock(MemberModel m) async {
    await MemberService.setBlocked(m.id, !m.isBlocked);
    await _load();
  }

  Future<void> _setBalance(MemberModel m) async {
    final c = TextEditingController(text: m.balanceDue.toStringAsFixed(0));
    final v = await showDialog<double?>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Set Balance Due (Rs)'),
        content: TextField(
          controller: c,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Amount'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amt = double.tryParse(c.text.trim());
              Navigator.pop(context, amt);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (v == null) return;
    await MemberService.setBalance(m.id, v);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Admin — Members')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  color: cs.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create Member (Offline-first)',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: cs.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _username,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.alternate_email_rounded),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _name,
                          decoration: const InputDecoration(
                            labelText: 'Full name',
                            prefixIcon: Icon(Icons.person_rounded),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _pin,
                                decoration: const InputDecoration(
                                  labelText: 'PIN (demo)',
                                  prefixIcon: Icon(Icons.lock_rounded),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _balance,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Balance due (Rs)',
                                  prefixIcon: Icon(Icons.payments_rounded),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _email,
                          decoration: const InputDecoration(
                            labelText: 'Email (optional)',
                            prefixIcon: Icon(Icons.mail_outline_rounded),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _phone,
                          decoration: const InputDecoration(
                            labelText: 'Phone (optional)',
                            prefixIcon: Icon(Icons.phone_rounded),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.person_add_alt_1_rounded),
                            label: const Text('Create member'),
                            onPressed: _create,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Member list',
                    style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                ...members.map((m) {
                  final badge =
                      m.isBlocked ? 'BLOCKED' : (m.isPaid ? 'PAID' : 'DUE');
                  final badgeColor = m.isBlocked
                      ? Colors.red
                      : (m.isPaid ? Colors.green : Colors.orange);

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: badgeColor.withValues(alpha: 0.14),
                        child: Icon(Icons.person, color: badgeColor),
                      ),
                      title: Text('${m.fullName} (@${m.username})',
                          style: const TextStyle(fontWeight: FontWeight.w900)),
                      subtitle: Text(
                        'Status: $badge • Balance: Rs ${m.balanceDue.toStringAsFixed(0)}',
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (v) async {
                          if (v == 'paid') await _togglePaid(m);
                          if (v == 'block') await _toggleBlock(m);
                          if (v == 'balance') await _setBalance(m);
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'paid',
                            child:
                                Text(m.isPaid ? 'Mark as DUE' : 'Mark as PAID'),
                          ),
                          PopupMenuItem(
                            value: 'block',
                            child: Text(m.isBlocked ? 'Unblock' : 'Block'),
                          ),
                          const PopupMenuItem(
                            value: 'balance',
                            child: Text('Set balance'),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}
