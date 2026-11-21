import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/wallet_transaction.dart';
import '../services/zhippay_service.dart';
import 'zhippay_transfer_screen.dart';
import 'zhippay_statistic_screen.dart';
import 'zhippay_profile_screen.dart';

class ZhippayDashboardScreen extends StatefulWidget {
  const ZhippayDashboardScreen({super.key});

  @override
  State<ZhippayDashboardScreen> createState() => _ZhippayDashboardScreenState();
}

class _ZhippayDashboardScreenState extends State<ZhippayDashboardScreen> {
  int _currentIndex = 0;
  final ZhippayService _service = ZhippayService.instance;

  @override
  void initState() {
    super.initState();
    _service.notifyAll();
  }

  void _showTopUpDialog() {
    final controller = TextEditingController(text: '100.00');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nạp tiền vào ví (Top Up)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Số tiền (\$USD)',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Nguồn tiền: Thẻ Visa / MasterCard liên kết',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text.trim()) ?? 0.0;
              if (amount > 0) {
                final messenger = ScaffoldMessenger.of(context);
                final nav = Navigator.of(ctx);
                await _service.topUp(amount, 'Thẻ Visa •••• 8824');
                nav.pop();
                if (mounted) {
                  setState(() {});
                  messenger.showSnackBar(
                    SnackBar(content: Text('Đã nạp \$${amount.toStringAsFixed(2)} thành công!')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4E54C8),
              foregroundColor: Colors.white,
            ),
            child: const Text('Xác nhận nạp'),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog() {
    final controller = TextEditingController(text: '50.00');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rút tiền (Withdraw)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Số tiền (\$USD)',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Số dư khả dụng: \$${_service.balance.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 12, color: Colors.blueAccent),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text.trim()) ?? 0.0;
              final messenger = ScaffoldMessenger.of(context);
              final nav = Navigator.of(ctx);
              try {
                if (amount > 0) {
                  await _service.withdraw(amount, 'Tài khoản Ngân hàng (ATM Cash)');
                  nav.pop();
                  if (mounted) {
                    setState(() {});
                    messenger.showSnackBar(
                      SnackBar(content: Text('Đã rút \$${amount.toStringAsFixed(2)} thành công!')),
                    );
                  }
                }
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Rút tiền'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildDashboardTab(),
            _buildWalletTab(),
            const ZhippayStatisticScreen(),
            const ZhippayProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4E54C8),
        unselectedItemColor: Colors.grey.shade400,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Statistic',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }

  /// Tab 1: Dashboard chính (Khớp 100% Mockup Trang 11)
  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Bar: zhippay, rewards badge, notification bell
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Về Menu chính',
              ),
              const Text(
                'zhippay',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              // Rewards pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.workspace_premium, size: 14, color: Colors.black87),
                    SizedBox(width: 4),
                    Text(
                      'rewards',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Notification bell
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Icon(Icons.notifications_none, size: 18, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Total Balance Card (Màu tím/indigo)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4E54C8), Color(0xFF6B58F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4E54C8).withOpacity(0.3),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total balance',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.stars, color: Colors.amberAccent, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            '${_service.rewardPoints} points >',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '\$${_service.balance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // 4 Action Buttons: Top Up, Transfer, Withdraw, History
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildBalanceActionButton(
                      icon: Icons.add_circle_outline,
                      label: 'Top Up',
                      onTap: _showTopUpDialog,
                    ),
                    _buildBalanceActionButton(
                      icon: Icons.send_outlined,
                      label: 'Transfer',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ZhippayTransferScreen()),
                        ).then((_) => setState(() {}));
                      },
                    ),
                    _buildBalanceActionButton(
                      icon: Icons.account_balance_outlined,
                      label: 'Withdraw',
                      onTap: _showWithdrawDialog,
                    ),
                    _buildBalanceActionButton(
                      icon: Icons.history,
                      label: 'History',
                      onTap: () {
                        setState(() {
                          _currentIndex = 2; // Switch to Statistic tab
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Upgrade Account Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome, color: Color(0xFF6B58F5), size: 18),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upgrade Account',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Upgrade account for more features',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section "Transfer again"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Transfer again',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Text(
                'see all',
                style: TextStyle(fontSize: 12, color: Colors.blueAccent.shade700, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Add new button
                Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ZhippayTransferScreen()),
                        ).then((_) => setState(() {}));
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Icon(Icons.add, color: Colors.black87, size: 20),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text('Add new', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
                const SizedBox(width: 14),
                _buildContactAvatar('Skyler', Colors.orange.shade100, Colors.orange.shade800),
                const SizedBox(width: 14),
                _buildContactAvatar('Andrew', Colors.blue.shade100, Colors.blue.shade800),
                const SizedBox(width: 14),
                _buildContactAvatar('Lavender', Colors.pink.shade100, Colors.pink.shade800),
                const SizedBox(width: 14),
                _buildContactAvatar('Grace', Colors.purple.shade100, Colors.purple.shade800),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Section "Latest transaction"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Latest transaction',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _currentIndex = 2; // Go to Statistic
                  });
                },
                child: Text(
                  'see all',
                  style: TextStyle(fontSize: 12, color: Colors.blueAccent.shade700, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Danh sách giao dịch gần nhất
          StreamBuilder<List<WalletTransaction>>(
            stream: _service.transactionsStream,
            initialData: _service.getStatistics(365)['transactions'],
            builder: (context, snapshot) {
              final list = snapshot.data ?? [];
              final displayList = list.take(5).toList();

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayList.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final tx = displayList[index];
                  return _buildTransactionItem(tx);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildContactAvatar(String name, Color bg, Color textColor) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ZhippayTransferScreen(initialRecipient: name)),
        ).then((_) => setState(() {}));
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: bg,
            child: Text(
              name[0],
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(fontSize: 11, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(WalletTransaction tx) {
    IconData icon;
    Color iconColor;
    if (tx.type == TransactionType.deposit) {
      icon = Icons.call_received;
      iconColor = Colors.green;
    } else if (tx.type == TransactionType.withdraw) {
      icon = Icons.call_made;
      iconColor = Colors.black87;
    } else {
      icon = Icons.swap_horiz;
      iconColor = const Color(0xFF4E54C8);
    }

    final dateStr = DateFormat('MMM dd, yyyy').format(tx.date);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  tx.subtitle,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
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
              const SizedBox(height: 2),
              Text(
                dateStr,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Tab 2: Wallet tab
  Widget _buildWalletTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ví tiền của tôi',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2C3E50), Color(0xFF3498DB)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Zhippay Virtual Debit', style: TextStyle(color: Colors.white70)),
                    Icon(Icons.credit_card, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  '\$${_service.balance.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text('•••• •••• •••• 8824', style: TextStyle(color: Colors.white70, letterSpacing: 2)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showTopUpDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Nạp tiền'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4E54C8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showWithdrawDialog,
                  icon: const Icon(Icons.arrow_upward),
                  label: const Text('Rút tiền'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
