import 'package:flutter/material.dart';
import 'package:lost_found_app/utils/app_theme.dart';
import 'package:lost_found_app/views/found/found_items_view.dart';
import 'package:lost_found_app/views/lost/lost_items_view.dart';
import 'package:lost_found_app/views/report/create_report_view.dart';
import 'package:lost_found_app/widgets/bottom_nav_bar.dart';
import 'package:lost_found_app/widgets/home_header.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
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

  @override
  Widget build(BuildContext context) {
    final lostItems = lostSampleItems.where((item) {
      final query = _lostSearchQuery.trim().toLowerCase();
      final matchesCategory =
          _lostSelectedCategory == 'All' ||
          item.category == _lostSelectedCategory;
      final matchesQuery =
          query.isEmpty ||
          item.title.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query) ||
          item.location.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query);

      return matchesCategory && matchesQuery;
    }).toList();

    final foundItems = foundSampleItems.where((item) {
      final query = _foundSearchQuery.trim().toLowerCase();
      final matchesCategory =
          _foundSelectedCategory == 'All' ||
          item.category == _foundSelectedCategory;
      final matchesQuery =
          query.isEmpty ||
          item.title.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query) ||
          item.location.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query);

      return matchesCategory && matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const HomeHeader(),
          Expanded(
            child: PageView(
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
                  onSearchChanged: (value) {
                    setState(() {
                      _lostSearchQuery = value;
                    });
                  },
                  onCategorySelected: (category) {
                    setState(() {
                      _lostSelectedCategory = category;
                    });
                  },
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
                  onSearchChanged: (value) {
                    setState(() {
                      _foundSearchQuery = value;
                    });
                  },
                  onCategorySelected: (category) {
                    setState(() {
                      _foundSelectedCategory = category;
                    });
                  },
                ),
              ],
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
          setState(() {
            _currentItem = item;
          });
        },
      ),
    );
  }
}
