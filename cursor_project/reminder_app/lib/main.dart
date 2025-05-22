import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

import 'providers/auth_provider.dart';
import 'providers/reminder_provider.dart';
import 'providers/memo_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/ledger_provider.dart';

import 'screens/login_screen.dart';
import 'screens/content_list_screen.dart';
import 'screens/reminder_calendar_screen.dart';
import 'screens/add_reminder_screen.dart';

import 'utils/notification_helper.dart'; // ✅ 반복 알림 함수 포함

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
}

Future<void> requestNotificationPermission() async {
  if (!kIsWeb && Platform.isAndroid) {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initNotifications(); // ✅ 알림 초기화
  await requestNotificationPermission(); // ✅ Android 알림 권한 요청

  final authProvider = AuthProvider();
  await authProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authProvider),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
        ChangeNotifierProvider(create: (_) => MemoProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LedgerProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final provider = Provider.of<ReminderProvider>(context, listen: false);
      scheduleDailyReminders(context, provider); // ✅ context 안전한 시점에서 호출
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: '리마인더 앱',
      theme: themeProvider.theme,
      routes: {
        '/calendar': (context) => const ReminderCalendarScreen(),
        '/add_reminder': (context) => const AddReminderScreen(),
      },
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return auth.isLoggedIn
              ? const ContentListScreen()
              : const LoginScreen();
        },
      ),
    );
  }
}
