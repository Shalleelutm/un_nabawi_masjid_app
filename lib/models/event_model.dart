// lib/models/event_model.dart
class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
  });
}
