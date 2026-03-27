import 'package:flutter/material.dart';

class ReservationStatusScreen extends StatelessWidget {
  const ReservationStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reservation Status')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Reservation status is handled in ReservationApproval + user screens.\nThis placeholder will become a rich tracker in Firebase phase.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}