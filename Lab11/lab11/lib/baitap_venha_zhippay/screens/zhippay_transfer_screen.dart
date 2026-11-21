import 'package:flutter/material.dart';
import '../services/zhippay_service.dart';

class ZhippayTransferScreen extends StatefulWidget {
  final String? initialRecipient;

  const ZhippayTransferScreen({super.key, this.initialRecipient});

  @override
  State<ZhippayTransferScreen> createState() => _ZhippayTransferScreenState();
}

class _ZhippayTransferScreenState extends State<ZhippayTransferScreen> {
  String _amountStr = '1740.00';
  late String _recipient;
  final String _note = 'New macbook air m2';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _recipient = widget.initialRecipient ?? 'Amazon';
  }

  void _onKeyPress(String key) {
    setState(() {
      if (key == 'backspace') {
        if (_amountStr.isNotEmpty) {
          _amountStr = _amountStr.substring(0, _amountStr.length - 1);
          if (_amountStr.isEmpty) _amountStr = '0';
        }
      } else if (key == '.') {
        if (!_amountStr.contains('.')) {
          _amountStr += '.';
        }
      } else {
        if (_amountStr == '0') {
          _amountStr = key;
        } else {
          // Chỉ cho phép 2 chữ số thập phân
          if (_amountStr.contains('.') &&
              _amountStr.split('.').last.length >= 2) {
            return;
          }
          _amountStr += key;
        }
      }
    });
  }

  Future<void> _handleSendMoney() async {
    final amount = double.tryParse(_amountStr) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số tiền hợp lệ')),
      );
      return;
    }

    final balance = ZhippayService.instance.balance;
    if (amount > balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Số dư khả dụng (\$${balance.toStringAsFixed(2)}) không đủ để chuyển \$${amount.toStringAsFixed(2)}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ZhippayService.instance.transfer(
        amount: amount,
        recipient: _recipient,
        note: _note,
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Chuyển tiền thành công!'),
              ],
            ),
            content: Text(
              'Đã chuyển thành công \$${amount.toStringAsFixed(2)} tới $_recipient.\nSố dư còn lại: \$${ZhippayService.instance.balance.toStringAsFixed(2)}',
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Hoàn tất'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi chuyển tiền: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const purpleBrand = Color(0xFF4E54C8);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Send Money',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  children: [
                    // Card Wallet Balance (Trang 11)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.account_balance_wallet_outlined, size: 20, color: Colors.grey),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Wallet balance',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Safe to spend \$${ZhippayService.instance.balance.toStringAsFixed(2)}',
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.swap_vert, color: Colors.grey, size: 20),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Recipient Card (Trang 11 - Amazon mockup)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                _recipient.isNotEmpty ? _recipient[0] : 'A',
                                style: TextStyle(
                                  color: Colors.amber.shade900,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _recipient,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _note,
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Huge Amount Display ($1740,00)
                    Text(
                      '\$$_amountStr',
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Info text (The transfer will be complete by Friday, August 21)
                    Text(
                      'The transfer will be complete by Friday, August 21',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            ),

            // Custom Numeric Keypad (1 - 9, ., 0, backspace) y hệt hình Trang 11
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                children: [
                  _buildKeypadRow(['1', '2', '3']),
                  const SizedBox(height: 8),
                  _buildKeypadRow(['4', '5', '6']),
                  const SizedBox(height: 8),
                  _buildKeypadRow(['7', '8', '9']),
                  const SizedBox(height: 8),
                  _buildKeypadRow(['.', '0', 'backspace']),
                  const SizedBox(height: 16),

                  // Send Money Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSendMoney,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: purpleBrand,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Send money',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: InkWell(
              onTap: () => _onKeyPress(key),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Center(
                  child: key == 'backspace'
                      ? const Icon(Icons.backspace_outlined, size: 18, color: Colors.black87)
                      : Text(
                          key,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
