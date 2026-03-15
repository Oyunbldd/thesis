import 'package:flutter/material.dart';

enum BottomNavItem { lost, report, found }

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    this.currentItem = BottomNavItem.report,
    this.onItemSelected,
  });

  final BottomNavItem currentItem;
  final ValueChanged<BottomNavItem>? onItemSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.10),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  label: 'Lost',
                  icon: Icons.search_rounded,
                  isSelected: currentItem == BottomNavItem.lost,
                  onTap: () => onItemSelected?.call(BottomNavItem.lost),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _CenterAction(
                  onTap: () => onItemSelected?.call(BottomNavItem.report),
                ),
              ),
              Expanded(
                child: _NavItem(
                  label: 'Found',
                  icon: Icons.inventory_2_rounded,
                  isSelected: currentItem == BottomNavItem.found,
                  onTap: () => onItemSelected?.call(BottomNavItem.found),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color textColor = isSelected
        ? const Color(0xFF2563EB)
        : const Color(0xFF64748B);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: textColor, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterAction extends StatelessWidget {
  const _CenterAction({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF38BDF8), Color(0xFF2563EB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x402563EB),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 34),
      ),
    );
  }
}
