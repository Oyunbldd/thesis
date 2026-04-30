import 'package:flutter/material.dart';

import '../../controllers/item_controller.dart';
import '../../models/item_report_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/item_category_utils.dart';
import '../../views/found/found_items_view.dart';
import '../../views/lost/lost_items_view.dart';
import '../../views/report/create_report_view.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/home_header.dart';
import '../../widgets/item_widgets.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ItemController _itemController = ItemController();

  BottomNavItem _currentItem = BottomNavItem.lost;
  late final PageController _pageController;

  late final TextEditingController _lostSearchController;
  late final TextEditingController _foundSearchController;

  String _lostSearchQuery = '';
  String _foundSearchQuery = '';
  String _lostSelectedCategory = 'All';
  String _foundSelectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _lostSearchController = TextEditingController();
    _foundSearchController = TextEditingController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _lostSearchController.dispose();
    _foundSearchController.dispose();
    super.dispose();
  }

  List<ItemData> _filterLost(List<ItemReportModel> items) {
    final query = _lostSearchQuery.trim().toLowerCase();
    return items
        .where((item) {
          final matchesCategory = _lostSelectedCategory == 'All' ||
              item.category == _lostSelectedCategory;
          final matchesQuery = query.isEmpty ||
              item.title.toLowerCase().contains(query) ||
              item.description.toLowerCase().contains(query) ||
              item.location.toLowerCase().contains(query) ||
              item.category.toLowerCase().contains(query);
          return matchesCategory && matchesQuery;
        })
        .map((m) => toItemData(m, isLost: true))
        .toList();
  }

  List<ItemData> _filterFound(List<ItemReportModel> items) {
    final query = _foundSearchQuery.trim().toLowerCase();
    return items
        .where((item) {
          final matchesCategory = _foundSelectedCategory == 'All' ||
              item.category == _foundSelectedCategory;
          final matchesQuery = query.isEmpty ||
              item.title.toLowerCase().contains(query) ||
              item.description.toLowerCase().contains(query) ||
              item.location.toLowerCase().contains(query) ||
              item.category.toLowerCase().contains(query);
          return matchesCategory && matchesQuery;
        })
        .map((m) => toItemData(m, isLost: false))
        .toList();
  }

  int get _currentIndex => switch (_currentItem) {
        BottomNavItem.lost => 0,
        BottomNavItem.report => 1,
        BottomNavItem.found => 2,
      };

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
    setState(() {
      _currentItem = switch (index) {
        0 => BottomNavItem.lost,
        1 => BottomNavItem.report,
        _ => BottomNavItem.found,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const HomeHeader(),
          _SwipeTabBar(
            selectedIndex: _currentIndex,
            onTabSelected: _goToPage,
          ),
          Expanded(
            child: StreamBuilder<List<ItemReportModel>>(
              stream: _itemController.getLostItems(),
              builder: (context, lostSnap) {
                return StreamBuilder<List<ItemReportModel>>(
                  stream: _itemController.getFoundItems(),
                  builder: (context, foundSnap) {
                    final lostItems = _filterLost(lostSnap.data ?? []);
                    final foundItems = _filterFound(foundSnap.data ?? []);

                    return PageView(
                      controller: _pageController,
                      onPageChanged: (index) => setState(() {
                        _currentItem = switch (index) {
                          0 => BottomNavItem.lost,
                          1 => BottomNavItem.report,
                          _ => BottomNavItem.found,
                        };
                      }),
                      children: [
                        LostItemsBody(
                          key: const PageStorageKey<String>('lost-items-body'),
                          searchController: _lostSearchController,
                          searchQuery: _lostSearchQuery,
                          selectedCategory: _lostSelectedCategory,
                          filteredItems: lostItems,
                          onSearchChanged: (value) =>
                              setState(() => _lostSearchQuery = value),
                          onCategorySelected: (category) =>
                              setState(() => _lostSelectedCategory = category),
                        ),
                        const ReportViewBody(
                          key: PageStorageKey<String>('report-view-body'),
                        ),
                        FoundItemsBody(
                          key: const PageStorageKey<String>('found-items-body'),
                          searchController: _foundSearchController,
                          searchQuery: _foundSearchQuery,
                          selectedCategory: _foundSelectedCategory,
                          filteredItems: foundItems,
                          onSearchChanged: (value) =>
                              setState(() => _foundSearchQuery = value),
                          onCategorySelected: (category) =>
                              setState(() => _foundSelectedCategory = category),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentItem: _currentItem,
        onItemSelected: (item) => _goToPage(switch (item) {
          BottomNavItem.lost => 0,
          BottomNavItem.report => 1,
          BottomNavItem.found => 2,
        }),
      ),
    );
  }
}

// ── Swipe tab bar ─────────────────────────────────────────────────────────────

class _SwipeTabBar extends StatelessWidget {
  const _SwipeTabBar({
    required this.selectedIndex,
    required this.onTabSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  static const _tabs = [
    (label: 'Lost', icon: Icons.search_off_rounded),
    (label: 'Report', icon: Icons.add_circle_outline_rounded),
    (label: 'Found', icon: Icons.inventory_2_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F4F8),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final tab = _tabs[index];
            final isSelected = index == selectedIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTabSelected(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        tab.icon,
                        size: 16,
                        color: isSelected
                            ? AppTheme.primary
                            : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        tab.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? AppTheme.primary
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

