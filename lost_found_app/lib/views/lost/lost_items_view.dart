import 'package:flutter/material.dart';

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
];

const List<ItemData> lostSampleItems = <ItemData>[
  ItemData(
    isLost: true,
    title: 'Black Wireless Headphones',
    description:
        'Lost my Sony WH-1000XM4 headphones in the Student Center cafeteria area around lunch time.',
    location: 'Student Center',
    date: 'Feb 15, 2026',
    category: 'Electronics',
    contactEmail: 'john.doe@student.edu',
    icon: Icons.headphones_rounded,
    accentColor: Color(0xFF111827),
    backgroundColor: Color(0xFF1F2937),
  ),
  ItemData(
    isLost: true,
    title: 'Blue Jansport Backpack',
    description:
        'Backpack with lecture notes and a laptop charger. Last seen near the library entrance after class.',
    location: 'Main Library',
    date: 'Feb 13, 2026',
    category: 'Bags',
    contactEmail: 'emma.baker@student.edu',
    icon: Icons.backpack_rounded,
    accentColor: Color(0xFF1D4ED8),
    backgroundColor: Color(0xFFDBEAFE),
  ),
  ItemData(
    isLost: true,
    title: 'Dorm Room Key Set',
    description:
        'Silver keychain with two keys and a red student tag. I may have dropped it near the engineering block.',
    location: 'Engineering Building',
    date: 'Feb 11, 2026',
    category: 'Keys',
    contactEmail: 'liam.cole@student.edu',
    icon: Icons.key_rounded,
    accentColor: Color(0xFFF59E0B),
    backgroundColor: Color(0xFFFEF3C7),
  ),
];

class LostItemsView extends StatefulWidget {
  const LostItemsView({super.key});

  @override
  State<LostItemsView> createState() => _LostItemsViewState();
}

class _LostItemsViewState extends State<LostItemsView> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = lostCategories.first;
  String _searchQuery = '';

  List<ItemData> get _filteredItems {
    final query = _searchQuery.trim().toLowerCase();

    return lostSampleItems.where((item) {
      final matchesCategory =
          _selectedCategory == 'All' || item.category == _selectedCategory;
      final matchesQuery =
          query.isEmpty ||
          item.title.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query) ||
          item.location.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query);

      return matchesCategory && matchesQuery;
    }).toList();
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
            child: LostItemsBody(
              searchController: _searchController,
              searchQuery: _searchQuery,
              selectedCategory: _selectedCategory,
              filteredItems: _filteredItems,
              onSearchChanged: (value) {
                setState(() => _searchQuery = value);
              },
              onCategorySelected: (category) {
                setState(() => _selectedCategory = category);
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
