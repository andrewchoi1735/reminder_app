import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/reminder.dart';
import '../providers/auth_provider.dart';
import '../providers/reminder_provider.dart';
import 'add_reminder_screen.dart';
import 'reminder_detail_screen.dart';

class ReminderListScreen extends StatefulWidget {
  const ReminderListScreen({super.key});

  @override
  State<ReminderListScreen> createState() => _ReminderListScreenState();
}

class _ReminderListScreenState extends State<ReminderListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Provider.of<AuthProvider>(context, listen: false).userId;
      Provider.of<ReminderProvider>(context, listen: false).setUser(userId);
    });
  }

  /// ✅ 주 단위로 리마인더 묶기
  Map<String, List<Reminder>> groupRemindersByWeek(List<Reminder> reminders) {
    Map<String, List<Reminder>> grouped = {};

    for (var reminder in reminders) {
      final monday = reminder.date.subtract(Duration(days: reminder.date.weekday - 1));
      final sunday = monday.add(const Duration(days: 6));
      final key = '${DateFormat('yyyy.MM.dd').format(monday)} ~ ${DateFormat('MM.dd').format(sunday)}';

      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(reminder);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('할 일 목록'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: '캘린더 보기',
            onPressed: () {
              Navigator.pushNamed(context, '/calendar');
            },
          ),
        ],
      ),
      body: Consumer<ReminderProvider>(
        builder: (context, reminderProvider, child) {
          final reminders = reminderProvider.reminders;
          if (reminders.isEmpty) {
            return const Center(child: Text('등록된 할일이 없습니다.'));
          }

          final groupedReminders = groupRemindersByWeek(reminders);

          return RefreshIndicator(
            onRefresh: () async {
              await reminderProvider.loadReminders();
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: groupedReminders.entries.map((entry) {
                final weekRange = entry.key;
                final weekReminders = entry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        weekRange,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...weekReminders.map((reminder) => Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: Checkbox(
                          value: reminder.isDone,
                          onChanged: (value) async {
                            final updated = reminder.copyWith(isDone: value!);
                            await reminderProvider.updateReminder(updated);
                          },
                        ),
                        title: Text(
                          reminder.title,
                          style: TextStyle(
                            decoration:
                            reminder.isDone ? TextDecoration.lineThrough : null,
                            color: reminder.isDone ? Colors.grey : null,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reminder.description.length > 50
                                  ? '${reminder.description.substring(0, 50)}...'
                                  : reminder.description,
                              style: TextStyle(
                                color: reminder.isDone ? Colors.grey : null,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '날짜: ${reminder.date.toString().split(' ').first}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await reminderProvider.deleteReminder(reminder.id!);
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ReminderDetailScreen(reminder: reminder),
                            ),
                          );
                        },
                      ),
                    ))
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddReminderScreen()),
          );
          if (mounted) {
            Provider.of<ReminderProvider>(context, listen: false).loadReminders();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
