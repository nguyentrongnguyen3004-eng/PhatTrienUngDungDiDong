import 'package:flutter/material.dart';
import '../auth_service.dart';
import 'auth_screen.dart';
import '../../bai2_storage_upload/screens/upload_screen.dart';
import '../../bai3_product_crud/screens/product_list_screen.dart';
import '../../baitap_venha_zhippay/screens/zhippay_onboarding_screen.dart';

class UserProfileScreen extends StatelessWidget {
  final String email;
  final String displayName;
  final String provider;
  final String uid;

  const UserProfileScreen({
    super.key,
    required this.email,
    required this.displayName,
    required this.provider,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: const Text('Hồ sơ Người dùng (Auth)'),
        backgroundColor: const Color(0xFFFF3366),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 46,
              backgroundColor: const Color(0xFFFF3366).withValues(alpha: 0.15),
              child: Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF3366),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              displayName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              email,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 0.5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow('Phương thức xác thực', provider),
                    const Divider(),
                    _buildInfoRow('User ID (UID)', uid),
                    const Divider(),
                    _buildInfoRow('Trạng thái', 'Đã đăng nhập thành công'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Chuyển sang các bài tập tiếp theo
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'CÁC BÀI TẬP TIẾP THEO',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey, letterSpacing: 0.5),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              leading: const Icon(Icons.cloud_upload_outlined, color: Colors.blue),
              title: const Text('Bài 2: Upload File & Quản lý tiến trình', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const UploadScreen()),
                );
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              leading: const Icon(Icons.pedal_bike, color: Colors.purple),
              title: const Text('Bài 3: Quản lý Sản phẩm (Firestore & Storage)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProductListScreen()),
                );
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              leading: const Icon(Icons.account_balance_wallet_outlined, color: Colors.indigo),
              title: const Text('Bài tập về nhà: Ví điện tử Zhippay', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ZhippayOnboardingScreen()),
                );
              },
            ),
            const SizedBox(height: 28),

            // Nút đăng xuất
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await AuthService.instance.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const AuthScreen()),
                    );
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Đăng xuất'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade600,
                  side: BorderSide(color: Colors.red.shade300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }
}
