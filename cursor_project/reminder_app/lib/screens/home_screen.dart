import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/auth_provider.dart';
import '../providers/reminder_provider.dart';
import '../models/reminder.dart';
import 'add_reminder_screen.dart';
import 'login_screen.dart';
import 'reminder_list_screen.dart';
import 'reminder_detail_screen.dart';
import 'settings_screen.dart';

import 'memo_list_screen.dart';
import 'calculator_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Provider.of<AuthProvider>(context, listen: false).userId;
      Provider.of<ReminderProvider>(context, listen: false).initDatabase(userId);
      setState(() => _isLoading = false);
    });
  }

  List<Reminder> _getRemindersForDay(DateTime day) {
    return Provider.of<ReminderProvider>(context)
        .reminders
        .where((reminder) =>
            reminder.date.year == day.year &&
            reminder.date.month == day.month &&
            reminder.date.day == day.day)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('컨텐츠 목록'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: [
          _buildContentCard(
            context,
            '리마인더',
            Icons.calendar_today,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReminderListScreen()),
            ),
          ),
          _buildContentCard(
            context,
            '메모장',
            Icons.note,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MemoListScreen()),
            ),
          ),
          _buildContentCard(
            context,
            '계산기',
            Icons.calculate,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CalculatorScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(BuildContext context, String title, IconData icon, VoidCallback onPressed) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 0,
      color: colorScheme.surfaceVariant,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(
          icon,
          size: 48,
          color: colorScheme.primary,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        onTap: onPressed,
      ),
    );
  }
} 