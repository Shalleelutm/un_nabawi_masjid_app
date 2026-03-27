import 'package:flutter/material.dart';

class NotificationRouter {
  static void handle(BuildContext context, String? payload) {
    if (payload == null || payload.trim().isEmpty) return;

    switch (payload) {
      case 'announcements':
        Navigator.pushNamed(context, '/announcements');
        return;

      case 'prayer_times':
        Navigator.pushNamed(context, '/prayer_times');
        return;

      case 'documents':
        Navigator.pushNamed(context, '/library');
        return;

      case 'reservations':
        Navigator.pushNamed(context, '/reservation_form');
        return;

      default:
        Navigator.pushNamed(context, '/');
    }
  }
}
