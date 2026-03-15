import 'package:flutter/material.dart';

import '../../utils/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/home_header.dart';

const int reportLostTotal = 3;
const int reportFoundTotal = 5;

class CreateReportView extends StatelessWidget {
  const CreateReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: const [
          HomeHeader(),
          Expanded(child: ReportViewBody()),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(
        currentItem: BottomNavItem.report,
      ),
    );
  }
}

class ReportViewBody extends StatelessWidget {
  const ReportViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 20),
      children: const [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _StatsCard(
                title: 'Lost Items',
                count: reportLostTotal,
                subtitle: 'Total reported',
                icon: Icons.error_outline_rounded,
                iconColor: Color(0xFFFF1D1D),
                countColor: Color(0xFFD30909),
                background: LinearGradient(
                  colors: [Color(0xFFFFF2F2), Color(0xFFFFE4E4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _StatsCard(
                title: 'Found Items',
                count: reportFoundTotal,
                subtitle: 'Total reported',
                icon: Icons.inventory_2_outlined,
                iconColor: Color(0xFF0C9F3A),
                countColor: Color(0xFF09863C),
                background: LinearGradient(
                  colors: [Color(0xFFEEFFF3), Color(0xFFE0FAE8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 22),
        _ActionPanel(),
        SizedBox(height: 18),
        _TipsCard(),
        SizedBox(height: 22),
        _RecentReportsCard(),
      ],
    );
  }
}

class _ActionPanel extends StatelessWidget {
  const _ActionPanel();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE9EEF6)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.secondary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What would you like to do?',
                  style: textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFF111318),
                    fontSize: 24,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Choose an option to get started',
                  style: textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF667085),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: AppTheme.border.withValues(alpha: 0.72), height: 1),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: _ReportActionCard(
              title: 'I Lost Something',
              description:
                  'Report a lost item to help others identify and return it',
              icon: Icons.error_outline_rounded,
              iconBackground: Color(0xFFFF0000),
              titleColor: Color(0xFF7F1D1D),
              descriptionColor: Color(0xFFD10909),
              borderColor: Color(0xFFFCC1C1),
              background: LinearGradient(
                colors: [Color(0xFFFFF4F4), Color(0xFFFFE9E9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: _ReportActionCard(
              title: 'I Found Something',
              description:
                  'Report a found item to help reunite it with its owner',
              icon: Icons.inventory_2_outlined,
              iconBackground: Color(0xFF0AA63A),
              titleColor: Color(0xFF14532D),
              descriptionColor: Color(0xFF0B8A36),
              borderColor: Color(0xFFA8EFBE),
              background: LinearGradient(
                colors: [Color(0xFFF1FFF5), Color(0xFFE5FAEB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentReportsCard extends StatelessWidget {
  const _RecentReportsCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE9EEF6)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.secondary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 22, 28, 20),
            child: Text(
              'Your Recent Reports',
              style: textTheme.headlineMedium?.copyWith(
                color: const Color(0xFF111318),
                fontSize: 22,
              ),
            ),
          ),
          Divider(color: AppTheme.border.withValues(alpha: 0.72), height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 34),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      size: 44,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'No reports yet',
                    style: textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF667085),
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Start by reporting an item above',
                    style: textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF98A2B3),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.title,
    required this.count,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.countColor,
    required this.background,
  });

  final String title;
  final int count;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color countColor;
  final Gradient background;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 172,
      padding: const EdgeInsets.fromLTRB(22, 20, 20, 18),
      decoration: BoxDecoration(
        gradient: background,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  title,
                  style: textTheme.titleLarge?.copyWith(
                    color: iconColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '$count',
            style: textTheme.headlineLarge?.copyWith(
              color: countColor,
              fontSize: 44,
              fontWeight: FontWeight.w700,
              height: 0.92,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: textTheme.titleLarge?.copyWith(
              color: countColor,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportActionCard extends StatelessWidget {
  const _ReportActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconBackground,
    required this.titleColor,
    required this.descriptionColor,
    required this.borderColor,
    required this.background,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color iconBackground;
  final Color titleColor;
  final Color descriptionColor;
  final Color borderColor;
  final Gradient background;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        gradient: background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.headlineMedium?.copyWith(
                      color: titleColor,
                      fontSize: 18,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: textTheme.titleLarge?.copyWith(
                      color: descriptionColor,
                      fontSize: 14,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Icon(
              Icons.chevron_right_rounded,
              color: descriptionColor,
              size: 34,
            ),
          ),
        ],
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  const _TipsCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF3F8FF), Color(0xFFEAF2FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD9E6FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFF2563EB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                'Helpful Tips',
                style: textTheme.headlineMedium?.copyWith(
                  color: const Color(0xFF2643A2),
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const _TipLine(text: 'Include clear photos for better visibility'),
          const SizedBox(height: 12),
          const _TipLine(text: 'Provide detailed descriptions and locations'),
          const SizedBox(height: 12),
          const _TipLine(text: 'Double-check your contact information'),
        ],
      ),
    );
  }
}

class _TipLine extends StatelessWidget {
  const _TipLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '\u2022',
          style: TextStyle(
            color: Color(0xFF1D4ED8),
            fontSize: 20,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFF1D4ED8),
              fontSize: 15,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
