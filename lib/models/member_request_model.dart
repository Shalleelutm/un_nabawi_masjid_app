class MemberRequestModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String reason;
  final String status; // pending/approved/rejected
  final DateTime createdAt;

  const MemberRequestModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'reason': reason,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
      };

  factory MemberRequestModel.fromJson(Map<String, dynamic> j) => MemberRequestModel(
        id: (j['id'] ?? '').toString(),
        fullName: (j['fullName'] ?? '').toString(),
        email: (j['email'] ?? '').toString(),
        phone: (j['phone'] ?? '').toString(),
        reason: (j['reason'] ?? '').toString(),
        status: (j['status'] ?? 'pending').toString(),
        createdAt: DateTime.tryParse((j['createdAt'] ?? '').toString()) ?? DateTime.now(),
      );
}