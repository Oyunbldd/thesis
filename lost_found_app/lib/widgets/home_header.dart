import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lost_found_app/utils/app_theme.dart';
import 'package:lost_found_app/views/notifications/notifications_view.dart';
import 'package:lost_found_app/views/profile_view.dart/profile_view.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  String _initials(String? email) {
    if (email == null || email.isEmpty) return '?';
    final name = email.split('@').first;
    final parts = name.split('.');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final email = FirebaseAuth.instance.currentUser?.email;
    final initials = _initials(email);

    return Container(
      height: 125,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ProfileView(),
                  ),
                ),
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white24,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Lost & Found",
                    style: textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                  Text(
                    "Campus Portal",
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.78),
                    ),
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const NotificationsView(),
              ),
            ),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .where('toUserId', isEqualTo: FirebaseAuth.instance.currentUser?.uid ?? '')
                  .where('read', isEqualTo: false)
                  .snapshots(),
              builder: (context, snapshot) {
                final unreadCount = snapshot.data?.docs.length ?? 0;
                return Stack(
                  children: [
                    const Icon(
                      Icons.notifications_none,
                      size: 28,
                      color: Colors.white,
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              unreadCount > 9 ? '9+' : '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
