import 'package:flutter/material.dart';

import '../../controllers/item_controller.dart';
import '../../models/item_report_model.dart';
import '../../utils/app_theme.dart';
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
        .map((m) => _toItemData(m, isLost: true))
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
        .map((m) => _toItemData(m, isLost: false))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const HomeHeader(),
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
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (index) {
                        setState(() {
                          _currentItem = switch (index) {
                            0 => BottomNavItem.lost,
                            1 => BottomNavItem.report,
                            _ => BottomNavItem.found,
                          };
                        });
                      },
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
        onItemSelected: (item) {
          final targetPage = switch (item) {
            BottomNavItem.lost => 0,
            BottomNavItem.report => 1,
            BottomNavItem.found => 2,
          };
          _pageController.animateToPage(
            targetPage,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
          );
          setState(() => _currentItem = item);
        },
      ),
    );
  }
}

// Shared colour/icon maps used by both HomeView and the standalone list views.
const _lostCategoryColors = <String, (Color, Color)>{
  'Electronics': (Color(0xFF1F2937), Color(0xFF111827)),
  'Bags': (Color(0xFFDBEAFE), Color(0xFF1D4ED8)),
  'Keys': (Color(0xFFFEF3C7), Color(0xFFF59E0B)),
  'Documents': (Color(0xFFEDE9FE), Color(0xFF7C3AED)),
  'IDs': (Color(0xFFEDE9FE), Color(0xFF7C3AED)),
  'Books': (Color(0xFFFCE7F3), Color(0xFFDB2777)),
  'Other': (Color(0xFFF0FDF4), Color(0xFF16A34A)),
};

const _foundCategoryColors = <String, (Color, Color)>{
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
  'Bags': Icons.backpack_rounded,
  'Accessories': Icons.watch_rounded,
  'Bottles': Icons.local_drink_rounded,
  'Keys': Icons.key_rounded,
  'Documents': Icons.description_rounded,
  'IDs': Icons.badge_rounded,
  'Books': Icons.book_rounded,
  'Other': Icons.category_rounded,
};

ItemData _toItemData(ItemReportModel model, {required bool isLost}) {
  final colorMap = isLost ? _lostCategoryColors : _foundCategoryColors;
  final colors = colorMap[model.category] ??
      (const Color(0xFFE2E8F0), const Color(0xFF64748B));
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final dt = model.date;
  final dateStr = '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  return ItemData(
    isLost: isLost,
    title: model.title,
    description: model.description,
    location: model.location,
    date: dateStr,
    category: model.category,
    contactEmail: model.userEmail,
    userId: model.userId,
    icon: _categoryIcons[model.category] ?? Icons.help_outline_rounded,
    backgroundColor: colors.$1,
    accentColor: colors.$2,
    imageUrl: model.imageUrl,
  );
}
