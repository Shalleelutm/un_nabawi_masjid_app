import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../core/roles.dart';

class AuthProvider extends ChangeNotifier {
  static const String adminEmail1 = 'iqbal.elahee@gmail.com';
  static const String adminEmail2 = 'shalleel.mohamud@umail.utm.ac.mu';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  StreamSubscription<User?>? _sub;

  User? _user;
  Map<String, dynamic>? _profile;
  bool _isAdmin = false;
  bool _isLoading = false;
  bool _loaded = false;
  String? _errorMessage;

  AuthProvider() {
    _listen();
  }

  User? get user => _user;
  Map<String, dynamic>? get profile => _profile;
  bool get isAdmin => _isAdmin;
  bool get isLoading => _isLoading;
  bool get isLoaded => _loaded;
  String? get errorMessage => _errorMessage;

  bool get isLoggedIn => _user != null;

  String get email => _user?.email?.trim() ?? '';

  AppRole get role {
    if (_user == null) return AppRole.visitor;
    return _isAdmin ? AppRole.admin : AppRole.user;
  }

  String? get currentUserEmail => _user?.email;

  String get displayName {
    final fromProfile = _profile?['name']?.toString().trim() ?? '';
    if (fromProfile.isNotEmpty) return fromProfile;

    final fromFirebase = _user?.displayName?.trim() ?? '';
    if (fromFirebase.isNotEmpty) return fromFirebase;

    final mail = _user?.email?.trim() ?? '';
    if (mail.isNotEmpty && mail.contains('@')) {
      return mail.split('@').first;
    }

    return 'Guest';
  }

  void _listen() {
    _sub?.cancel();
    _sub = _auth.authStateChanges().listen((firebaseUser) async {
      _user = firebaseUser;
      _errorMessage = null;

      if (firebaseUser == null) {
        _profile = null;
        _isAdmin = false;
        _loaded = true;
        notifyListeners();
        return;
      }

      await _ensureMemberDocument(firebaseUser);
      await _loadProfile(firebaseUser);
      _loaded = true;
      notifyListeners();
    });
  }

  Future<void> _loadProfile(User firebaseUser) async {
    final doc = await _db.collection('members').doc(firebaseUser.uid).get();
    _profile = doc.data();

    final emailLower = (firebaseUser.email ?? '').trim().toLowerCase();
    final adminDoc = await _db.collection('admins').doc(firebaseUser.uid).get();
    final memberRole =
        (_profile?['role']?.toString().trim().toLowerCase() ?? '');

    _isAdmin = adminDoc.exists ||
        memberRole == 'admin' ||
        emailLower == adminEmail1.toLowerCase() ||
        emailLower == adminEmail2.toLowerCase();
  }

  Future<void> _ensureMemberDocument(
    User firebaseUser, {
    String? name,
    String? phone,
  }) async {
    final ref = _db.collection('members').doc(firebaseUser.uid);
    final snap = await ref.get();

    final existing = snap.data() ?? <String, dynamic>{};

    await ref.set({
      'uid': firebaseUser.uid,
      'name': (name ?? existing['name'] ?? firebaseUser.displayName ?? '')
          .toString()
          .trim(),
      'email': (firebaseUser.email ?? existing['email'] ?? '')
          .toString()
          .trim(),
      'phone': (phone ?? existing['phone'] ?? firebaseUser.phoneNumber ?? '')
          .toString()
          .trim(),
      'photoUrl': (firebaseUser.photoURL ?? existing['photoUrl'] ?? '')
          .toString()
          .trim(),
      'role': (existing['role'] ?? 'member').toString(),
      'emailVerified': firebaseUser.emailVerified,
      'updatedAt': FieldValue.serverTimestamp(),
      if (!snap.exists) 'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<bool> loginEmail({
    required String email,
    required String password,
  }) async {
    try {
      _startLoading();
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await refreshUser();
      _finishLoading();
      return true;
    } on FirebaseAuthException catch (e) {
      _fail(_mapFirebaseError(e));
      return false;
    } catch (e) {
      _fail('Login failed: $e');
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String phone = '',
  }) async {
    try {
      _startLoading();

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        await credential.user!.updateDisplayName(name.trim());
        await credential.user!.reload();
        _user = _auth.currentUser;
        await _ensureMemberDocument(
          _user!,
          name: name.trim(),
          phone: phone.trim(),
        );
      }

      await refreshUser();
      _finishLoading();
      return true;
    } on FirebaseAuthException catch (e) {
      _fail(_mapFirebaseError(e));
      return false;
    } catch (e) {
      _fail('Registration failed: $e');
      return false;
    }
  }

  Future<bool> loginGoogle() async {
    try {
      _startLoading();

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _fail('Google sign-in cancelled.');
        return false;
      }

      final googleAuth = await googleUser.authentication;

      final authCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final credential = await _auth.signInWithCredential(authCredential);

      if (credential.user != null) {
        await _ensureMemberDocument(credential.user!);
      }

      await refreshUser();
      _finishLoading();
      return true;
    } on FirebaseAuthException catch (e) {
      _fail(_mapFirebaseError(e));
      return false;
    } catch (e) {
      _fail('Google login failed: $e');
      return false;
    }
  }

  Future<bool> sendResetEmail(String email) async {
    try {
      _startLoading();
      await _auth.sendPasswordResetEmail(email: email.trim());
      _finishLoading();
      return true;
    } on FirebaseAuthException catch (e) {
      _fail(_mapFirebaseError(e));
      return false;
    } catch (e) {
      _fail('Reset email failed: $e');
      return false;
    }
  }

  Future<void> refreshUser() async {
    final current = _auth.currentUser;
    if (current == null) {
      _user = null;
      _profile = null;
      _isAdmin = false;
      notifyListeners();
      return;
    }

    await current.reload();
    _user = _auth.currentUser;
    if (_user != null) {
      await _ensureMemberDocument(_user!);
      await _loadProfile(_user!);
    }
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      _startLoading();
      await _googleSignIn.signOut().catchError((_) => null);
      await _auth.signOut();
      _user = null;
      _profile = null;
      _isAdmin = false;
      _finishLoading();
    } catch (e) {
      _fail('Logout failed: $e');
    }
  }

  Future<void> loginOffline(String email, String password) async {
    await loginEmail(email: email, password: password);
  }

  Future<void> resendEmailVerification() async {
    if (_auth.currentUser != null && !_auth.currentUser!.emailVerified) {
      await _auth.currentUser!.sendEmailVerification();
      await refreshUser();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _startLoading() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
  }

  void _finishLoading() {
    _isLoading = false;
    notifyListeners();
  }

  void _fail(String message) {
    _isLoading = false;
    _errorMessage = message;
    notifyListeners();
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'This email is already in use.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'network-request-failed':
        return 'Network error. Check your internet.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return e.message ?? 'Authentication error.';
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}