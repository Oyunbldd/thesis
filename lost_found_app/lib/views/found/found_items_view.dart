import 'package:flutter/material.dart';

import '../../utils/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/home_header.dart';
import '../../widgets/item_widgets.dart';

const List<String> foundCategories = <String>[
  'All',
  'Electronics',
  'Accessories',
  'Bottles',
  'Documents',
];

const List<ItemData> foundSampleItems = <ItemData>[
  ItemData(
    isLost: false,
    title: 'White AirPods Case',
    description:
        'Found near the second floor study lounge. The case was closed and placed at the front desk for safekeeping.',
    location: 'Main Library',
    date: 'Feb 16, 2026',
    category: 'Electronics',
    contactEmail: 'security.office@student.edu',
    icon: Icons.headphones_rounded,
    accentColor: Color(0xFF0F766E),
    backgroundColor: Color(0xFF99F6E4),
  ),
  ItemData(
    isLost: false,
    title: 'Green Water Bottle',
    description:
        'Reusable bottle found beside the gym entrance after the evening session. It has a small campus sticker on it.',
    location: 'Sports Center',
    date: 'Feb 14, 2026',
    category: 'Bottles',
    contactEmail: 'maria.kiss@student.edu',
    icon: Icons.local_drink_rounded,
    accentColor: Color(0xFF15803D),
    backgroundColor: Color(0xFFDCFCE7),
  ),
  ItemData(
    isLost: false,
    title: 'Student ID Card Holder',
    description:
        'Transparent card holder with student ID and transport pass found outside the engineering labs.',
    location: 'Engineering Building',
    date: 'Feb 12, 2026',
    category: 'Documents',
    contactEmail: 'reception@inf.elte.hu',
    icon: Icons.badge_rounded,
    accentColor: Color(0xFF7C3AED),
    backgroundColor: Color(0xFFEDE9FE),
  ),
];

class FoundItemsView extends StatefulWidget {
  const FoundItemsView({super.key});

  @override
  State<FoundItemsView> createState() => _FoundItemsViewState();
}

class _FoundItemsViewState extends State<FoundItemsView> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = foundCategories.first;
  String _searchQuery = '';

  List<ItemData> get _filteredItems {
    final query = _searchQuery.trim().toLowerCase();

    return foundSampleItems.where((item) {
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
            child: FoundItemsBody(
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
      bottomNavigationBar: const BottomNavBar(currentItem: BottomNavItem.found),
    );
  }
}

class FoundItemsBody extends StatelessWidget {
  const FoundItemsBody({
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
            itemCount: foundCategories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final category = foundCategories[index];
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
