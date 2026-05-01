// AI-GENERATED: This entire file was generated using Claude Sonnet 4.6 (Anthropic).
// Tool: Claude Code CLI
// Purpose: Test coverage for item_category_utils.dart (categories, colors, icons, formatDate, toItemData)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lost_found_app/models/item_report_model.dart';
import 'package:lost_found_app/utils/item_category_utils.dart';
import 'package:lost_found_app/widgets/item_widgets.dart';

void main() {
  // AI-GENERATED: Category list size and content tests (lines 12–48)
  group('lostItemCategories', () {
    test('contains exactly 8 categories', () { // AI-GENERATED
      expect(lostItemCategories.length, 8);
    });

    test('contains all required categories', () { // AI-GENERATED
      expect(lostItemCategories, containsAll([
        'Electronics',
        'Accessories',
        'Books',
        'Clothing',
        'Keys',
        'IDs',
        'Documents',
        'Other',
      ]));
    });

    test('does not contain Bottles', () { // AI-GENERATED
      expect(lostItemCategories, isNot(contains('Bottles')));
    });
  });

  // AI-GENERATED: Found category list tests (lines 35–48)
  group('foundItemCategories', () {
    test('contains exactly 9 categories', () { // AI-GENERATED
      expect(foundItemCategories.length, 9);
    });

    test('contains Bottles (exclusive to found)', () { // AI-GENERATED
      expect(foundItemCategories, contains('Bottles'));
    });

    test('contains every lostItemCategory', () { // AI-GENERATED
      for (final cat in lostItemCategories) {
        expect(foundItemCategories, contains(cat),
            reason: '$cat is in lostItemCategories but not foundItemCategories');
      }
    });
  });

  // AI-GENERATED: Color map coverage tests (lines 52–68)
  group('lostCategoryColors', () {
    test('has an entry for every lost category', () { // AI-GENERATED
      for (final cat in lostItemCategories) {
        expect(lostCategoryColors.containsKey(cat), isTrue,
            reason: 'Missing color entry for lost category: $cat');
      }
    });
  });

  group('foundCategoryColors', () {
    test('has an entry for every found category', () { // AI-GENERATED
      for (final cat in foundItemCategories) {
        expect(foundCategoryColors.containsKey(cat), isTrue,
            reason: 'Missing color entry for found category: $cat');
      }
    });
  });

  // AI-GENERATED: Icon map coverage tests (lines 72–93)
  group('categoryIcons', () {
    test('has an icon for every lost category', () { // AI-GENERATED
      for (final cat in lostItemCategories) {
        expect(categoryIcons.containsKey(cat), isTrue,
            reason: 'Missing icon for category: $cat');
      }
    });

    test('has an icon for every found category', () { // AI-GENERATED
      for (final cat in foundItemCategories) {
        expect(categoryIcons.containsKey(cat), isTrue,
            reason: 'Missing icon for found category: $cat');
      }
    });

    test('all icon values are non-null IconData', () { // AI-GENERATED
      for (final entry in categoryIcons.entries) {
        expect(entry.value, isA<IconData>(),
            reason: 'Icon for ${entry.key} is not an IconData');
      }
    });
  });

  // AI-GENERATED: formatDate function tests (lines 97–127)
  group('formatDate', () {
    test('formats January 1, 2024 correctly', () { // AI-GENERATED
      expect(formatDate(DateTime(2024, 1, 1)), 'Jan 1, 2024');
    });

    test('formats December 31, 2023 correctly', () { // AI-GENERATED
      expect(formatDate(DateTime(2023, 12, 31)), 'Dec 31, 2023');
    });

    test('formats February 5, 2025 correctly', () { // AI-GENERATED
      expect(formatDate(DateTime(2025, 2, 5)), 'Feb 5, 2025');
    });

    test('formats all 12 months with correct abbreviation', () { // AI-GENERATED
      final expected = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      for (var i = 1; i <= 12; i++) {
        final result = formatDate(DateTime(2024, i, 15));
        expect(result.startsWith(expected[i - 1]), isTrue,
            reason: 'Month $i should start with ${expected[i - 1]} but got $result');
      }
    });

    test('includes day and year in output', () { // AI-GENERATED
      final result = formatDate(DateTime(2026, 5, 1));
      expect(result, contains('2026'));
      expect(result, contains('1'));
    });
  });

  // AI-GENERATED: Helper model factory used by toItemData tests (lines 131–149)
  ItemReportModel _makeModel({
    String category = 'Electronics',
    String type = 'lost',
    String imageUrl = '',
  }) {
    return ItemReportModel(
      id: 'id_1',
      title: 'Test Item',
      description: 'A test description',
      category: category,
      type: type,
      status: 'open',
      imageUrl: imageUrl,
      location: 'Library',
      date: DateTime(2024, 6, 15),
      userId: 'user_1',
      userEmail: 'user@inf.elte.hu',
    );
  }

  // AI-GENERATED: toItemData lost item tests (lines 151–207)
  group('toItemData for lost items', () {
    test('isLost is true', () { // AI-GENERATED
      final data = toItemData(_makeModel(type: 'lost'), isLost: true);
      expect(data.isLost, isTrue);
    });

    test('uses lostCategoryColors for Electronics', () { // AI-GENERATED
      final data = toItemData(_makeModel(category: 'Electronics'), isLost: true);
      final expected = lostCategoryColors['Electronics']!;
      expect(data.backgroundColor, expected.$1);
      expect(data.accentColor, expected.$2);
    });

    test('uses lostCategoryColors for Keys', () { // AI-GENERATED
      final data = toItemData(_makeModel(category: 'Keys'), isLost: true);
      final expected = lostCategoryColors['Keys']!;
      expect(data.backgroundColor, expected.$1);
      expect(data.accentColor, expected.$2);
    });

    test('maps title and description correctly', () { // AI-GENERATED
      final model = _makeModel();
      final data = toItemData(model, isLost: true);
      expect(data.title, model.title);
      expect(data.description, model.description);
    });

    test('maps location and formatted date correctly', () { // AI-GENERATED
      final model = _makeModel();
      final data = toItemData(model, isLost: true);
      expect(data.location, model.location);
      expect(data.date, formatDate(model.date));
    });

    test('maps contactEmail and userId correctly', () { // AI-GENERATED
      final model = _makeModel();
      final data = toItemData(model, isLost: true);
      expect(data.contactEmail, model.userEmail);
      expect(data.userId, model.userId);
    });

    test('uses categoryIcons for known category', () { // AI-GENERATED
      final data = toItemData(_makeModel(category: 'Books'), isLost: true);
      expect(data.icon, categoryIcons['Books']);
    });

    test('falls back to help_outline icon for unknown category', () { // AI-GENERATED
      final data = toItemData(_makeModel(category: 'Unicorn'), isLost: true);
      expect(data.icon, Icons.help_outline_rounded);
    });

    test('falls back to grey color pair for unknown category', () { // AI-GENERATED
      final data = toItemData(_makeModel(category: 'Unicorn'), isLost: true);
      expect(data.backgroundColor, const Color(0xFFE2E8F0));
      expect(data.accentColor, const Color(0xFF64748B));
    });
  });

  // AI-GENERATED: toItemData found item tests (lines 209–239)
  group('toItemData for found items', () {
    test('isLost is false', () { // AI-GENERATED
      final data = toItemData(_makeModel(type: 'found'), isLost: false);
      expect(data.isLost, isFalse);
    });

    test('uses foundCategoryColors for Electronics', () { // AI-GENERATED
      final data = toItemData(_makeModel(category: 'Electronics', type: 'found'), isLost: false);
      final expected = foundCategoryColors['Electronics']!;
      expect(data.backgroundColor, expected.$1);
      expect(data.accentColor, expected.$2);
    });

    test('uses foundCategoryColors for Bottles', () { // AI-GENERATED
      final data = toItemData(_makeModel(category: 'Bottles', type: 'found'), isLost: false);
      final expected = foundCategoryColors['Bottles']!;
      expect(data.backgroundColor, expected.$1);
      expect(data.accentColor, expected.$2);
    });

    test('imageUrl is passed through', () { // AI-GENERATED
      final model = _makeModel(imageUrl: 'https://example.com/img.png');
      final data = toItemData(model, isLost: false);
      expect(data.imageUrl, 'https://example.com/img.png');
    });

    test('empty imageUrl is preserved', () { // AI-GENERATED
      final data = toItemData(_makeModel(imageUrl: ''), isLost: false);
      expect(data.imageUrl, '');
    });
  });

  // AI-GENERATED: Return type check (lines 241–246)
  group('toItemData returns ItemData', () {
    test('result is an ItemData instance', () { // AI-GENERATED
      final data = toItemData(_makeModel(), isLost: true);
      expect(data, isA<ItemData>());
    });
  });
}
