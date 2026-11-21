import 'package:flutter/material.dart';
import 'services/firebase_service.dart';
import 'bai1_auth/screens/auth_screen.dart';
import 'bai2_storage_upload/screens/upload_screen.dart';
import 'bai3_product_crud/screens/product_list_screen.dart';
import 'baitap_venha_zhippay/screens/zhippay_onboarding_screen.dart';

void main() async {
  // 1. Khởi tạo Flutter Binding
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Khởi tạo Firebase kết nối tới project thật: lab11-firebase-4180d
  await FirebaseService.instance.initialize();

  // 3. Kiểm tra tình trạng kết nối đến Firebase (Trang 4 giáo trình)
  await FirebaseService.checkFirebaseConnected();

  runApp(const Lab11App());
}

class Lab11App extends StatelessWidget {
  const Lab11App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 11 - Flutter & Firebase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4E54C8),
          primary: const Color(0xFF4E54C8),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const MainMenuScreen(),
    );
  }
}

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isConnected = FirebaseService.instance.isInitialized;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text(
          'Lab 11: Flutter & Firebase',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Banner Trạng thái Firebase
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isConnected ? const Color(0xFFE8F5E9) : const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isConnected ? Colors.green.shade300 : Colors.amber.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isConnected ? Icons.cloud_done : Icons.cloud_queue,
                      color: isConnected ? Colors.green.shade700 : Colors.amber.shade800,
                      size: 26,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isConnected
                                ? 'Firebase: Đã kết nối thành công'
                                : 'Firebase: Chế độ Sẵn sàng',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isConnected ? Colors.green.shade900 : Colors.amber.shade900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isConnected
                                ? 'Dự án: lab11-firebase-4180d'
                                : 'Chưa kết nối Firebase thật.',
                            style: TextStyle(
                              fontSize: 11,
                              color: isConnected ? Colors.green.shade800 : Colors.amber.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'DANH SÁCH BÀI TẬP THỰC HÀNH',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),

              // Card Bài 1: Firebase Authentication
              _ExerciseMenuCard(
                title: 'Bài tập 1: Firebase Authentication',
                subtitle: 'Đăng ký, Đăng nhập Basic Auth (Email/Pass), Google Sign-In & Guest Auth.',
                icon: Icons.lock_person_outlined,
                accentColor: const Color(0xFFFF3366),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                  );
                },
              ),
              const SizedBox(height: 14),

              // Card Bài 2: Firebase Storage Upload
              _ExerciseMenuCard(
                title: 'Bài tập 2: Firebase Storage Upload',
                subtitle: 'Upload file lên Storage, hiển thị % tiến trình và quản lý Pause, Resume, Stop/Cancel.',
                icon: Icons.cloud_upload_outlined,
                accentColor: const Color(0xFF388AF6),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const UploadScreen()),
                  );
                },
              ),
              const SizedBox(height: 14),

              // Card Bài 3: Firestore & Storage CRUD
              _ExerciseMenuCard(
                title: 'Bài tập 3: Quản lý Sản phẩm (CRUD)',
                subtitle: 'Danh sách sản phẩm xe đạp, form thêm sản phẩm tải ảnh lên Storage và lưu Firestore, chức năng xóa.',
                icon: Icons.pedal_bike,
                accentColor: const Color(0xFF7A2CE8),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProductListScreen()),
                  );
                },
              ),
              const SizedBox(height: 14),

              // Card Bài tập về nhà: Zhippay E-Wallet
              _ExerciseMenuCard(
                title: 'Bài tập về nhà: Ví điện tử Zhippay',
                subtitle: 'Onboarding, Dashboard số dư, Chuyển tiền (Send Money) kèm bàn phím số, Nạp/Rút, Profile & Thống kê dòng tiền.',
                icon: Icons.account_balance_wallet_outlined,
                accentColor: const Color(0xFF4E54C8),
                isHighlight: true,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ZhippayOnboardingScreen()),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseMenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;
  final bool isHighlight;

  const _ExerciseMenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onTap,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHighlight ? accentColor.withValues(alpha: 0.5) : Colors.grey.shade200,
            width: isHighlight ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isHighlight ? accentColor.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: accentColor, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.3),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
