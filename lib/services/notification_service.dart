import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../screens/student/order_detail_screen.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize notifications
  Future<void> initialize(BuildContext context) async {
    // Request permissions for iOS/Android
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted notification permission');
    }

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showForegroundNotification(context, message);
      }
    });

    // Handle notification tap when app is in background but opened
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
       _handleNotificationTap(context, message);
    });

    // Handle notification tap when app is terminated
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(context, initialMessage);
    }
  }

  // Update user's FCM token in Firestore
  Future<void> updateToken(String userId) async {
    try {
      String? token = await _fcm.getToken();
      if (token != null) {
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': token,
        });
        debugPrint("FCM Token updated for user $userId");
      }
    } catch (e) {
      debugPrint("Error updating FCM token: $e");
    }
  }

  void _showForegroundNotification(BuildContext context, RemoteMessage message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message.notification?.title ?? "Order Update",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(message.notification?.body ?? ""),
          ],
        ),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: "View",
          onPressed: () => _handleNotificationTap(context, message),
        ),
      ),
    );
  }

  void _handleNotificationTap(BuildContext context, RemoteMessage message) {
    // Navigate to order details if orderId is present in data
    final orderId = message.data['orderId'];
    if (orderId != null) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => OrderDetailScreen(orderId: orderId),
        ),
      );
    }
  }
}

// Global background handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
}
