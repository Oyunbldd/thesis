import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String toUserId;
  final String title;
  final String body;
  final String newItemId;
  final String newItemType;
  final String matchedItemId;
  final bool read;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.toUserId,
    required this.title,
    required this.body,
    required this.newItemId,
    required this.newItemType,
    required this.matchedItemId,
    required this.read,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      toUserId: data['toUserId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      newItemId: data['newItemId'] as String? ?? '',
      newItemType: data['newItemType'] as String? ?? '',
      matchedItemId: data['matchedItemId'] as String? ?? '',
      read: data['read'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
