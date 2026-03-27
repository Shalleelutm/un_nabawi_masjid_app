enum DuesMemberType { regular, elder }

class DuesMemberModel {
  final String id;
  final String fullName;
  final String phone;
  final DuesMemberType type;
  final DateTime joinDate;
  final bool active;

  const DuesMemberModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.type,
    required this.joinDate,
    required this.active,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'phone': phone,
        'type': type.name,
        'joinDate': joinDate.toIso8601String(),
        'active': active,
      };

  factory DuesMemberModel.fromJson(Map<String, dynamic> json) {
    final t = (json['type'] ?? 'regular').toString();
    final type = DuesMemberType.values
        .where((e) => e.name == t)
        .cast<DuesMemberType?>()
        .firstWhere((e) => e != null, orElse: () => DuesMemberType.regular)!;

    return DuesMemberModel(
      id: (json['id'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      type: type,
      joinDate: DateTime.tryParse((json['joinDate'] ?? '').toString()) ??
          DateTime(DateTime.now().year, DateTime.now().month, 1),
      active: (json['active'] as bool?) ?? true,
    );
  }

  DuesMemberModel copyWith({
    String? fullName,
    String? phone,
    DuesMemberType? type,
    DateTime? joinDate,
    bool? active,
  }) =>
      DuesMemberModel(
        id: id,
        fullName: fullName ?? this.fullName,
        phone: phone ?? this.phone,
        type: type ?? this.type,
        joinDate: joinDate ?? this.joinDate,
        active: active ?? this.active,
      );
}