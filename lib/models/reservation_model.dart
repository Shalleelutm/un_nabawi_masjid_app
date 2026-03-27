enum ReservationStatus { pending, approved, rejected }

class Reservation {
  final String id;
  final String userEmail;
  final String type;
  final DateTime date;
  final String time;
  final int quantity;
  final ReservationStatus status;

  const Reservation({
    required this.id,
    required this.userEmail,
    required this.type,
    required this.date,
    required this.time,
    required this.quantity,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'userEmail': userEmail,
      'type': type,
      'date': date.toIso8601String(),
      'time': time,
      'quantity': quantity,
      'status': status.name,
    };
  }

  factory Reservation.fromMap(String id, Map<String, dynamic> map) {
    return Reservation(
      id: id,
      userEmail: map['userEmail'] ?? '',
      type: map['type'] ?? '',
      date: DateTime.parse(map['date']),
      time: map['time'] ?? '',
      quantity: map['quantity'] ?? 1,
      status: ReservationStatus.values.firstWhere(
        (e) => e.name == (map['status'] ?? 'pending'),
        orElse: () => ReservationStatus.pending,
      ),
    );
  }
}