enum TransactionType { deposit, withdraw, transfer }

class WalletTransaction {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final String recipient;

  WalletTransaction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.type,
    required this.date,
    this.recipient = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'amount': amount,
      'type': type.name,
      'date': date.toIso8601String(),
      'recipient': recipient,
    };
  }

  factory WalletTransaction.fromMap(Map<String, dynamic> map, String docId) {
    TransactionType parsedType = TransactionType.transfer;
    if (map['type'] == 'deposit') parsedType = TransactionType.deposit;
    if (map['type'] == 'withdraw') parsedType = TransactionType.withdraw;

    return WalletTransaction(
      id: docId,
      title: map['title'] ?? 'Giao dịch',
      subtitle: map['subtitle'] ?? '',
      amount: (map['amount'] is num) ? (map['amount'] as num).toDouble() : 0.0,
      type: parsedType,
      date: map['date'] != null
          ? DateTime.tryParse(map['date']) ?? DateTime.now()
          : DateTime.now(),
      recipient: map['recipient'] ?? '',
    );
  }

  bool get isIncome => type == TransactionType.deposit;
}
