enum DuesPaymentStatus { pending, confirmed }

class DuesPaymentModel {
  final String id;
  final String memberId;
  final int amount; // in MUR
  final String monthKey; // "YYYY-MM"
  final DateTime paidAt;
  final String method; // cash, juice, bank, etc.
  final String note;
  final DuesPaymentStatus status;

  const DuesPaymentModel({
    required this.id,
    required this.memberId,
    required this.amount,
    required this.monthKey,
    required this.paidAt,
    required this.method,
    required this.note,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'memberId': memberId,
        'amount': amount,
        'monthKey': monthKey,
        'paidAt': paidAt.toIso8601String(),
        'method': method,
        'note': note,
        'status': status.name,
      };

  factory DuesPaymentModel.fromJson(Map<String, dynamic> json) {
    final st = (json['status'] ?? 'pending').toString();
    final status = DuesPaymentStatus.values
        .where((e) => e.name == st)
        .cast<DuesPaymentStatus?>()
        .firstWhere((e) => e != null,
            orElse: () => DuesPaymentStatus.pending)!;

    return DuesPaymentModel(
      id: (json['id'] ?? '').toString(),
      memberId: (json['memberId'] ?? '').toString(),
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      monthKey: (json['monthKey'] ?? '').toString(),
      paidAt: DateTime.tryParse((json['paidAt'] ?? '').toString()) ??
          DateTime.now(),
      method: (json['method'] ?? 'cash').toString(),
      note: (json['note'] ?? '').toString(),
      status: status,
    );
  }

  DuesPaymentModel copyWith({
    int? amount,
    String? monthKey,
    DateTime? paidAt,
    String? method,
    String? note,
    DuesPaymentStatus? status,
  }) =>
      DuesPaymentModel(
        id: id,
        memberId: memberId,
        amount: amount ?? this.amount,
        monthKey: monthKey ?? this.monthKey,
        paidAt: paidAt ?? this.paidAt,
        method: method ?? this.method,
        note: note ?? this.note,
        status: status ?? this.status,
      );
}