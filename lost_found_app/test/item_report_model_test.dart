import 'package:flutter_test/flutter_test.dart';
import 'package:lost_found_app/models/item_report_model.dart';

void main() {
  // ── fromMap ──────────────────────────────────────────────────────────────

  group('ItemReportModel.fromMap', () {
    test('correctly parses all fields from a valid map', () {
      final map = {
        'id': 'item_001',
        'title': 'Blue Backpack',
        'description': 'Found near the library',
        'category': 'Bag',
        'type': 'found',
        'status': 'open',
        'imageUrl': 'https://example.com/image.png',
        'location': 'Library',
        'date': '2024-01-15T10:00:00.000',
        'userId': 'user_001',
        'userEmail': 'student@inf.elte.hu',
      };

      final model = ItemReportModel.fromMap(map);

      expect(model.id, 'item_001');
      expect(model.title, 'Blue Backpack');
      expect(model.description, 'Found near the library');
      expect(model.category, 'Bag');
      expect(model.type, 'found');
      expect(model.status, 'open');
      expect(model.imageUrl, 'https://example.com/image.png');
      expect(model.location, 'Library');
      expect(model.date, DateTime.parse('2024-01-15T10:00:00.000'));
      expect(model.userId, 'user_001');
      expect(model.userEmail, 'student@inf.elte.hu');
    });

    test('falls back to default values when fields are missing', () {
      final model = ItemReportModel.fromMap({});

      expect(model.id, '');
      expect(model.title, '');
      expect(model.description, '');
      expect(model.category, '');
      expect(model.type, '');
      expect(model.status, 'open');
      expect(model.imageUrl, '');
      expect(model.location, '');
      expect(model.userId, '');
      expect(model.userEmail, '');
    });
  });

  // ── toMap ────────────────────────────────────────────────────────────────

  group('ItemReportModel.toMap', () {
    test('serializes all fields to correct map keys and values', () {
      final date = DateTime(2024, 1, 15, 10, 0, 0);
      final model = ItemReportModel(
        id: 'item_001',
        title: 'Blue Backpack',
        description: 'Found near the library',
        category: 'Bag',
        type: 'found',
        status: 'open',
        imageUrl: 'https://example.com/image.png',
        location: 'Library',
        date: date,
        userId: 'user_001',
        userEmail: 'student@inf.elte.hu',
      );

      final map = model.toMap();

      expect(map['id'], 'item_001');
      expect(map['title'], 'Blue Backpack');
      expect(map['description'], 'Found near the library');
      expect(map['category'], 'Bag');
      expect(map['type'], 'found');
      expect(map['status'], 'open');
      expect(map['imageUrl'], 'https://example.com/image.png');
      expect(map['location'], 'Library');
      expect(map['date'], date.toIso8601String());
      expect(map['userId'], 'user_001');
      expect(map['userEmail'], 'student@inf.elte.hu');
    });
  });
}
