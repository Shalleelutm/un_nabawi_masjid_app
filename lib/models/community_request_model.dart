class CommunityRequestModel {
  final String id;
  final String userName;
  final String userEmail;

  final String category; // Mayaat, Marriage, Cleaning, Event, etc.
  final DateTime eventDate;

  final int chairs;
  final int tables;
  final int plates;
  final int mats;
  final int expectedGuests;

  final String description;

  final String status; // pending / approved / rejected / handled
  final String adminNote;

  final DateTime createdAt;

  CommunityRequestModel({
    required this.id,
    required this.userName,
    required this.userEmail,
    required this.category,
    required this.eventDate,
    required this.chairs,
    required this.tables,
    required this.plates,
    required this.mats,
    required this.expectedGuests,
    required this.description,
    required this.status,
    required this.adminNote,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userName': userName,
        'userEmail': userEmail,
        'category': category,
        'eventDate': eventDate.toIso8601String(),
        'chairs': chairs,
        'tables': tables,
        'plates': plates,
        'mats': mats,
        'expectedGuests': expectedGuests,
        'description': description,
        'status': status,
        'adminNote': adminNote,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CommunityRequestModel.fromJson(Map<String, dynamic> j) {
    return CommunityRequestModel(
      id: j['id'],
      userName: j['userName'],
      userEmail: j['userEmail'],
      category: j['category'],
      eventDate: DateTime.parse(j['eventDate']),
      chairs: j['chairs'],
      tables: j['tables'],
      plates: j['plates'],
      mats: j['mats'],
      expectedGuests: j['expectedGuests'],
      description: j['description'],
      status: j['status'],
      adminNote: j['adminNote'],
      createdAt: DateTime.parse(j['createdAt']),
    );
  }
}