import 'package:flutter_test/flutter_test.dart';
import 'package:lost_found_app/models/item_report_model.dart';
import 'package:lost_found_app/services/matching_service.dart';

ItemReportModel _makeItem({
  String location = 'Library',
  DateTime? date,
}) {
  return ItemReportModel(
    id: 'test_id',
    title: 'Test Item',
    description: '',
    category: 'Bag',
    type: 'lost',
    status: 'open',
    imageUrl: '',
    location: location,
    date: date ?? DateTime(2024, 1, 15),
    userId: 'user_001',
  );
}

void main() {
  late MatchingService matchingService;

  setUp(() {
    matchingService = MatchingService();
  });

  // ── scoring logic ────────────────────────────────────────────────────────

  group('MatchingService.scoreItems', () {
    test('same location gives +3 score', () {
      // Use dates far apart so only location contributes
      final a = _makeItem(location: 'Library', date: DateTime(2024, 1, 1));
      final b = _makeItem(location: 'Library', date: DateTime(2024, 4, 1));

      final score = matchingService.scoreItems(a, b);

      expect(score, 3);
    });

    test('different location gives +0 for location', () {
      // Use dates far apart so score is 0 from both location and date
      final a = _makeItem(location: 'Library', date: DateTime(2024, 1, 1));
      final b = _makeItem(location: 'Cafeteria', date: DateTime(2024, 4, 1));

      final score = matchingService.scoreItems(a, b);

      expect(score, 0);
    });

    test('date within 7 days gives +2 score', () {
      // Use different locations so only date contributes
      final a = _makeItem(location: 'Library', date: DateTime(2024, 1, 15));
      final b = _makeItem(location: 'Cafeteria', date: DateTime(2024, 1, 20));

      final score = matchingService.scoreItems(a, b);

      expect(score, 2);
    });

    test('date between 8 and 30 days gives +1 score', () {
      // Use different locations so only date contributes
      final a = _makeItem(location: 'Library', date: DateTime(2024, 1, 1));
      final b = _makeItem(location: 'Cafeteria', date: DateTime(2024, 1, 20));

      final score = matchingService.scoreItems(a, b);

      expect(score, 1);
    });

    test('date over 30 days gives +0 score', () {
      // Use different locations so score is 0 from both
      final a = _makeItem(location: 'Library', date: DateTime(2024, 1, 1));
      final b = _makeItem(location: 'Cafeteria', date: DateTime(2024, 3, 1));

      final score = matchingService.scoreItems(a, b);

      expect(score, 0);
    });

    test('same location and date within 7 days gives maximum score of 5', () {
      final a = _makeItem(location: 'Library', date: DateTime(2024, 1, 15));
      final b = _makeItem(location: 'Library', date: DateTime(2024, 1, 17));

      final score = matchingService.scoreItems(a, b);

      expect(score, 5);
    });
  });
}
