import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> scheduleReminderNotification({
  required int id,
  required String title,
  required DateTime remindAt,
}) async {
  final tz.TZDateTime scheduledTime = tz.TZDateTime.from(
    remindAt.subtract(const Duration(minutes: 30)), // ⏰ 30분 전
    tz.local,
  );

  if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) {
    // 알림 시간이 이미 지난 경우 예약하지 않음
    return;
  }

  await flutterLocalNotificationsPlugin.zonedSchedule(
    id,
    '곧 다가오는 일정 📌',
    title,
    scheduledTime,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'reminder_channel',
        'Reminder Notifications',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
    UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.dateAndTime,
  );
}
