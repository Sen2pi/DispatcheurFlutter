import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

import 'core/di/injection.dart';
import 'core/constants/app_constants.dart';
import 'core/utils/logger.dart';
import 'app.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Configurar orientação
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Carregar variáveis de ambiente
    await dotenv.load(fileName: ".env");
    AppLogger.info('Variáveis de ambiente carregadas');

    // Inicializar Hive
    await Hive.initFlutter();
    AppLogger.info('Hive inicializado');

    // Configurar injeção de dependências
    await configureDependencies();
    AppLogger.info('Dependências configuradas');

    // Configurar notificações
    await _initializeNotifications();
    AppLogger.info('Notificações configuradas');

    // Solicitar permissões críticas
    await _requestCriticalPermissions();
    AppLogger.info('Permissões solicitadas');

    runApp(const ProviderScope(child: DispatcheurApp()));
  } catch (e, stackTrace) {
    AppLogger.error('Erro na inicialização da app', e, stackTrace);
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Erro na inicialização: $e'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => main(),
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _initializeNotifications() async {
  // Awesome Notifications
  await AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelKey: AppConstants.notificationChannelKey,
      channelName: 'DispatcheurCC VoIP',
      channelDescription: 'Notificações de chamadas VoIP',
      defaultColor: const Color(0xFF3B82F6),
      ledColor: Colors.blue,
      importance: NotificationImportance.High,
      enableVibration: true,
      enableLights: true,
      playSound: true,
      criticalAlerts: true,
    ),
  ]);

  // Local Notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
        requestCriticalPermission: true,
      );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
    macOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      AppLogger.info('Notificação clicada: ${response.payload}');
    },
  );
}

Future<void> _requestCriticalPermissions() async {
  final permissions = [Permission.microphone, Permission.notification];

  // Adicionar permissões específicas do Android
  if (Theme.of(
        WidgetsBinding.instance.focusManager.primaryFocus?.context ??
            NavigationService.navigatorKey.currentContext!,
      ).platform ==
      TargetPlatform.android) {
    permissions.addAll([Permission.phone, Permission.systemAlertWindow]);
  }

  final statuses = await permissions.request();

  for (final entry in statuses.entries) {
    if (entry.value.isPermanentlyDenied) {
      AppLogger.warning('Permissão ${entry.key} negada permanentemente');
    } else if (entry.value.isDenied) {
      AppLogger.warning('Permissão ${entry.key} negada');
    } else {
      AppLogger.info('Permissão ${entry.key} concedida');
    }
  }
}
