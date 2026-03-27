import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> registerWithEmail({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    if (credential.user != null) {
      await credential.user!.updateDisplayName(name.trim());
      await credential.user!.reload();
      await _ensureMemberDocument(
        credential.user!,
        name: name.trim(),
        phone: phone?.trim(),
      );
      await credential.user!.sendEmailVerification();
    }

    return credential;
  }

  Future<UserCredential> loginWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'google-sign-in-cancelled',
        message: 'Google sign-in was cancelled.',
      );
    }

    final googleAuth = await googleUser.authentication;

    final authCredential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final credential = await _auth.signInWithCredential(authCredential);

    if (credential.user != null) {
      await _ensureMemberDocument(
        credential.user!,
        name: credential.user!.displayName,
        phone: credential.user!.phoneNumber,
      );
    }

    return credential;
  }

  Future<void> startPhoneVerification({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken)
        codeSentHandler,
    required void Function(PhoneAuthCredential credential)
        verificationCompletedHandler,
    required void Function(FirebaseAuthException e) verificationFailedHandler,
    required void Function(String verificationId) codeAutoRetrievalTimeoutHandler,
    int? forceResendingToken,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber.trim(),
      forceResendingToken: forceResendingToken,
      verificationCompleted: verificationCompletedHandler,
      verificationFailed: verificationFailedHandler,
      codeSent: codeSentHandler,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeoutHandler,
      timeout: const Duration(seconds: 60),
    );
  }

  Future<UserCredential> signInWithPhoneCredential(
    PhoneAuthCredential credential,
  ) async {
    final userCredential = await _auth.signInWithCredential(credential);

    if (userCredential.user != null) {
      await _ensureMemberDocument(
        userCredential.user!,
        name: userCredential.user!.displayName,
        phone: userCredential.user!.phoneNumber,
      );
    }

    return userCredential;
  }

  Future<UserCredential> verifySmsCodeAndSignIn({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode.trim(),
    );
    return signInWithPhoneCredential(credential);
  }

  Future<void> logout() async {
    await _googleSignIn.signOut().catchError((_) => null);
    await _auth.signOut();
  }

  Future<void> sendEmailVerification() async {
    if (_auth.currentUser != null && !_auth.currentUser!.emailVerified) {
      await _auth.currentUser!.sendEmailVerification();
    }
  }

  Future<Map<String, dynamic>?> getMemberProfile(String uid) async {
    final memberDoc = await _db.collection('members').doc(uid).get();
    return memberDoc.data();
  }

  Future<void> updateMemberProfile({
    required String uid,
    required String name,
    required String phone,
  }) async {
    await _db.collection('members').doc(uid).set({
      'name': name.trim(),
      'phone': phone.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (_auth.currentUser != null && name.trim().isNotEmpty) {
      await _auth.currentUser!.updateDisplayName(name.trim());
      await _auth.currentUser!.reload();
    }
  }

  Future<bool> isAdmin(String uid) async {
    final adminDoc = await _db.collection('admins').doc(uid).get();
    if (adminDoc.exists) return true;

    final memberDoc = await _db.collection('members').doc(uid).get();
    final role = memberDoc.data()?['role']?.toString().toLowerCase() ?? '';
    return role == 'admin';
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> announcementsStream() {
    return _db
        .collection('announcements')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> createAnnouncement({
    required String title,
    required String body,
    required bool pinned,
    required String authorUid,
    required String authorName,
  }) async {
    await _db.collection('announcements').add({
      'title': title.trim(),
      'body': body.trim(),
      'pinned': pinned,
      'authorUid': authorUid,
      'authorName': authorName.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateAnnouncement({
    required String id,
    required String title,
    required String body,
    required bool pinned,
  }) async {
    await _db.collection('announcements').doc(id).update({
      'title': title.trim(),
      'body': body.trim(),
      'pinned': pinned,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteAnnouncement(String id) async {
    await _db.collection('announcements').doc(id).delete();
  }

  Future<void> _ensureMemberDocument(
    User user, {
    String? name,
    String? phone,
  }) async {
    final ref = _db.collection('members').doc(user.uid);
    final existing = await ref.get();

    final payload = <String, dynamic>{
      'uid': user.uid,
      'name': (name ?? user.displayName ?? '').trim(),
      'email': (user.email ?? '').trim(),
      'phone': (phone ?? user.phoneNumber ?? '').trim(),
      'photoUrl': user.photoURL ?? '',
      'role': existing.data()?['role'] ?? 'member',
      'emailVerified': user.emailVerified,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (!existing.exists) {
      payload['createdAt'] = FieldValue.serverTimestamp();
    }

    await ref.set(payload, SetOptions(merge: true));
  }
}