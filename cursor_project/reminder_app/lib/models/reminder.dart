import 'package:intl/intl.dart';

class Reminder {
  int? id;
  final String title;
  final String description;
  final DateTime date;
  final String time;
  final List<String> participants;
  final bool isDone;

  Reminder({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.participants,
    this.isDone = false,
  });

  /// ✅ DB나 JSON 변환용 toMap (toJson)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'time': time,
      'participants': participants,
      'isDone': isDone ? 1 : 0, // ✅ bool → int
    };
  }

  Map<String, List<Reminder>> groupRemindersByWeek(List<Reminder> reminders) {
    Map<String, List<Reminder>> grouped = {};

    for (var reminder in reminders) {
      final monday = reminder.date.subtract(Duration(days: reminder.date.weekday - 1));
      final sunday = monday.add(const Duration(days: 6));
      final key = '${DateFormat('yyyy.MM.dd').format(monday)} ~ ${DateFormat('MM.dd').format(sunday)}';

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(reminder);
    }

    return grouped;
  }


  /// ✅ fromMap (fromJson)
  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as int?,
      title: json['title'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String,
      participants: List<String>.from(json['participants'] as List),
      isDone: (json['isDone'] ?? 0) == 1, // ✅ int → bool (기본값 0)
    );
  }

  /// ✅ copyWith 추가
  Reminder copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? date,
    String? time,
    List<String>? participants,
    bool? isDone,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      participants: participants ?? this.participants,
      isDone: isDone ?? this.isDone,
    );
  }
}
