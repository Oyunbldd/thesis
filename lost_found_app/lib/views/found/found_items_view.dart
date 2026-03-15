import 'package:flutter/material.dart';

import '../../utils/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/home_header.dart';
import 'found_item_details_view.dart';

const List<String> foundCategories = <String>[
  'All',
  'Electronics',
  'Accessories',
  'Bottles',
  'Documents',
];

const List<FoundItemData> foundSampleItems = <FoundItemData>[
  FoundItemData(
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
  FoundItemData(
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
  FoundItemData(
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

  List<FoundItemData> get _filteredItems {
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
                setState(() {
                  _searchQuery = value;
                });
              },
              onCategorySelected: (category) {
                setState(() {
                  _selectedCategory = category;
                });
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
  final List<FoundItemData> filteredItems;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      children: [
        _SearchBar(controller: searchController, onChanged: onSearchChanged),
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
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final category = foundCategories[index];
              final isSelected = category == selectedCategory;

              return _CategoryChip(
                label: category,
                isSelected: isSelected,
                onTap: () => onCategorySelected(category),
              );
            },
          ),
        ),
        const SizedBox(height: 22),
        if (filteredItems.isEmpty)
          _EmptyState(
            selectedCategory: selectedCategory,
            searchQuery: searchQuery,
          ),
        ...filteredItems.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: _FoundItemCard(
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
                    builder: (context, scrollController) =>
                        FoundItemDetailsView(
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

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: AppTheme.secondary.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontSize: 19,
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Search items...',
          hintStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 19,
            color: AppTheme.textSecondary.withValues(alpha: 0.75),
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 34,
            color: AppTheme.textSecondary.withValues(alpha: 0.7),
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                  icon: const Icon(Icons.close_rounded),
                  color: AppTheme.textSecondary,
                )
              : null,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 20,
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F0FF) : AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? const Color(0xFFC7D8FF) : AppTheme.border,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.selectedCategory,
    required this.searchQuery,
  });

  final String selectedCategory;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final filterText = selectedCategory == 'All'
        ? 'all categories'
        : selectedCategory;
    final queryText = searchQuery.trim().isEmpty
        ? 'without a search term'
        : 'for "${searchQuery.trim()}"';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 40,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: 14),
          Text(
            'No matching items',
            style: textTheme.titleLarge?.copyWith(
              fontSize: 19,
              color: AppTheme.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search or category. Right now we found nothing in $filterText $queryText.',
            style: textTheme.bodyMedium?.copyWith(height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FoundItemCard extends StatelessWidget {
  const _FoundItemCard({required this.item, required this.onTap});

  final FoundItemData item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppTheme.secondary.withValues(alpha: 0.10),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                child: Container(
                  height: 235,
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [item.backgroundColor, item.accentColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _CategoryBadge(label: item.category),
                      const Spacer(),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Icon(
                          item.icon,
                          size: 132,
                          color: Colors.white.withValues(alpha: 0.88),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: textTheme.headlineMedium?.copyWith(
                        fontSize: 24,
                        color: AppTheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      item.description,
                      style: textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        height: 1.45,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _InfoRow(
                      icon: Icons.location_on_outlined,
                      text: item.location,
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(icon: Icons.access_time_outlined, text: item.date),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE5EEFF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppTheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primary, size: 28),
        const SizedBox(width: 12),
        Text(
          text,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 17,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class FoundItemData {
  const FoundItemData({
    required this.title,
    required this.description,
    required this.location,
    required this.date,
    required this.category,
    required this.contactEmail,
    required this.icon,
    required this.accentColor,
    required this.backgroundColor,
  });

  final String title;
  final String description;
  final String location;
  final String date;
  final String category;
  final String contactEmail;
  final IconData icon;
  final Color accentColor;
  final Color backgroundColor;
}
