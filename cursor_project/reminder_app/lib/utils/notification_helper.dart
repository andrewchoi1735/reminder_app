import 'package:reminder_app/providers/reminder_provider.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> scheduleDailyReminders(BuildContext context, ReminderProvider provider) async {
  final now = tz.TZDateTime.now(tz.local);
  final scheduleTimes = {
    'MORNING': tz.TZDateTime(tz.local, now.year, now.month, now.day, 9),
    'AFTERNOON': tz.TZDateTime(tz.local, now.year, now.month, now.day, 14),
    'EVENING': tz.TZDateTime(tz.local, now.year, now.month, now.day, 21),
  };

  for (final entry in scheduleTimes.entries) {
    final label = entry.key;
    final time = entry.value;

    // 지금 시간이 해당 시간보다 이후라면 해당 알림은 오늘 실행 안 함
    if (now.hour >= time.hour) continue;

    // 조건 확인 후 알림 발송
    await checkAndSendReminder(context, label, provider);
  }
}
Future<void> scheduleDailyRemindersWithoutContext(ReminderProvider provider) async {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final hasPending = provider.reminders.any((r) =>
  r.date.year == today.year &&
      r.date.month == today.month &&
      r.date.day == today.day &&
      !r.isDone);

  if (!hasPending) return;

  await flutterLocalNotificationsPlugin.show(
    999,
    '오늘의 할 일 알림',
    '앱을 열어 오늘의 할 일을 확인해보세요!',
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_reminder_channel',
        'Daily Reminders',
        importance: Importance.high,
        priority: Priority.high,
      ),
    ),
  );
}

Future<void> checkAndSendReminder(
    BuildContext context,
    String label,
    ReminderProvider provider,
    ) async {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final hasPending = provider.reminders.any((r) =>
  r.date.year == today.year &&
      r.date.month == today.month &&
      r.date.day == today.day &&
      !r.isDone);

  if (!hasPending) return; // 할 일 없으면 알림 안 보냄

  await flutterLocalNotificationsPlugin.show(
    label.hashCode,
    '할 일 알림',
    _getMessageForLabel(label),
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_reminder_channel',
        'Daily Reminders',
        importance: Importance.high,
        priority: Priority.high,
      ),
    ),
  );
}

String _getMessageForLabel(String label) {
  switch (label) {
    case 'MORNING':
      return '오늘의 할 일을 확인해주세요.';
    case 'AFTERNOON':
      return '아직 끝마치지 못한 일이 있어요.';
    case 'EVENING':
      return '오늘 할 일을 내일로 미루지 말아주세요.';
    default:
      return '할 일을 확인해주세요.';
  }
}
