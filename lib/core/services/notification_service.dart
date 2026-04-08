import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../network/supabase_initializer.dart';

/// Handles Firebase Cloud Messaging initialization, token management,
/// and foreground/background notification display.
///
/// Token is stored in Supabase `device_tokens` table via the
/// `upsert_device_token` RPC so the CRM can read it for push delivery.
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log('NotificationService | background message: ${message.notification?.title}');
}

abstract class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'lavacash_high_importance',
    'LavaCash Notificações',
    description: 'Alertas e avisos do LavaCash.',
    importance: Importance.high,
  );

  static Future<void> initialize() async {
    await Firebase.initializeApp();

    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

    await _setupLocalNotifications();
    await _requestPermission();
    _listenForeground();

    log('NotificationService | inicializado');
  }

  /// Call after auth + empresa loaded to register the FCM token.
  static Future<void> saveToken({
    required String deviceId,
  }) async {
    try {
      final String? token = await FirebaseMessaging.instance.getToken();
      if (token == null) {
        log('NotificationService | token FCM nulo');
        return;
      }
      log('NotificationService | token=${token.substring(0, 20)}...');
      await _persistToken(deviceId: deviceId, token: token);

      FirebaseMessaging.instance.onTokenRefresh.listen((String newToken) async {
        log('NotificationService | token atualizado');
        await _persistToken(deviceId: deviceId, token: newToken);
      });
    } on Exception catch (e) {
      log('NotificationService | erro ao salvar token: $e');
    }
  }

  static Future<void> _persistToken({
    required String deviceId,
    required String token,
  }) async {
    final client = SupabaseInitializer.clientOrNull;
    if (client == null) return;
    try {
      await client.rpc(
        'upsert_device_token',
        params: <String, dynamic>{
          'p_device_id': deviceId,
          'p_fcm_token': token,
          'p_platform': defaultTargetPlatform == TargetPlatform.iOS
              ? 'ios'
              : 'android',
        },
      );
      log('NotificationService | token salvo no Supabase');
    } on Exception catch (e) {
      log('NotificationService | erro ao persistir token: $e');
    }
  }

  static Future<void> _requestPermission() async {
    final NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    log(
      'NotificationService | permissão: ${settings.authorizationStatus}',
    );
  }

  static Future<void> _setupLocalNotifications() async {
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    const InitializationSettings initSettings = InitializationSettings(
      android: AndroidInitializationSettings('ic_stat_notify'),
    );
    await _localNotifications.initialize(initSettings);
  }

  static void _listenForeground() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final RemoteNotification? notification = message.notification;
      if (notification == null) return;
      log(
        'NotificationService | foreground: ${notification.title}',
      );
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: 'ic_stat_notify',
            color: const Color(0xFF006B2C),
            largeIcon: const DrawableResourceAndroidBitmap('ic_launcher_foreground'),
          ),
        ),
      );
    });
  }
}
