import 'package:flutter/material.dart';

import '../../utils/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/home_header.dart';

class LostItemsView extends StatelessWidget {
  const LostItemsView({super.key});

  static const List<String> _categories = <String>[
    'All',
    'Electronics',
    'Bags',
    'Keys',
    'Documents',
  ];

  static const List<_LostItemData> _sampleItems = <_LostItemData>[
    _LostItemData(
      title: 'Black Wireless Headphones',
      description:
          'Lost my Sony WH-1000XM4 headphones in the Student Center cafeteria area around lunch time.',
      location: 'Student Center',
      date: 'Feb 15, 2026',
      category: 'Electronics',
      icon: Icons.headphones_rounded,
      accentColor: Color(0xFF111827),
      backgroundColor: Color(0xFF1F2937),
    ),
    _LostItemData(
      title: 'Blue Jansport Backpack',
      description:
          'Backpack with lecture notes and a laptop charger. Last seen near the library entrance after class.',
      location: 'Main Library',
      date: 'Feb 13, 2026',
      category: 'Bags',
      icon: Icons.backpack_rounded,
      accentColor: Color(0xFF1D4ED8),
      backgroundColor: Color(0xFFDBEAFE),
    ),
    _LostItemData(
      title: 'Dorm Room Key Set',
      description:
          'Silver keychain with two keys and a red student tag. I may have dropped it near the engineering block.',
      location: 'Engineering Building',
      date: 'Feb 11, 2026',
      category: 'Keys',
      icon: Icons.key_rounded,
      accentColor: Color(0xFFF59E0B),
      backgroundColor: Color(0xFFFEF3C7),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          const HomeHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              children: [
                const _SearchBar(),
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
                    itemCount: _categories.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = index == 1;

                      return _CategoryChip(
                        label: category,
                        isSelected: isSelected,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 22),
                ..._sampleItems.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: _LostItemCard(item: item),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentItem: BottomNavItem.lost),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: 34,
            color: AppTheme.textSecondary.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 14),
          Text(
            'Search items...',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 19,
              color: AppTheme.textSecondary.withValues(alpha: 0.75),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.isSelected});

  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
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
    );
  }
}

class _LostItemCard extends StatelessWidget {
  const _LostItemCard({required this.item});

  final _LostItemData item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
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
                _InfoRow(icon: Icons.location_on_outlined, text: item.location),
                const SizedBox(height: 12),
                _InfoRow(icon: Icons.access_time_outlined, text: item.date),
              ],
            ),
          ),
        ],
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

class _LostItemData {
  const _LostItemData({
    required this.title,
    required this.description,
    required this.location,
    required this.date,
    required this.category,
    required this.icon,
    required this.accentColor,
    required this.backgroundColor,
  });

  final String title;
  final String description;
  final String location;
  final String date;
  final String category;
  final IconData icon;
  final Color accentColor;
  final Color backgroundColor;
}
