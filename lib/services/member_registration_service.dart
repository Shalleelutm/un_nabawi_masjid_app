  import 'package:cloud_firestore/cloud_firestore.dart';

  class MemberRegistrationService {
    MemberRegistrationService._();
    static final instance = MemberRegistrationService._();

    final _db = FirebaseFirestore.instance;

    Future<void> registerMember({
      required String name,
      required String email,
    }) async {
      await _db.collection('members').doc(email).set({
        'name': name,
        'email': email,
        'joined': DateTime.now().toIso8601String(),
      });
    }
  }