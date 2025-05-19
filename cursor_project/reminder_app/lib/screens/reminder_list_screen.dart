import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/reminder_provider.dart';
import '../models/reminder.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('리마인더 목록')),
      body: Consumer<ReminderProvider>(
        builder: (context, reminderProvider, child) {
          final reminders = reminderProvider.reminders;
          if (reminders.isEmpty) {
            return const Center(child: Text('등록된 리마인더가 없습니다.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await reminderProvider.loadReminders();
            },
            child: ListView.builder(
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final Reminder reminder = reminders[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(reminder.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reminder.description.length > 50
                              ? '${reminder.description.substring(0, 50)}...'
                              : reminder.description,
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
                          builder: (context) => ReminderDetailScreen(reminder: reminder),
                        ),
                      );
                    },
                  ),
                );
              },
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
          // 리마인더 추가 후 목록 새로고침
          if (mounted) {
            Provider.of<ReminderProvider>(context, listen: false).loadReminders();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
