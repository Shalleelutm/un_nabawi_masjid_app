class MemberModel {
  final String id;
  final String username;
  final String fullName;
  final String email;
  final String phone;

  final bool isActive;
  final bool isBlocked;

  /// Simple offline membership ledger
  final double balanceDue;
  final bool isPaid;

  /// Demo-only password for offline member portal (Phase 8 will be Firebase Auth)
  final String pin;

  final DateTime createdAt;
  final DateTime updatedAt;

  MemberModel({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.isActive,
    required this.isBlocked,
    required this.balanceDue,
    required this.isPaid,
    required this.pin,
    required this.createdAt,
    required this.updatedAt,
  });

  MemberModel copyWith({
    String? username,
    String? fullName,
    String? email,
    String? phone,
    bool? isActive,
    bool? isBlocked,
    double? balanceDue,
    bool? isPaid,
    String? pin,
    DateTime? updatedAt,
  }) {
    return MemberModel(
      id: id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      isBlocked: isBlocked ?? this.isBlocked,
      balanceDue: balanceDue ?? this.balanceDue,
      isPaid: isPaid ?? this.isPaid,
      pin: pin ?? this.pin,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'username': username,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'isActive': isActive,
        'isBlocked': isBlocked,
        'balanceDue': balanceDue,
        'isPaid': isPaid,
        'pin': pin,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  static MemberModel fromMap(Map<String, dynamic> m) {
    return MemberModel(
      id: (m['id'] ?? '').toString(),
      username: (m['username'] ?? '').toString(),
      fullName: (m['fullName'] ?? '').toString(),
      email: (m['email'] ?? '').toString(),
      phone: (m['phone'] ?? '').toString(),
      isActive: (m['isActive'] ?? true) == true,
      isBlocked: (m['isBlocked'] ?? false) == true,
      balanceDue:
          (m['balanceDue'] is num) ? (m['balanceDue'] as num).toDouble() : 0.0,
      isPaid: (m['isPaid'] ?? false) == true,
      pin: (m['pin'] ?? '0000').toString(),
      createdAt: DateTime.tryParse((m['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      updatedAt: DateTime.tryParse((m['updatedAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}
