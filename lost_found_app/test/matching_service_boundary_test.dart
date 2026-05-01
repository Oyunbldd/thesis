import 'package:flutter_test/flutter_test.dart';
import 'package:lost_found_app/models/item_report_model.dart';
import 'package:lost_found_app/services/matching_service.dart';

ItemReportModel _item({String location = 'Library', required DateTime date}) {
  return ItemReportModel(
    id: 'test',
    title: 'Item',
    description: '',
    category: 'Electronics',
    type: 'lost',
    status: 'open',
    imageUrl: '',
    location: location,
    date: date,
    userId: 'user_1',
  );
}

void main() {
  late MatchingService svc;
  final base = DateTime(2024, 6, 1);

  setUp(() => svc = MatchingService());

  // ── Date boundary tests ───────────────────────────────────────────────────

  group('MatchingService date scoring boundaries', () {
    test('same date (0 days apart) gives +2', () {
      final score = svc.scoreItems(
        _item(location: 'A', date: base),
        _item(location: 'B', date: base),
      );
      expect(score, 2);
    });

    test('exactly 7 days apart gives +2', () {
      final score = svc.scoreItems(
        _item(location: 'A', date: base),
        _item(location: 'B', date: base.add(const Duration(days: 7))),
      );
      expect(score, 2);
    });

    test('exactly 8 days apart gives +1 (falls into 8–30 range)', () {
      final score = svc.scoreItems(
        _item(location: 'A', date: base),
        _item(location: 'B', date: base.add(const Duration(days: 8))),
      );
      expect(score, 1);
    });

    test('exactly 30 days apart gives +1', () {
      final score = svc.scoreItems(
        _item(location: 'A', date: base),
        _item(location: 'B', date: base.add(const Duration(days: 30))),
      );
      expect(score, 1);
    });

    test('exactly 31 days apart gives +0', () {
      final score = svc.scoreItems(
        _item(location: 'A', date: base),
        _item(location: 'B', date: base.add(const Duration(days: 31))),
      );
      expect(score, 0);
    });

    test('date diff is absolute — b before a gives same score as a before b', () {
      final scoreForward = svc.scoreItems(
        _item(location: 'A', date: base),
        _item(location: 'A', date: base.add(const Duration(days: 5))),
      );
      final scoreBackward = svc.scoreItems(
        _item(location: 'A', date: base.add(const Duration(days: 5))),
        _item(location: 'A', date: base),
      );
      expect(scoreForward, scoreBackward);
    });
  });

  // ── Location + date combinations ──────────────────────────────────────────

  group('MatchingService combined score', () {
    test('same location + same date = 5 (max score)', () {
      final score = svc.scoreItems(
        _item(location: 'Library', date: base),
        _item(location: 'Library', date: base),
      );
      expect(score, 5);
    });

    test('same location + within 7 days = 5', () {
      final score = svc.scoreItems(
        _item(location: 'Library', date: base),
        _item(location: 'Library', date: base.add(const Duration(days: 3))),
      );
      expect(score, 5);
    });

    test('same location + 8–30 days = 4', () {
      final score = svc.scoreItems(
        _item(location: 'Library', date: base),
        _item(location: 'Library', date: base.add(const Duration(days: 15))),
      );
      expect(score, 4);
    });

    test('same location + more than 30 days = 3', () {
      final score = svc.scoreItems(
        _item(location: 'Library', date: base),
        _item(location: 'Library', date: base.add(const Duration(days: 60))),
      );
      expect(score, 3);
    });

    test('different location + within 7 days = 2', () {
      final score = svc.scoreItems(
        _item(location: 'Library', date: base),
        _item(location: 'Cafeteria', date: base.add(const Duration(days: 2))),
      );
      expect(score, 2);
    });

    test('different location + 8–30 days = 1', () {
      final score = svc.scoreItems(
        _item(location: 'Library', date: base),
        _item(location: 'Cafeteria', date: base.add(const Duration(days: 20))),
      );
      expect(score, 1);
    });

    test('different location + more than 30 days = 0', () {
      final score = svc.scoreItems(
        _item(location: 'Library', date: base),
        _item(location: 'Cafeteria', date: base.add(const Duration(days: 45))),
      );
      expect(score, 0);
    });
  });

  // ── Notification threshold ────────────────────────────────────────────────

  group('MatchingService notification threshold (score >= 2)', () {
    test('score of 0 is below notify threshold', () {
      final score = svc.scoreItems(
        _item(location: 'Library', date: base),
        _item(location: 'Cafeteria', date: base.add(const Duration(days: 45))),
      );
      expect(score < 2, isTrue);
    });

    test('score of 1 is below notify threshold', () {
      final score = svc.scoreItems(
        _item(location: 'Library', date: base),
        _item(location: 'Cafeteria', date: base.add(const Duration(days: 20))),
      );
      expect(score < 2, isTrue);
    });

    test('score of 2 meets notify threshold', () {
      final score = svc.scoreItems(
        _item(location: 'Library', date: base),
        _item(location: 'Cafeteria', date: base.add(const Duration(days: 2))),
      );
      expect(score >= 2, isTrue);
    });

    test('score of 3 meets notify threshold', () {
      final score = svc.scoreItems(
        _item(location: 'Library', date: base),
        _item(location: 'Library', date: base.add(const Duration(days: 45))),
      );
      expect(score >= 2, isTrue);
    });

    test('max score of 5 meets notify threshold', () {
      final score = svc.scoreItems(
        _item(location: 'Library', date: base),
        _item(location: 'Library', date: base),
      );
      expect(score >= 2, isTrue);
    });
  });

  // ── Score is symmetric ────────────────────────────────────────────────────

  group('MatchingService score symmetry', () {
    test('scoreItems(a, b) == scoreItems(b, a) for location match', () {
      final a = _item(location: 'Library', date: base);
      final b = _item(location: 'Library', date: base.add(const Duration(days: 10)));
      expect(svc.scoreItems(a, b), svc.scoreItems(b, a));
    });

    test('scoreItems(a, b) == scoreItems(b, a) for different locations', () {
      final a = _item(location: 'Cafeteria', date: base);
      final b = _item(location: 'Library', date: base.add(const Duration(days: 3)));
      expect(svc.scoreItems(a, b), svc.scoreItems(b, a));
    });
  });
}
