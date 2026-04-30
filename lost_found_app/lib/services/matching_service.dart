import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/item_report_model.dart';

class MatchingService {
  late final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Call this after a new lost or found item is submitted.
  /// It queries the opposite collection for same-category open items,
  /// scores each one, and writes a notification doc for strong matches.
  Future<void> findMatchesAndNotify(ItemReportModel newItem) async {
    // Search the opposite side
    final oppositeCollection = newItem.type == 'found'
        ? 'lost_items'
        : 'found_items';

    final snapshot = await _db
        .collection(oppositeCollection)
        .where('category', isEqualTo: newItem.category)
        .where('status', isEqualTo: 'open')
        .get();

    for (final doc in snapshot.docs) {
      final candidate = ItemReportModel.fromFirestore(doc);

      // Skip if same user (don't notify yourself)
      if (candidate.userId == newItem.userId) continue;

      final score = _score(newItem, candidate);

      // Only notify on meaningful matches (score >= 2)
      if (score >= 2) {
        await _writeNotification(
          toUserId: candidate.userId,
          newItem: newItem,
          matchedItem: candidate,
          score: score,
        );
      }
    }
  }

  /// Scoring:
  ///   +3 same location
  ///   +2 date within 7 days
  ///   +1 date within 30 days
  @visibleForTesting
  int scoreItems(ItemReportModel a, ItemReportModel b) => _score(a, b);

  int _score(ItemReportModel a, ItemReportModel b) {
    int score = 0;

    if (a.location == b.location) score += 3;

    final diffDays = a.date.difference(b.date).inDays.abs();
    if (diffDays <= 7) {
      score += 2;
    } else if (diffDays <= 30) {
      score += 1;
    }

    return score;
  }

  Future<void> _writeNotification({
    required String toUserId,
    required ItemReportModel newItem,
    required ItemReportModel matchedItem,
    required int score,
  }) async {
    final isFoundReport = newItem.type == 'found';

    final title = isFoundReport
        ? '🔍 Someone found a ${newItem.category}!'
        : '📢 Someone is looking for a ${newItem.category}!';

    final body = isFoundReport
        ? 'A ${newItem.category} was found near ${newItem.location}. Could it be the one you lost?'
        : 'A ${newItem.category} was reported lost near ${newItem.location}. Does it match what you found?';

    await _db.collection('notifications').add({
      'toUserId': toUserId,
      'title': title,
      'body': body,
      'newItemId': newItem.id,
      'newItemType': newItem.type,
      'matchedItemId': matchedItem.id,
      'score': score,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
