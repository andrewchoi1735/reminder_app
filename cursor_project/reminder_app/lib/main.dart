import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'providers/auth_provider.dart';
import 'providers/reminder_provider.dart';
import 'providers/memo_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/ledger_provider.dart';

import 'screens/login_screen.dart';
import 'screens/content_list_screen.dart';
import 'screens/reminder_calendar_screen.dart';
import 'screens/add_reminder_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  // Android 알림 초기 설정
  const AndroidInitializationSettings androidSettings =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // 시간대 설정 (필수)
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Seoul')); // 한국 시간대로 지정
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initNotifications(); // 🔔 알림 초기화

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
