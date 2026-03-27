class DuesSettingsModel {
  final int monthlyFeeRegular; // e.g. 75
  final int monthlyFeeElder; // e.g. 50
  final String currency; // e.g. "MUR"
  final DateTime updatedAt;

  const DuesSettingsModel({
    required this.monthlyFeeRegular,
    required this.monthlyFeeElder,
    required this.currency,
    required this.updatedAt,
  });

  factory DuesSettingsModel.defaults() => DuesSettingsModel(
        monthlyFeeRegular: 75,
        monthlyFeeElder: 50,
        currency: 'MUR',
        updatedAt: DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'monthlyFeeRegular': monthlyFeeRegular,
        'monthlyFeeElder': monthlyFeeElder,
        'currency': currency,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory DuesSettingsModel.fromJson(Map<String, dynamic> json) =>
      DuesSettingsModel(
        monthlyFeeRegular: (json['monthlyFeeRegular'] as num?)?.toInt() ?? 75,
        monthlyFeeElder: (json['monthlyFeeElder'] as num?)?.toInt() ?? 50,
        currency: (json['currency'] as String?) ?? 'MUR',
        updatedAt: DateTime.tryParse((json['updatedAt'] ?? '').toString()) ??
            DateTime.now(),
      );

  DuesSettingsModel copyWith({
    int? monthlyFeeRegular,
    int? monthlyFeeElder,
    String? currency,
    DateTime? updatedAt,
  }) =>
      DuesSettingsModel(
        monthlyFeeRegular: monthlyFeeRegular ?? this.monthlyFeeRegular,
        monthlyFeeElder: monthlyFeeElder ?? this.monthlyFeeElder,
        currency: currency ?? this.currency,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}