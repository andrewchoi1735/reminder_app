import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/reminder.dart';
import '../providers/reminder_provider.dart';
import 'reminder_detail_screen.dart';
import 'add_reminder_screen.dart';

class ReminderCalendarScreen extends StatefulWidget {
  const ReminderCalendarScreen({super.key});

  @override
  State<ReminderCalendarScreen> createState() => _ReminderCalendarScreenState();
}

class _ReminderCalendarScreenState extends State<ReminderCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReminderProvider>(context, listen: false).loadReminders();
    });
  }

  // 날짜를 "시간 제외"한 형태로 정규화
  DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  @override
  Widget build(BuildContext context) {
    final reminders = Provider.of<ReminderProvider>(context).reminders;

    // 날짜별로 리마인더 그룹핑
    Map<DateTime, List<Reminder>> reminderMap = {};
    for (var r in reminders) {
      final date = normalizeDate(r.date);
      reminderMap.putIfAbsent(date, () => []).add(r);
    }

    final selectedReminders = reminderMap[normalizeDate(_selectedDay ?? _focusedDay)] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('캘린더'),
      ),
      body: Column(
        children: [
          TableCalendar<Reminder>(
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            eventLoader: (day) {
              final date = normalizeDate(day);
              return reminderMap[date] ?? [];
            },
            calendarStyle: const CalendarStyle(
              markerDecoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: selectedReminders.isEmpty
                ? const Center(child: Text('선택된 날짜에 할 일이 없습니다.'))
                : ListView.builder(
              itemCount: selectedReminders.length,
              itemBuilder: (context, index) {
                final reminder = selectedReminders[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    title: Text(reminder.title),
                    subtitle: Text('${reminder.description}\n시간: ${reminder.time}'),
                    isThreeLine: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReminderDetailScreen(reminder: reminder),
                        ),
                      );
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await Provider.of<ReminderProvider>(context, listen: false)
                            .deleteReminder(reminder.id!);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddReminderScreen()),
          );
          if (mounted) {
            Provider.of<ReminderProvider>(context, listen: false).loadReminders();
          }
        },
      ),
    );
  }
}
