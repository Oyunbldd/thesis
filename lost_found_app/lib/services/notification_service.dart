import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Call this once when the user is logged in
  Future<void> initialize(BuildContext context) async {
    // 1. Request permission (iOS requires explicit permission)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final granted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    if (!granted) return;

    // 2. Save token to Firestore so Cloud Function can reach this device
    await _saveToken();

    // 3. Refresh token automatically if it changes
    _messaging.onTokenRefresh.listen(_saveTokenToFirestore);

    // 4. Handle notifications received while app is open (foreground)
    FirebaseMessaging.onMessage.listen((message) {
      final title = message.notification?.title ?? 'Match found!';
      final body = message.notification?.body ?? '';
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                if (body.isNotEmpty) ...[const SizedBox(height: 4), Text(body)],
              ],
            ),
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  Future<void> _saveToken() async {
    final token = await _messaging.getToken();
    print('FCM TOKEN: $token');
    if (token != null) await _saveTokenToFirestore(token);
  }

  Future<void> _saveTokenToFirestore(String token) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).set({
      'fcmToken': token,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
