import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

class FirebaseService {
  static final FirebaseService instance = FirebaseService._internal();
  FirebaseService._internal();

  bool _isInitialized = false;
  bool _useMockMode = false;
  String _statusMessage = 'Đang khởi tạo Firebase...';

  bool get isInitialized => _isInitialized;
  bool get useMockMode => _useMockMode;
  String get statusMessage => _statusMessage;

  /// Khởi tạo Firebase theo hướng dẫn trong Slide (Trang 4)
  Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _isInitialized = Firebase.apps.isNotEmpty;
      _useMockMode = false;
      _statusMessage = 'Firebase đã kết nối thành công!';
      if (kDebugMode) {
        print('Firebase connected: $_isInitialized');
      }
    } catch (e) {
      // Khi chưa cấu hình Firebase Console thật hoặc chạy trên Windows/Web chưa config,
      // tự động kích hoạt Mock Mode để bạn vẫn chạy thử giao diện và bài tập bình thường!
      _isInitialized = false;
      _useMockMode = true;
      _statusMessage =
          'Chưa kết nối Firebase thật (Đang dùng Demo Mock Mode). Chạy flutterfire configure để kết nối thật.';
      if (kDebugMode) {
        print('Firebase init warning (Fallback to Mock Mode): $e');
        print('Firebase connected: false');
      }
    }
  }

  /// Hàm kiểm tra kết nối như trong giáo trình Trang 4 (checkFirebaseConnected)
  static Future<bool> checkFirebaseConnected() async {
    bool isConnected = Firebase.apps.isNotEmpty;
    if (kDebugMode) {
      print('Firebase connected: $isConnected');
    }
    return isConnected;
  }
}
