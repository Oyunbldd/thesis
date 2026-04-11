import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lost_found_app/models/item_report_model.dart';
import 'package:lost_found_app/models/notification_model.dart';
import 'package:lost_found_app/utils/app_theme.dart';
import 'package:lost_found_app/widgets/item_widgets.dart';

const _categoryColors = <String, (Color, Color)>{
  'Electronics': (Color(0xFF99F6E4), Color(0xFF0F766E)),
  'Accessories': (Color(0xFFEDE9FE), Color(0xFF7C3AED)),
  'Bottles': (Color(0xFFDCFCE7), Color(0xFF15803D)),
  'Documents': (Color(0xFFFEF3C7), Color(0xFFF59E0B)),
  'IDs': (Color(0xFFEDE9FE), Color(0xFF7C3AED)),
  'Keys': (Color(0xFFFEF3C7), Color(0xFFF59E0B)),
  'Books': (Color(0xFFFCE7F3), Color(0xFFDB2777)),
  'Other': (Color(0xFFE0F2FE), Color(0xFF0284C7)),
};

const _categoryIcons = <String, IconData>{
  'Electronics': Icons.devices_rounded,
  'Accessories': Icons.watch_rounded,
  'Bottles': Icons.local_drink_rounded,
  'Documents': Icons.description_rounded,
  'IDs': Icons.badge_rounded,
  'Keys': Icons.key_rounded,
  'Books': Icons.book_rounded,
  'Other': Icons.category_rounded,
};

String _formatDate(DateTime dt) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
}

ItemData _toItemData(ItemReportModel model) {
  final colors =
      _categoryColors[model.category] ??
      (const Color(0xFFE2E8F0), const Color(0xFF64748B));
  return ItemData(
    isLost: model.type == 'lost',
    title: model.title,
    description: model.description,
    location: model.location,
    date: _formatDate(model.date),
    category: model.category,
    contactEmail: model.userId,
    icon: _categoryIcons[model.category] ?? Icons.help_outline_rounded,
    backgroundColor: colors.$1,
    accentColor: colors.$2,
    imageUrl: model.imageUrl,
  );
}

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  Future<void> _markAsRead(String docId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(docId)
        .update({'read': true});
  }

  Future<void> _openMatchedItem(
    BuildContext context,
    NotificationModel n,
  ) async {
    if (!n.read) await _markAsRead(n.id);

    // Determine which collection the new item belongs to
    final collection = n.newItemType == 'found' ? 'found_items' : 'lost_items';

    final doc = await FirebaseFirestore.instance
        .collection(collection)
        .doc(n.newItemId)
        .get();

    if (!doc.exists || !context.mounted) return;

    final item = ItemReportModel.fromFirestore(doc);
    final itemData = _toItemData(item);

    if (!context.mounted) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) =>
            ItemDetailsView(item: itemData, scrollController: scrollController),
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        toolbarHeight: 100,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
        foregroundColor: Colors.white,
      ),
      body: uid.isEmpty
          ? const Center(child: Text('Not logged in'))
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('toUserId', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final notifications = snapshot.data!.docs
              .map((doc) => NotificationModel.fromFirestore(doc))
              .toList();

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final n = notifications[index];
              return GestureDetector(
                onTap: () => _openMatchedItem(context, n),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: n.read ? Colors.white : const Color(0xFFEAF3EB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: n.read
                          ? Colors.transparent
                          : const Color(0xFF5D8A66).withValues(alpha: 0.4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF5D8A66,
                          ).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          n.newItemType == 'found'
                              ? Icons.search
                              : Icons.campaign_outlined,
                          color: const Color(0xFF5D8A66),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    n.title,
                                    style: TextStyle(
                                      fontWeight: n.read
                                          ? FontWeight.w500
                                          : FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                if (!n.read)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF5D8A66),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              n.body,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  _timeAgo(n.createdAt),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const Spacer(),
                                const Text(
                                  'Tap to view item →',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF5D8A66),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
