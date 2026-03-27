import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/reservation_service.dart';

class ReservationProvider extends ChangeNotifier {
  final ReservationService _service = ReservationService.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> get stream =>
      _service.streamRequests();

  Future<void> submit({
    required String userId,
    required String userEmail,
    required String type,
    required String message,
  }) async {
    await _service.submitRequest(
      userId: userId,
      userEmail: userEmail,
      type: type,
      message: message,
    );

    notifyListeners();
  }

  Future<void> markResolved(String id, {String adminReply = ''}) async {
    await _service.updateRequest(
      requestId: id,
      status: 'resolved',
      adminReply: adminReply,
    );

    notifyListeners();
  }

  Future<void> markRejected(String id, {String adminReply = ''}) async {
    await _service.updateRequest(
      requestId: id,
      status: 'rejected',
      adminReply: adminReply,
    );

    notifyListeners();
  }

  Future<void> markInProgress(String id, {String adminReply = ''}) async {
    await _service.updateRequest(
      requestId: id,
      status: 'in_progress',
      adminReply: adminReply,
    );

    notifyListeners();
  }
}