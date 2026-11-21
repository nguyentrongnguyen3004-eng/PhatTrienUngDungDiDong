import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wallet_transaction.dart';
import '../../services/firebase_service.dart';

class ZhippayService {
  static final ZhippayService instance = ZhippayService._internal();
  ZhippayService._internal() {
    _initSampleData();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double _balance = 2108.22; // Số dư mặc định theo mẫu slide Trang 11
  final int _rewardPoints = 6350;
  String _userName = 'Alex Nguyen';
  final String _userEmail = 'alex.nguyen@example.com';
  String _userPhone = '+84 987 654 321';

  final List<WalletTransaction> _transactions = [];
  final StreamController<double> _balanceController = StreamController<double>.broadcast();
  final StreamController<List<WalletTransaction>> _transController =
      StreamController<List<WalletTransaction>>.broadcast();

  double get balance => _balance;
  int get rewardPoints => _rewardPoints;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userPhone => _userPhone;

  Stream<double> get balanceStream => _balanceController.stream;
  Stream<List<WalletTransaction>> get transactionsStream => _transController.stream;

  void _initSampleData() {
    // Nạp các giao dịch mẫu y hệt trong hình mockup Trang 11
    final now = DateTime.now();
    _transactions.addAll([
      WalletTransaction(
        id: 'tx_1',
        title: 'Withdraw',
        subtitle: 'Cardless withdraw',
        amount: 232.80,
        type: TransactionType.withdraw,
        date: now.subtract(const Duration(days: 2)),
      ),
      WalletTransaction(
        id: 'tx_2',
        title: 'Bank transfer',
        subtitle: 'to Greg Stan',
        amount: 170.09,
        type: TransactionType.transfer,
        date: now.subtract(const Duration(days: 4)),
        recipient: 'Greg Stan',
      ),
      WalletTransaction(
        id: 'tx_3',
        title: 'Deposit',
        subtitle: 'From ATM Cash',
        amount: 32.65,
        type: TransactionType.deposit,
        date: now.subtract(const Duration(days: 6)),
      ),
      WalletTransaction(
        id: 'tx_4',
        title: 'Salary Deposit',
        subtitle: 'Tech Corp Payroll',
        amount: 1500.00,
        type: TransactionType.deposit,
        date: now.subtract(const Duration(days: 25)),
      ),
      WalletTransaction(
        id: 'tx_5',
        title: 'Shopping Online',
        subtitle: 'Amazon Retail',
        amount: 450.00,
        type: TransactionType.transfer,
        date: now.subtract(const Duration(days: 50)),
      ),
      WalletTransaction(
        id: 'tx_6',
        title: 'Bonus Reward',
        subtitle: 'Quarterly Cashback',
        amount: 300.00,
        type: TransactionType.deposit,
        date: now.subtract(const Duration(days: 120)),
      ),
    ]);
  }

  void notifyAll() {
    _balanceController.add(_balance);
    _transController.add(List.unmodifiable(_transactions));
  }

  /// Nạp tiền vào ví (Top Up)
  Future<void> topUp(double amount, String source) async {
    _balance += amount;
    final tx = WalletTransaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Top Up',
      subtitle: 'Nạp qua $source',
      amount: amount,
      type: TransactionType.deposit,
      date: DateTime.now(),
    );
    _transactions.insert(0, tx);
    notifyAll();

    if (!FirebaseService.instance.useMockMode) {
      try {
        await _firestore.collection('zhippay_transactions').add(tx.toMap());
        await _firestore.collection('zhippay_wallet').doc('default_wallet').set({
          'balance': _balance,
          'updatedAt': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));
      } catch (_) {}
    }
  }

  /// Rút tiền khỏi ví (Withdraw)
  Future<void> withdraw(double amount, String destination) async {
    if (amount > _balance) {
      throw Exception('Số dư không đủ để thực hiện rút tiền');
    }
    _balance -= amount;
    final tx = WalletTransaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Withdraw',
      subtitle: 'Rút về $destination',
      amount: amount,
      type: TransactionType.withdraw,
      date: DateTime.now(),
    );
    _transactions.insert(0, tx);
    notifyAll();

    if (!FirebaseService.instance.useMockMode) {
      try {
        await _firestore.collection('zhippay_transactions').add(tx.toMap());
        await _firestore.collection('zhippay_wallet').doc('default_wallet').set({
          'balance': _balance,
          'updatedAt': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));
      } catch (_) {}
    }
  }

  /// Chuyển khoản (Transfer / Send Money)
  Future<void> transfer({
    required double amount,
    required String recipient,
    String? note,
  }) async {
    if (amount > _balance) {
      throw Exception('Số dư không đủ để chuyển khoản');
    }
    _balance -= amount;
    final tx = WalletTransaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Bank transfer',
      subtitle: note?.isNotEmpty == true ? 'to $recipient: $note' : 'to $recipient',
      amount: amount,
      type: TransactionType.transfer,
      date: DateTime.now(),
      recipient: recipient,
    );
    _transactions.insert(0, tx);
    notifyAll();

    if (!FirebaseService.instance.useMockMode) {
      try {
        await _firestore.collection('zhippay_transactions').add(tx.toMap());
        await _firestore.collection('zhippay_wallet').doc('default_wallet').set({
          'balance': _balance,
          'updatedAt': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));
      } catch (_) {}
    }
  }

  /// Lọc và thống kê dòng tiền theo khoảng thời gian (1 tháng, 1 quý, 1 năm...)
  Map<String, dynamic> getStatistics(int days) {
    final now = DateTime.now();
    final cutoff = now.subtract(Duration(days: days));

    final filtered = _transactions.where((t) => t.date.isAfter(cutoff)).toList();

    double totalIncome = 0;
    double totalExpense = 0;

    for (var tx in filtered) {
      if (tx.isIncome) {
        totalIncome += tx.amount;
      } else {
        totalExpense += tx.amount;
      }
    }

    return {
      'transactions': filtered,
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'netFlow': totalIncome - totalExpense,
    };
  }

  /// Cập nhật profile
  void updateProfile({String? name, String? phone}) {
    if (name != null && name.isNotEmpty) _userName = name;
    if (phone != null && phone.isNotEmpty) _userPhone = phone;
  }
}
