// AI-GENERATED: This entire file was generated using Claude Sonnet 4.6 (Anthropic).
// Tool: Claude Code CLI
// Purpose: Extended test coverage for ItemReportModel (date fallbacks, status defaults, roundtrip serialization)

import 'package:flutter_test/flutter_test.dart';
import 'package:lost_found_app/models/item_report_model.dart';

void main() {
  // AI-GENERATED: fromMap date parsing tests (lines 10–37)
  group('ItemReportModel.fromMap date parsing', () {
    test('parses valid ISO 8601 date string', () { // AI-GENERATED
      final map = {'date': '2024-06-15T12:00:00.000'};
      final model = ItemReportModel.fromMap(map);
      expect(model.date, DateTime(2024, 6, 15, 12, 0, 0));
    });

    test('falls back to a recent DateTime when date is empty string', () { // AI-GENERATED
      final before = DateTime.now();
      final model = ItemReportModel.fromMap({'date': ''});
      final after = DateTime.now();
      expect(model.date.isAfter(before) || model.date.isAtSameMomentAs(before), isTrue);
      expect(model.date.isBefore(after) || model.date.isAtSameMomentAs(after), isTrue);
    });

    test('falls back to a recent DateTime when date is garbage string', () { // AI-GENERATED
      final before = DateTime.now();
      final model = ItemReportModel.fromMap({'date': 'not-a-date'});
      final after = DateTime.now();
      expect(model.date.isAfter(before) || model.date.isAtSameMomentAs(before), isTrue);
      expect(model.date.isBefore(after) || model.date.isAtSameMomentAs(after), isTrue);
    });

    test('falls back when date key is missing', () { // AI-GENERATED
      final before = DateTime.now();
      final model = ItemReportModel.fromMap({});
      final after = DateTime.now();
      expect(model.date.isAfter(before) || model.date.isAtSameMomentAs(before), isTrue);
      expect(model.date.isBefore(after) || model.date.isAtSameMomentAs(after), isTrue);
    });
  });

  // AI-GENERATED: fromMap status default tests (lines 41–56)
  group('ItemReportModel.fromMap status', () {
    test('status defaults to "open" when not provided', () { // AI-GENERATED
      final model = ItemReportModel.fromMap({});
      expect(model.status, 'open');
    });

    test('status is "closed" when explicitly set', () { // AI-GENERATED
      final model = ItemReportModel.fromMap({'status': 'closed'});
      expect(model.status, 'closed');
    });

    test('status is "open" when explicitly set', () { // AI-GENERATED
      final model = ItemReportModel.fromMap({'status': 'open'});
      expect(model.status, 'open');
    });
  });

  // AI-GENERATED: fromMap userEmail default tests (lines 60–70)
  group('ItemReportModel.fromMap userEmail', () {
    test('userEmail defaults to empty string when not provided', () { // AI-GENERATED
      final model = ItemReportModel.fromMap({});
      expect(model.userEmail, '');
    });

    test('userEmail is parsed correctly when provided', () { // AI-GENERATED
      final model = ItemReportModel.fromMap({'userEmail': 'user@inf.elte.hu'});
      expect(model.userEmail, 'user@inf.elte.hu');
    });
  });

  // AI-GENERATED: toMap structure tests (lines 74–113)
  group('ItemReportModel.toMap structure', () {
    test('toMap contains all 11 expected keys', () { // AI-GENERATED
      final model = ItemReportModel(
        id: 'x',
        title: 'x',
        description: 'x',
        category: 'x',
        type: 'lost',
        status: 'open',
        imageUrl: '',
        location: 'x',
        date: DateTime(2024),
        userId: 'u',
      );
      final map = model.toMap();
      const expectedKeys = [
        'id', 'title', 'description', 'category', 'type',
        'status', 'imageUrl', 'location', 'date', 'userId', 'userEmail',
      ];
      for (final key in expectedKeys) {
        expect(map.containsKey(key), isTrue, reason: 'Key "$key" missing from toMap()');
      }
    });

    test('date is stored as ISO 8601 string in toMap', () { // AI-GENERATED
      final date = DateTime(2024, 3, 15, 9, 30);
      final model = ItemReportModel(
        id: 'id',
        title: 't',
        description: 'd',
        category: 'Books',
        type: 'lost',
        status: 'open',
        imageUrl: '',
        location: 'Library',
        date: date,
        userId: 'u',
      );
      expect(model.toMap()['date'], date.toIso8601String());
    });
  });

  // AI-GENERATED: Roundtrip serialization tests (lines 117–169)
  group('ItemReportModel roundtrip', () {
    test('fromMap then toMap then fromMap produces identical field values', () { // AI-GENERATED
      final original = {
        'id': 'rt_001',
        'title': 'Roundtrip Item',
        'description': 'Testing roundtrip serialization',
        'category': 'Electronics',
        'type': 'lost',
        'status': 'open',
        'imageUrl': 'https://example.com/img.jpg',
        'location': 'Cafeteria',
        'date': '2024-09-01T08:00:00.000',
        'userId': 'u_rt',
        'userEmail': 'rt@inf.elte.hu',
      };

      final model1 = ItemReportModel.fromMap(original);
      final map2 = model1.toMap();
      final model2 = ItemReportModel.fromMap(map2);

      expect(model2.id, model1.id);
      expect(model2.title, model1.title);
      expect(model2.description, model1.description);
      expect(model2.category, model1.category);
      expect(model2.type, model1.type);
      expect(model2.status, model1.status);
      expect(model2.imageUrl, model1.imageUrl);
      expect(model2.location, model1.location);
      expect(model2.date, model1.date);
      expect(model2.userId, model1.userId);
      expect(model2.userEmail, model1.userEmail);
    });

    test('toMap output re-parses to same type and status', () { // AI-GENERATED
      final model = ItemReportModel(
        id: 'x',
        title: 'x',
        description: 'x',
        category: 'Keys',
        type: 'found',
        status: 'closed',
        imageUrl: '',
        location: 'Gym',
        date: DateTime(2025, 1, 1),
        userId: 'u2',
        userEmail: 'u2@inf.elte.hu',
      );
      final roundtripped = ItemReportModel.fromMap(model.toMap());
      expect(roundtripped.type, 'found');
      expect(roundtripped.status, 'closed');
    });
  });

  // AI-GENERATED: type/status value preservation tests (lines 173–188)
  group('ItemReportModel type and status values', () {
    test('type "lost" is preserved through fromMap', () { // AI-GENERATED
      final model = ItemReportModel.fromMap({'type': 'lost'});
      expect(model.type, 'lost');
    });

    test('type "found" is preserved through fromMap', () { // AI-GENERATED
      final model = ItemReportModel.fromMap({'type': 'found'});
      expect(model.type, 'found');
    });

    test('status "closed" is preserved through fromMap', () { // AI-GENERATED
      final model = ItemReportModel.fromMap({'status': 'closed'});
      expect(model.status, 'closed');
    });
  });

  // AI-GENERATED: Constructor default and field storage tests (lines 192–237)
  group('ItemReportModel constructor', () {
    test('userEmail has default value of empty string', () { // AI-GENERATED
      final model = ItemReportModel(
        id: 'id',
        title: 'title',
        description: '',
        category: 'Other',
        type: 'lost',
        status: 'open',
        imageUrl: '',
        location: 'Somewhere',
        date: DateTime(2024),
        userId: 'uid',
      );
      expect(model.userEmail, '');
    });

    test('all required fields are stored correctly', () { // AI-GENERATED
      final date = DateTime(2024, 11, 20);
      final model = ItemReportModel(
        id: 'abc',
        title: 'My Phone',
        description: 'Black iPhone',
        category: 'Electronics',
        type: 'lost',
        status: 'open',
        imageUrl: 'https://storage.example.com/img.jpg',
        location: 'Room 101',
        date: date,
        userId: 'user_xyz',
        userEmail: 'xyz@inf.elte.hu',
      );

      expect(model.id, 'abc');
      expect(model.title, 'My Phone');
      expect(model.description, 'Black iPhone');
      expect(model.category, 'Electronics');
      expect(model.type, 'lost');
      expect(model.status, 'open');
      expect(model.imageUrl, 'https://storage.example.com/img.jpg');
      expect(model.location, 'Room 101');
      expect(model.date, date);
      expect(model.userId, 'user_xyz');
      expect(model.userEmail, 'xyz@inf.elte.hu');
    });
  });
}
