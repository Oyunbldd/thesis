import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

enum LfTab { lost, found, report }

class LfBottomNav extends StatelessWidget {
  final LfTab activeTab;
  final Function(LfTab) onTabSelected;

  const LfBottomNav({
    super.key,
    required this.activeTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85,
      padding: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                label: "Lost",
                icon: Icons.error_outline,
                active: activeTab == LfTab.lost,
                activeColor: AppColors.lostRed,
                onTap: () => onTabSelected(LfTab.lost),
              ),
              const SizedBox(width: 96),
              _NavItem(
                label: "Found",
                icon: Icons.inventory_2_outlined,
                active: activeTab == LfTab.found,
                activeColor: Colors.green,
                onTap: () => onTabSelected(LfTab.found),
              ),
            ],
          ),

          Positioned(
            top: -12,
            child: Column(
              children: [
                _CenterActionButton(
                  onTap: () => onTabSelected(LfTab.report),
                  active: activeTab == LfTab.report,
                ),
                const SizedBox(height: 2),
                const Text(
                  "Report",
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : const Color(0xFF9CA3AF);

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool active;

  const _CenterActionButton({required this.onTap, required this.active});

  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.blueAccent : Colors.white;
    return Material(
      elevation: 1,
      shape: const CircleBorder(),
      shadowColor: Colors.black.withValues(alpha: 0.22),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: const Color(0xFFE5E7EB), width: 3),
          ),
          child: Icon(
            Icons.add,
            size: 24,
            color: active ? Colors.white : Color(0xFF374151),
          ),
        ),
      ),
    );
  }
}
