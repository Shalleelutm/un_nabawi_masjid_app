// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/ui_feedback.dart';
import '../../core/app_routes.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();

  bool _loading = false;
  bool _showPass = false;

  // ✅ Admin account fixed (as per your requirement)
  static const String _adminEmail = 'iqbal.elahee@gmail.com';
  static const String _kAdminLoggedIn = 'admin_logged_in';

  @override
  void initState() {
    super.initState();
    _autoRedirectIfLoggedIn();
  }

  Future<void> _autoRedirectIfLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final ok = prefs.getBool(_kAdminLoggedIn) ?? false;
    if (!ok) return;

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.adminHome);
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _email.text.trim().toLowerCase();
    final pass = _pass.text;

    if (email.isEmpty || pass.isEmpty) {
      UIFeedback.errorSnack(context, 'Please enter email and password.');
      return;
    }

    setState(() => _loading = true);

    // Demo delay (later Firebase Auth for real)
    await Future.delayed(const Duration(milliseconds: 600));

    if (email != _adminEmail) {
      setState(() => _loading = false);
      UIFeedback.errorSnack(
        context,
        'Access denied. Only Iqbal can login as admin.',
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAdminLoggedIn, true);

    setState(() => _loading = false);

    UIFeedback.successSnack(context, 'Welcome Admin Iqbal.');
    UIFeedback.showConfetti(context);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.adminHome);
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF0E5E4E);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 18,
                  color: Color(0x22000000),
                  offset: Offset(0, 8),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.admin_panel_settings,
                    size: 54, color: primaryGreen),
                const SizedBox(height: 10),
                const Text(
                  'Un Nabawi Masjid',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Admin Email',
                    prefixIcon: Icon(Icons.mail_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _pass,
                  obscureText: !_showPass,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _showPass ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _showPass = !_showPass),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.login),
                    label: Text(_loading ? 'Signing in...' : 'Login'),
                    onPressed: _loading ? null : _login,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Admin account: iqbal.elahee@gmail.com',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
