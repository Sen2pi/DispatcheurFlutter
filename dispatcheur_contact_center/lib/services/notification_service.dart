import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      final iosSettings = DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
        onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        macOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      );

      _initialized = true;
      debugPrint('✅ NotificationService inicializado');
    } catch (e) {
      debugPrint('❌ Erro ao inicializar NotificationService: $e');
    }
  }

  Future<void> showIncomingCallNotification({
    required String callerId,
    required String callerName,
  }) async {
    if (!_initialized) await initialize();

    try {
      const androidDetails = AndroidNotificationDetails(
        'incoming_calls',
        'Incoming Calls',
        channelDescription: 'Notificações de chamadas recebidas',
        importance: Importance.max,
        priority: Priority.high,
        category: AndroidNotificationCategory.call,
        fullScreenIntent: true,
        ongoing: true,
        autoCancel: false,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        categoryIdentifier: 'incoming_call',
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        callerId.hashCode,
        'Chamada Recebida',
        'Chamada de $callerName',
        details,
        payload: 'incoming_call:$callerId',
      );
    } catch (e) {
      debugPrint('❌ Erro ao mostrar notificação: $e');
    }
  }

  Future<void> cancelIncomingCallNotification(String callerId) async {
    try {
      await _notificationsPlugin.cancel(callerId.hashCode);
    } catch (e) {
      debugPrint('❌ Erro ao cancelar notificação: $e');
    }
  }

  Future<void> _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) async {
    debugPrint('Notificação iOS recebida: $title');
  }

  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    debugPrint('Notificação clicada: ${response.payload}');
  }
}
