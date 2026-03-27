import 'package:cloud_firestore/cloud_firestore.dart';

class IslamicEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;

  IslamicEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
  });

  factory IslamicEvent.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return IslamicEvent(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
    );
  }
}

class IslamicEventsService {
  IslamicEventsService._();
  static final IslamicEventsService instance = IslamicEventsService._();

  final _collection = FirebaseFirestore.instance.collection('islamic_events');

  Stream<List<IslamicEvent>> streamEvents() {
    return _collection.orderBy('date').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => IslamicEvent.fromDoc(doc)).toList();
    });
  }

  Future<void> addEvent({
    required String title,
    required String description,
    required DateTime date,
  }) async {
    await _collection.add({
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
    });
  }

  Future<void> deleteEvent(String id) async {
    await _collection.doc(id).delete();
  }
}