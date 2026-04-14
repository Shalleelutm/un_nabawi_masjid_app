// ignore_for_file: unused_import, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/kaaba_loader.dart';
import '../../widgets/palestine_gradient_background.dart';
import '../../widgets/wow_text.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: 2, vsync: this);

  final _loginEmail = TextEditingController();
  final _loginPassword = TextEditingController();

  final _registerName = TextEditingController();
  final _registerEmail = TextEditingController();
  final _registerPhone = TextEditingController();
  final _registerPassword = TextEditingController();
  final _registerConfirm = TextEditingController();

  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  bool _loginObscure = true;
  bool _registerObscure = true;
  bool _registerConfirmObscure = true;

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmail.dispose();
    _loginPassword.dispose();
    _registerName.dispose();
    _registerEmail.dispose();
    _registerPhone.dispose();
    _registerPassword.dispose();
    _registerConfirm.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final ok = await auth.loginEmail(
      email: _loginEmail.text.trim(),
      password: _loginPassword.text,
    );

    if (!mounted) return;

    if (ok) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        auth.isAdmin ? AppRoutes.adminHome : AppRoutes.memberHome,
        (_) => false,
      );
    } else {
      _show(auth.errorMessage ?? 'Login failed.');
    }
  }

  Future<void> _doRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      name: _registerName.text.trim(),
      email: _registerEmail.text.trim(),
      password: _registerPassword.text,
      phone: _registerPhone.text.trim(),
    );

    if (!mounted) return;

    if (ok) {
      _show('Account created successfully.');
      Navigator.pushNamedAndRemoveUntil(
        context,
        auth.isAdmin ? AppRoutes.adminHome : AppRoutes.memberHome,
        (_) => false,
      );
    } else {
      _show(auth.errorMessage ?? 'Registration failed.');
    }
  }

  Future<void> _doGoogleLogin() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.loginGoogle();

    if (!mounted) return;

    if (ok) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        auth.isAdmin ? AppRoutes.adminHome : AppRoutes.memberHome,
        (_) => false,
      );
    } else {
      _show(auth.errorMessage ?? 'Google login failed.');
    }
  }

  Future<void> _doResetPassword() async {
    final email = _loginEmail.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _show('Enter your email first, then tap reset password.');
      return;
    }

    final auth = context.read<AuthProvider>();
    final ok = await auth.sendResetEmail(email);

    if (!mounted) return;

    _show(ok ? 'Password reset email sent.' : (auth.errorMessage ?? 'Reset failed.'));
  }

  void _show(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Member Login'),
      ),
      body: PalestineGradientBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      const SizedBox(height: 6),
                      const WowText('Un Nabawi Masjid', size: 28),
                      const SizedBox(height: 8),
                      const Text(
                        'One login screen for both members and admins.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      TabBar(
                        controller: _tabController,
                        tabs: const [
                          Tab(text: 'Login'),
                          Tab(text: 'Register'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildLoginTab(auth),
                            _buildRegisterTab(auth),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginTab(AuthProvider auth) {
    return SingleChildScrollView(
      child: Form(
        key: _loginFormKey,
        child: Column(
          children: [
            TextFormField(
              controller: _loginEmail,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_rounded),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter your email.';
                }
                if (!value.contains('@')) {
                  return 'Enter a valid email.';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _loginPassword,
              obscureText: _loginObscure,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_rounded),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() => _loginObscure = !_loginObscure);
                  },
                  icon: Icon(
                    _loginObscure
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter your password.';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            if (auth.isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: KaabaLoader(
                  size: 72,
                  message: 'Logging in...',
                ),
              )
            else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _doLogin,
                  icon: const Icon(Icons.login_rounded),
                  label: const Text('Login'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _doGoogleLogin,
                  icon: const Icon(Icons.account_circle_rounded),
                  label: const Text('Login with Google'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _doResetPassword,
                child: const Text('Forgot Password?'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterTab(AuthProvider auth) {
    return SingleChildScrollView(
      child: Form(
        key: _registerFormKey,
        child: Column(
          children: [
            TextFormField(
              controller: _registerName,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_rounded),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter your full name.';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _registerEmail,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_rounded),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter your email.';
                }
                if (!value.contains('@')) {
                  return 'Enter a valid email.';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _registerPhone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone_rounded),
                hintText: '+2305XXXXXXX',
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _registerPassword,
              obscureText: _registerObscure,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_rounded),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() => _registerObscure = !_registerObscure);
                  },
                  icon: Icon(
                    _registerObscure
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter a password.';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters.';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _registerConfirm,
              obscureText: _registerConfirmObscure,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                prefixIcon: const Icon(Icons.verified_user_rounded),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _registerConfirmObscure = !_registerConfirmObscure;
                    });
                  },
                  icon: Icon(
                    _registerConfirmObscure
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                  ),
                ),
              ),
              validator: (value) {
                if (value != _registerPassword.text) {
                  return 'Passwords do not match.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            if (auth.isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: KaabaLoader(
                  size: 72,
                  message: 'Creating account...',
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _doRegister,
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  label: const Text('Create Account'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}