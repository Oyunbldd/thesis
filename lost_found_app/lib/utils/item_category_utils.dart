import 'package:flutter/material.dart';

import '../models/item_report_model.dart';
import '../widgets/item_widgets.dart';

//Category lists
const List<String> lostItemCategories = [
  'Electronics',
  'Accessories',
  'Books',
  'Clothing',
  'Keys',
  'IDs',
  'Documents',
  'Other',
];

const List<String> foundItemCategories = [
  'Electronics',
  'Accessories',
  'Books',
  'Clothing',
  'Keys',
  'IDs',
  'Documents',
  'Bottles',
  'Other',
];

// Color maps
const lostCategoryColors = <String, (Color, Color)>{
  'Electronics': (Color(0xFF1F2937), Color(0xFF111827)),
  'Accessories': (Color(0xFFDBEAFE), Color(0xFF1D4ED8)),
  'Books': (Color(0xFFFCE7F3), Color(0xFFDB2777)),
  'Clothing': (Color(0xFFFFF7ED), Color(0xFFEA580C)),
  'Keys': (Color(0xFFFEF3C7), Color(0xFFF59E0B)),
  'IDs': (Color(0xFFEDE9FE), Color(0xFF7C3AED)),
  'Documents': (Color(0xFFEDE9FE), Color(0xFF7C3AED)),
  'Other': (Color(0xFFF0FDF4), Color(0xFF16A34A)),
};

const foundCategoryColors = <String, (Color, Color)>{
  'Electronics': (Color(0xFF99F6E4), Color(0xFF0F766E)),
  'Accessories': (Color(0xFFEDE9FE), Color(0xFF7C3AED)),
  'Books': (Color(0xFFFCE7F3), Color(0xFFDB2777)),
  'Clothing': (Color(0xFFFFF7ED), Color(0xFFEA580C)),
  'Keys': (Color(0xFFFEF3C7), Color(0xFFF59E0B)),
  'IDs': (Color(0xFFEDE9FE), Color(0xFF7C3AED)),
  'Documents': (Color(0xFFFEF3C7), Color(0xFFF59E0B)),
  'Bottles': (Color(0xFFDCFCE7), Color(0xFF15803D)),
  'Other': (Color(0xFFE0F2FE), Color(0xFF0284C7)),
};

// Icon map
const categoryIcons = <String, IconData>{
  'Electronics': Icons.devices_rounded,
  'Accessories': Icons.watch_rounded,
  'Books': Icons.book_rounded,
  'Clothing': Icons.checkroom_rounded,
  'Keys': Icons.key_rounded,
  'IDs': Icons.badge_rounded,
  'Documents': Icons.description_rounded,
  'Bottles': Icons.local_drink_rounded,
  'Other': Icons.category_rounded,
};

// Helpers
String formatDate(DateTime dt) {
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

ItemData toItemData(ItemReportModel model, {required bool isLost}) {
  final colorMap = isLost ? lostCategoryColors : foundCategoryColors;
  final colors =
      colorMap[model.category] ??
      (const Color(0xFFE2E8F0), const Color(0xFF64748B));
  return ItemData(
    isLost: isLost,
    title: model.title,
    description: model.description,
    location: model.location,
    date: formatDate(model.date),
    category: model.category,
    contactEmail: model.userEmail,
    userId: model.userId,
    icon: categoryIcons[model.category] ?? Icons.help_outline_rounded,
    backgroundColor: colors.$1,
    accentColor: colors.$2,
    imageUrl: model.imageUrl,
  );
}
