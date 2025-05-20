class Transaction {
  final int? id;
  final String title;
  final int amount;
  final DateTime date;
  final String type; // 'income' or 'expense'

  Transaction({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
  });

  Transaction copyWith({
    int? id,
    String? title,
    int? amount,
    DateTime? date,
    String? type,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
    );
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int?,
      title: json['title'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type,
    };
  }
}
