class Achievement {
  final String id;
  final String title;
  final String description;
  final int xp;
  final bool unlocked;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.xp,
    this.unlocked = false,
  });

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    int? xp,
    bool? unlocked,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      xp: xp ?? this.xp,
      unlocked: unlocked ?? this.unlocked,
    );
  }
}