import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class TopHeader extends StatelessWidget {
  final String initials;
  final String title;
  final String subtitle;
  final bool showNotificationBadge;
  final VoidCallback? onBellTap;

  const TopHeader({
    super.key,
    required this.initials,
    required this.title,
    required this.subtitle,
    this.showNotificationBadge = true,
    this.onBellTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.headerGradientStart, AppColors.headerGradientEnd],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
            child: Row(
              children: [
                _Avatar(initials: initials),
                const SizedBox(width: 5),
                // Title pill
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),

                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                _Bell(onTap: onBellTap, showBadge: showNotificationBadge),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initials;
  const _Avatar({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.95), width: 2),
        color: Colors.white.withValues(alpha: 0.10),
      ),
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _Bell extends StatelessWidget {
  final VoidCallback? onTap;
  final bool showBadge;

  const _Bell({required this.onTap, required this.showBadge});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 26,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_none, color: Colors.white, size: 30),
          if (showBadge)
            Positioned(
              right: -1,
              top: -1,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
