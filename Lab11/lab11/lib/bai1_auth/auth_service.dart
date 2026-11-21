import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/firebase_service.dart';

class AuthService {
  static final AuthService instance = AuthService._internal();
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _ggSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // Mock User nếu đang ở Demo Mode (khi chưa cấu hình Firebase Console)
  User? _mockUser;

  Stream<User?> get authStateChanges {
    if (FirebaseService.instance.useMockMode) {
      return Stream.value(_mockUser);
    }
    try {
      return _auth.authStateChanges();
    } catch (_) {
      return Stream.value(_mockUser);
    }
  }

  User? get currentUser {
    if (FirebaseService.instance.useMockMode) {
      return _mockUser;
    }
    try {
      return _auth.currentUser ?? _mockUser;
    } catch (_) {
      return _mockUser;
    }
  }

  /// Đăng nhập bằng Email & Password (Trang 5)
  Future<UserCredential?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    if (FirebaseService.instance.useMockMode) {
      if (password.length < 6) {
        throw Exception('Mật khẩu phải từ 6 ký tự trở lên (Demo Mode)');
      }
      _mockUser = null; // Mock handled in mock class if needed
      return null;
    }

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      if (kDebugMode) {
        print('User logged in: ${credential.user?.email}');
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('FirebaseAuthException: ${e.code} - ${e.message}');
      }
      rethrow;
    }
  }

  /// Đăng ký tài khoản mới bằng Email & Password (Trang 10)
  Future<UserCredential?> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    if (FirebaseService.instance.useMockMode) {
      if (password.length < 6) {
        throw Exception('Mật khẩu phải từ 6 ký tự trở lên (Demo Mode)');
      }
      return null;
    }

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      if (kDebugMode) {
        print('User registered: ${credential.user?.email}');
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('FirebaseAuthException register: ${e.code} - ${e.message}');
      }
      rethrow;
    }
  }

  /// Đăng nhập bằng Google (Trang 5, 6)
  Future<UserCredential?> signInWithGoogle() async {
    if (FirebaseService.instance.useMockMode) {
      return null;
    }

    try {
      final GoogleSignInAccount? googleUser = await _ggSignIn.signIn();
      if (googleUser == null) {
        if (kDebugMode) {
          print('Người dùng đã hủy đăng nhập Google');
        }
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (kDebugMode) {
        print('Access token: ${googleAuth.accessToken}');
        print('ID token: ${googleAuth.idToken}');
      }

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      if (kDebugMode) {
        print('User signed in: ${userCredential.user?.displayName}');
        print('Email: ${userCredential.user?.email}');
      }
      return userCredential;
    } catch (e) {
      if (kDebugMode) {
        print('Error during Google Sign-In: $e');
      }
      rethrow;
    }
  }

  /// Đăng nhập với tư cách khách (Guest / Anonymous)
  Future<UserCredential?> signInAnonymously() async {
    if (FirebaseService.instance.useMockMode) {
      return null;
    }
    return await _auth.signInAnonymously();
  }

  /// Gửi mã xác minh SMS đến số điện thoại (Phone Authentication)
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(FirebaseAuthException e) onVerificationFailed,
    required Function(PhoneAuthCredential credential) onVerificationCompleted,
  }) async {
    if (FirebaseService.instance.useMockMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      onCodeSent('mock_verification_id_123456');
      return;
    }

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber.trim(),
      verificationCompleted: onVerificationCompleted,
      verificationFailed: onVerificationFailed,
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  /// Đăng nhập bằng mã OTP nhận được qua SMS
  Future<UserCredential?> signInWithSmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    if (FirebaseService.instance.useMockMode) {
      if (smsCode == '123456' || smsCode.length == 6) {
        return null;
      }
      throw Exception('Mã OTP không hợp lệ (Gợi ý mã mẫu: 123456)');
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode.trim(),
    );
    return await _auth.signInWithCredential(credential);
  }

  /// Quên mật khẩu / Gửi email reset password
  Future<void> sendPasswordResetEmail(String email) async {
    if (FirebaseService.instance.useMockMode) {
      return;
    }
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Đăng xuất
  Future<void> signOut() async {
    _mockUser = null;
    try {
      await _ggSignIn.signOut();
    } catch (_) {}
    try {
      await _auth.signOut();
    } catch (_) {}
  }
}
