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
import 'screens/sensor_step_counter_screen.dart';
import 'screens/reward_screen.dart'; // 상단 import

import 'utils/notification_helper.dart';

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

Future<void> requestActivityPermission() async {
  if (!kIsWeb && Platform.isAndroid) {
    final status = await Permission.activityRecognition.status;
    if (!status.isGranted) {
      await Permission.activityRecognition.request();
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initNotifications();
  await requestNotificationPermission();
  await requestActivityPermission(); // ✅ 걸음수 측정용 권한 요청 추가!

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
      scheduleDailyReminders(context, provider);
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
        '/sensor_steps': (context) => const SensorStepCounterScreen(), // ✅ 걸음수 측정 화면
        '/reward': (context) => const StepRewardScreen(),  // ✅ 추가
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
