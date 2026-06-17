import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mygate_coepd/services/api_service.dart';

// Background message handler — MUST be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialised by the time this is called.
  // No extra work needed here; FCM shows the notification automatically.
  debugPrint('[FCM-BG] Message received: ${message.messageId}');
}

// ---------------------------------------------------------------------------
// Notification → Route mapping
// ---------------------------------------------------------------------------
const Map<String, String> _typeToRoute = {
  // Visitor
  'visitor_request': '/visitors',
  'visitor_pre_approval': '/visitors',
  'visitor_status': '/visitors',
  // Helpdesk
  'ticket_created': '/services',
  'ticket_assigned': '/services',
  // Billing
  'invoice_generated': '/bills',
  'payment_received': '/bills',
  // Communications
  'notice_created': '/announcements',
  'announcement_created': '/announcements',
  'poll_created': '/community',
  // Amenities
  'amenity_booking_requested': '/amenities',
  'booking_status_updated': '/amenities',
  // Security
  'security_alert': '/security',
  // Default
  'general': '/resident-notifications',
};

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------
class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// The navigator key used by [MaterialApp] — set this in [App] or [main].
  static GlobalKey<NavigatorState>? navigatorKey;

  bool _isInitialized = false;

  // ─── Public API ────────────────────────────────────────────────────────────

  Future<void> init() async {
    if (_isInitialized) return;

    // 1. Request permissions
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('[FCM] Permission denied by user.');
      return;
    }

    // 2. Configure foreground presentation on iOS
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 3. Initialise flutter_local_notifications for Android foreground heads-up
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _localNotifications.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (response) {
        _navigate(response.payload);
      },
    );

    // 4. Create Android notification channel
    const channel = AndroidNotificationChannel(
      'mygate_high_importance',
      'MyGate Notifications',
      description: 'Push notifications for MyGate community events',
      importance: Importance.max,
      playSound: true,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // 5. Wire up handlers
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // 6. Handle terminated state — app launched by tapping a notification
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      // Delay slightly so the Navigator is ready
      await Future.delayed(const Duration(milliseconds: 500));
      _navigate(jsonEncode(initialMessage.data));
    }

    _isInitialized = true;
    debugPrint('[FCM] Initialised successfully.');
  }

  Future<void> registerDeviceToken() async {
    try {
      final token = await _fcm.getToken();
      if (token == null) return;

      debugPrint('[FCM] Token: $token');

      await ApiService().dio.post(
        '/api/notifications/tokens',
        data: {
          'device_token': token,
          'device_type': Platform.isIOS ? 'ios' : 'android',
        },
      );
      debugPrint('[FCM] Token registered with backend.');
    } catch (e) {
      debugPrint('[FCM] Failed to register token: $e');
    }
  }

  Future<void> unregisterDeviceToken() async {
    try {
      final token = await _fcm.getToken();
      if (token == null) return;

      await ApiService().dio.post(
        '/api/notifications/tokens/unregister',
        data: {'device_token': token},
      );
      debugPrint('[FCM] Token unregistered from backend.');
    } catch (e) {
      debugPrint('[FCM] Failed to unregister token: $e');
    }
  }

  // ─── Private handlers ──────────────────────────────────────────────────────

  /// Shows a heads-up notification while the app is in the foreground.
  void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'mygate_high_importance',
          'MyGate Notifications',
          channelDescription: 'Push notifications for MyGate community events',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  /// Called when user taps a notification while the app is in the background.
  void _onMessageOpenedApp(RemoteMessage message) {
    _navigate(jsonEncode(message.data));
  }

  // ─── Navigation ────────────────────────────────────────────────────────────

  /// Navigates to the appropriate route based on the FCM data payload.
  void _navigate(String? payload) {
    if (payload == null || payload.isEmpty) return;

    try {
      final Map<String, dynamic> data = Map<String, dynamic>.from(
        jsonDecode(payload),
      );

      final String? type = data['type'] as String?;
      final String? actionUrl = data['action_url'] as String?;

      // Prefer the explicit action_url from the backend, fall back to type map
      String route = '/resident-notifications';

      if (actionUrl != null && actionUrl.isNotEmpty) {
        route = actionUrl;
      } else if (type != null && _typeToRoute.containsKey(type)) {
        route = _typeToRoute[type]!;
      }

      final nav = navigatorKey?.currentState ?? apiNavigatorKey.currentState;
      if (nav == null) {
        debugPrint('[FCM] Navigator not ready, cannot navigate to $route');
        return;
      }

      debugPrint('[FCM] Navigating to $route (type=$type)');
      nav.pushNamed(route);
    } catch (e) {
      debugPrint('[FCM] Navigation error: $e');
    }
  }
}
