import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'services/notification_service.dart';
import 'data/models/call_model.dart';
import 'data/models/contact_model.dart';
import 'data/models/note_model.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Configurar orientação
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Carregar variáveis de ambiente
    await dotenv.load(fileName: ".env");

    // Inicializar Hive
    await Hive.initFlutter();

    // Registrar adaptadores Hive
    Hive.registerAdapter(CallModelAdapter());
    Hive.registerAdapter(ContactModelAdapter());
    Hive.registerAdapter(NoteModelAdapter());

    // Abrir boxes Hive
    await Hive.openBox<CallModel>('calls');
    await Hive.openBox<ContactModel>('contacts');
    await Hive.openBox<NoteModel>('notes');
    await Hive.openBox('settings');

    // Configurar injeção de dependências
    configureDependencies();

    // Configurar notificações
    await _initializeNotifications();

    // Solicitar permissões
    await _requestPermissions();

    // Configurar status bar
    await _configureSystemUI();

    runApp(const ProviderScope(child: DispatcheurApp()));
  } catch (e) {
    debugPrint('Erro na inicialização: $e');
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
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

  final iosSettings = DarwinInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true,
    onDidReceiveLocalNotification: (id, title, body, payload) async {
      debugPrint('Notificação iOS recebida: $title');
    },
  );

  const initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
    macOS: iosSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (details) {
      debugPrint('Notificação clicada: ${details.payload}');
    },
  );
}

Future<void> _requestPermissions() async {
  final deviceInfo = DeviceInfoPlugin();

  // Permissões básicas
  final permissions = <Permission>[
    Permission.microphone,
    Permission.camera,
    Permission.notification,
  ];

  // Permissões específicas do Android
  if (Theme.of(
        WidgetsBinding.instance.platformDispatcher.views.first,
      ).platform ==
      TargetPlatform.android) {
    final androidInfo = await deviceInfo.androidInfo;

    permissions.addAll([Permission.phone, Permission.audio]);

    // Para Android 13+
    if (androidInfo.version.sdkInt >= 33) {
      permissions.add(Permission.notification);
    }
  }

  // Solicitar permissões
  final statuses = await permissions.request();

  // Log dos resultados
  statuses.forEach((permission, status) {
    debugPrint('$permission: $status');
  });
}

Future<void> _configureSystemUI() async {
  // Configurar cores da status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
}
