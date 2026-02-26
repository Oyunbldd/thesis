import 'package:flutter/material.dart';

import '../../shared/widgets/top_header.dart';
import '../../shared/widgets/lf_bottom_nav.dart';

import '../lost/lost_page.dart';
import '../found/found_page.dart';
import '../report/report_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  LfTab tab = LfTab.lost;

  @override
  Widget build(BuildContext context) {
    final pages = <LfTab, Widget>{
      LfTab.lost: const LostPage(),
      LfTab.report: const ReportPage(),
      LfTab.found: const FoundPage(),
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Column(
        children: [
          const TopHeader(
            initials: "JS",
            title: "Lost & Found",
            subtitle: "Campus Portal",
            showNotificationBadge: false,
          ),

          Expanded(child: pages[tab] ?? const SizedBox.shrink()),
        ],
      ),

      bottomNavigationBar: LfBottomNav(
        activeTab: tab,
        onTabSelected: (selectedTab) {
          if (selectedTab == tab) return;
          setState(() => tab = selectedTab);
        },
      ),
    );
  }
}
