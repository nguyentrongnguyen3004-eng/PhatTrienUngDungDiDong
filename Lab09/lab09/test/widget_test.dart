import 'package:flutter_test/flutter_test.dart';
import 'package:lab09/models/expense.dart';
import 'package:lab09/models/user.dart';

void main() {
  group('Expense Model Tests', () {
    test('Expense toMap and fromMap conversion', () {
      final expense = Expense(
        id: 1,
        title: 'Ăn trưa',
        amount: 35000.0,
        note: 'Cơm tấm',
        date: '18/10/2026 12:00',
      );

      final map = expense.toMap();
      expect(map['id'], 1);
      expect(map['title'], 'Ăn trưa');
      expect(map['amount'], 35000.0);
      expect(map['note'], 'Cơm tấm');
      expect(map['date'], '18/10/2026 12:00');

      final fromMapExpense = Expense.fromMap(map);
      expect(fromMapExpense.id, expense.id);
      expect(fromMapExpense.title, expense.title);
      expect(fromMapExpense.amount, expense.amount);
      expect(fromMapExpense.note, expense.note);
      expect(fromMapExpense.date, expense.date);
    });

    test('Expense handles int amount properly', () {
      final map = {
        'id': 2,
        'title': 'Mua sách',
        'amount': 50000,
        'note': 'Sách Flutter',
        'date': '18/10/2026 14:00',
      };

      final expense = Expense.fromMap(map);
      expect(expense.amount, 50000.0);
    });
  });

  group('User Model Tests', () {
    test('User toMap and fromMap conversion', () {
      final user = User(
        id: 1,
        email: 'user@example.com',
        password: 'password123',
      );

      final map = user.toMap();
      expect(map['id'], 1);
      expect(map['email'], 'user@example.com');
      expect(map['password'], 'password123');

      final fromMapUser = User.fromMap(map);
      expect(fromMapUser.id, user.id);
      expect(fromMapUser.email, user.email);
      expect(fromMapUser.password, user.password);
    });
  });
}
