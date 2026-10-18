class Expense {
  final int? id;
  final String title;
  final double amount;
  final String note;
  final String? date;

  Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.note,
    this.date,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'amount': amount,
      'note': note,
      'date': date,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: (map['amount'] is int)
          ? (map['amount'] as int).toDouble()
          : (map['amount'] as num).toDouble(),
      note: map['note'] as String,
      date: map['date'] as String?,
    );
  }
}
