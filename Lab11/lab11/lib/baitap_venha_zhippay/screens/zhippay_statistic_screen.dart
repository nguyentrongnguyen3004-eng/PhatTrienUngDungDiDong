import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/wallet_transaction.dart';
import '../services/zhippay_service.dart';

class ZhippayStatisticScreen extends StatefulWidget {
  const ZhippayStatisticScreen({super.key});

  @override
  State<ZhippayStatisticScreen> createState() => _ZhippayStatisticScreenState();
}

class _ZhippayStatisticScreenState extends State<ZhippayStatisticScreen> {
  int _selectedDays = 30; // 30 ngày (1 tháng), 90 ngày (1 quý), 365 ngày (1 năm)
  final ZhippayService _service = ZhippayService.instance;

  @override
  Widget build(BuildContext context) {
    final stats = _service.getStatistics(_selectedDays);
    final double income = stats['totalIncome'];
    final double expense = stats['totalExpense'];
    final double net = stats['netFlow'];
    final List<WalletTransaction> transactions = stats['transactions'];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thống kê Dòng tiền',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          const Text(
            'Phân tích chi tiêu và thu nhập theo thời gian',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // Bộ lọc khoảng thời gian theo yêu cầu Trang 12: 1 tháng, 1 quý, 1 năm
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildFilterTab('1 Tháng', 30),
                _buildFilterTab('1 Quý', 90),
                _buildFilterTab('1 Năm', 365),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Cards Tổng quan (Thu nhập, Chi tiêu, Dòng tiền ròng)
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'Tổng Thu',
                  amount: income,
                  color: Colors.green,
                  icon: Icons.arrow_downward,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: 'Tổng Chi',
                  amount: expense,
                  color: Colors.redAccent,
                  icon: Icons.arrow_upward,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dòng tiền ròng (Net)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text('Thu trừ Chi', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
                Text(
                  '${net >= 0 ? '+' : ''}\$${net.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: net >= 0 ? Colors.green.shade700 : Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Biểu đồ so sánh Thu - Chi trực quan bằng fl_chart
          const Text(
            'Biểu đồ Thu / Chi',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            height: 190,
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (income > expense ? income : expense) * 1.25 + 50,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        if (val == 0) return const Text('Thu nhập', style: TextStyle(fontSize: 11));
                        if (val == 1) return const Text('Chi tiêu', style: TextStyle(fontSize: 11));
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: income,
                        color: Colors.green,
                        width: 28,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: expense,
                        color: Colors.redAccent,
                        width: 28,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Danh sách các giao dịch trong khoảng thời gian đã lọc
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Giao dịch (${transactions.length})',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Text(
                'Lọc: $_selectedDays ngày qua',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (transactions.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: const Text('Không có giao dịch trong khoảng thời gian này.', style: TextStyle(color: Colors.grey)),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final tx = transactions[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        tx.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                        color: tx.isIncome ? Colors.green : Colors.redAccent,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(tx.subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${tx.isIncome ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: tx.isIncome ? Colors.green : Colors.black87,
                            ),
                          ),
                          Text(
                            DateFormat('dd/MM/yyyy').format(tx.date),
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, int days) {
    final isSelected = _selectedDays == days;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedDays = days;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? const Color(0xFF4E54C8) : Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
