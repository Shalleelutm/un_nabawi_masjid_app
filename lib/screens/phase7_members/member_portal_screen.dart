import 'package:flutter/material.dart';

import '../../services/member_service.dart';
import '../../models/member_model.dart';

class MemberPortalScreen extends StatefulWidget {
  const MemberPortalScreen({super.key});

  @override
  State<MemberPortalScreen> createState() => _MemberPortalScreenState();
}

class _MemberPortalScreenState extends State<MemberPortalScreen> {
  final _user = TextEditingController();
  final _pin = TextEditingController();

  bool loading = false;
  MemberModel? member;

  @override
  void dispose() {
    _user.dispose();
    _pin.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      loading = true;
      member = null;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    final m = await MemberService.login(_user.text, _pin.text);

    setState(() {
      loading = false;
      member = m;
    });

    if (!mounted) return;

    if (m == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Login failed (wrong username/PIN or blocked).')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Member Portal')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: cs.tertiaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.badge_rounded, size: 34),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Check your membership status\n(Offline-first — Phase 8 will be real login).',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: cs.onTertiaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _user,
            decoration: const InputDecoration(
              labelText: 'Username',
              prefixIcon: Icon(Icons.alternate_email_rounded),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _pin,
            decoration: const InputDecoration(
              labelText: 'PIN',
              prefixIcon: Icon(Icons.lock_rounded),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.login_rounded),
              label: Text(loading ? 'Checking...' : 'Login'),
              onPressed: loading ? null : _login,
            ),
          ),
          const SizedBox(height: 12),
          if (member != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${member!.fullName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _kv('Username', '@${member!.username}'),
                    _kv('Status', member!.isBlocked ? 'BLOCKED' : 'ACTIVE'),
                    _kv('Paid', member!.isPaid ? 'YES' : 'NO'),
                    _kv('Balance due',
                        'Rs ${member!.balanceDue.toStringAsFixed(0)}'),
                    const SizedBox(height: 10),
                    Text(
                      member!.isPaid
                          ? '✅ JazakAllahu khairan — your membership is up to date.'
                          : '⚠️ Please contact the Masjid office to clear your balance.',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(child: Text(k)),
          Text(v, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
