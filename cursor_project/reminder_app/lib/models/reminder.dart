class Reminder {
  int? id;
  final String title;
  final String description;
  final DateTime date;
  final String time;
  final List<String> participants;

  Reminder({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.participants,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'time': time,
      'participants': participants,
    };
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as int?,
      title: json['title'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String,
      participants: List<String>.from(json['participants'] as List),
    );
  }
} 