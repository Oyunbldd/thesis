import 'package:flutter/material.dart';

import '../../controllers/item_controller.dart';
import '../../models/item_report_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/home_header.dart';
import '../../widgets/item_widgets.dart';

const List<String> lostCategories = <String>[
  'All',
  'Electronics',
  'Bags',
  'Keys',
  'Documents',
  'IDs',
  'Books',
  'Other',
];

// Palette for auto-assigning card colours based on category.
const _categoryColors = <String, (Color, Color)>{
  'Electronics': (Color(0xFF1F2937), Color(0xFF111827)),
  'Bags': (Color(0xFFDBEAFE), Color(0xFF1D4ED8)),
  'Keys': (Color(0xFFFEF3C7), Color(0xFFF59E0B)),
  'Documents': (Color(0xFFEDE9FE), Color(0xFF7C3AED)),
  'IDs': (Color(0xFFEDE9FE), Color(0xFF7C3AED)),
  'Books': (Color(0xFFFCE7F3), Color(0xFFDB2777)),
  'Other': (Color(0xFFF0FDF4), Color(0xFF16A34A)),
};

const _categoryIcons = <String, IconData>{
  'Electronics': Icons.devices_rounded,
  'Bags': Icons.backpack_rounded,
  'Keys': Icons.key_rounded,
  'Documents': Icons.description_rounded,
  'IDs': Icons.badge_rounded,
  'Books': Icons.book_rounded,
  'Other': Icons.category_rounded,
};

ItemData _toItemData(ItemReportModel model) {
  final colors = _categoryColors[model.category] ??
      (const Color(0xFFE2E8F0), const Color(0xFF64748B));
  return ItemData(
    isLost: true,
    title: model.title,
    description: model.description,
    location: model.location,
    date: _formatDate(model.date),
    category: model.category,
    contactEmail: model.userEmail,
    userId: model.userId,
    icon: _categoryIcons[model.category] ?? Icons.help_outline_rounded,
    backgroundColor: colors.$1,
    accentColor: colors.$2,
    imageUrl: model.imageUrl,
  );
}

String _formatDate(DateTime dt) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
}

class LostItemsView extends StatefulWidget {
  const LostItemsView({super.key});

  @override
  State<LostItemsView> createState() => _LostItemsViewState();
}

class _LostItemsViewState extends State<LostItemsView> {
  final ItemController _itemController = ItemController();
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = lostCategories.first;
  String _searchQuery = '';

  List<ItemData> _filter(List<ItemReportModel> items) {
    final query = _searchQuery.trim().toLowerCase();
    return items
        .where((item) {
          final matchesCategory =
              _selectedCategory == 'All' || item.category == _selectedCategory;
          final matchesQuery =
              query.isEmpty ||
              item.title.toLowerCase().contains(query) ||
              item.description.toLowerCase().contains(query) ||
              item.location.toLowerCase().contains(query) ||
              item.category.toLowerCase().contains(query);
          return matchesCategory && matchesQuery;
        })
        .map(_toItemData)
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          const HomeHeader(),
          Expanded(
            child: StreamBuilder<List<ItemReportModel>>(
              stream: _itemController.getLostItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Error loading items:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }
                final items = _filter(snapshot.data ?? []);
                return LostItemsBody(
                  searchController: _searchController,
                  searchQuery: _searchQuery,
                  selectedCategory: _selectedCategory,
                  filteredItems: items,
                  onSearchChanged: (value) =>
                      setState(() => _searchQuery = value),
                  onCategorySelected: (category) =>
                      setState(() => _selectedCategory = category),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentItem: BottomNavItem.lost),
    );
  }
}

class LostItemsBody extends StatelessWidget {
  const LostItemsBody({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.selectedCategory,
    required this.filteredItems,
    required this.onSearchChanged,
    required this.onCategorySelected,
  });

  final TextEditingController searchController;
  final String searchQuery;
  final String selectedCategory;
  final List<ItemData> filteredItems;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      children: [
        ItemSearchBar(controller: searchController, onChanged: onSearchChanged),
        const SizedBox(height: 20),
        Row(
          children: [
            Icon(
              Icons.filter_alt_outlined,
              color: AppTheme.textPrimary.withValues(alpha: 0.82),
              size: 26,
            ),
            const SizedBox(width: 10),
            Text(
              'Filter by Category',
              style: textTheme.titleLarge?.copyWith(
                fontSize: 18,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: lostCategories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final category = lostCategories[index];
              return ItemCategoryChip(
                label: category,
                isSelected: category == selectedCategory,
                onTap: () => onCategorySelected(category),
              );
            },
          ),
        ),
        const SizedBox(height: 22),
        if (filteredItems.isEmpty)
          ItemEmptyState(
            selectedCategory: selectedCategory,
            searchQuery: searchQuery,
          ),
        ...filteredItems.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: ItemCard(
              item: item,
              onTap: () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  enableDrag: true,
                  useSafeArea: false,
                  backgroundColor: Colors.transparent,
                  barrierColor: Colors.black.withValues(alpha: 0.38),
                  builder: (_) => DraggableScrollableSheet(
                    expand: false,
                    initialChildSize: 0.93,
                    minChildSize: 0.60,
                    maxChildSize: 0.97,
                    builder: (context, scrollController) => ItemDetailsView(
                      item: item,
                      scrollController: scrollController,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
