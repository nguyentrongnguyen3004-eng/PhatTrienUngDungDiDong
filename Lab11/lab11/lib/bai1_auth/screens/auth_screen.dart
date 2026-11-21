import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../auth_service.dart';
import '../../services/firebase_service.dart';
import 'user_profile_screen.dart';
import '../../bai2_storage_upload/screens/upload_screen.dart';
import '../../bai3_product_crud/screens/product_list_screen.dart';
import '../../baitap_venha_zhippay/screens/zhippay_onboarding_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUpMode = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập đầy đủ Email và Mật khẩu.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (FirebaseService.instance.useMockMode) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => UserProfileScreen(
              email: email,
              displayName: email.split('@').first,
              provider: _isSignUpMode ? 'Email/Password (Đăng ký)' : 'Email/Password',
              uid: 'mock_uid_${DateTime.now().millisecondsSinceEpoch}',
            ),
          ),
        );
        return;
      }

      UserCredential? cred;
      if (_isSignUpMode) {
        cred = await AuthService.instance.signUpWithEmailPassword(
          email: email,
          password: password,
        );
      } else {
        cred = await AuthService.instance.signInWithEmailPassword(
          email: email,
          password: password,
        );
      }

      if (cred != null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => UserProfileScreen(
              email: cred?.user?.email ?? email,
              displayName: cred?.user?.displayName ?? email.split('@').first,
              provider: 'Email/Password',
              uid: cred?.user?.uid ?? '',
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found') {
          _errorMessage = 'Tài khoản không tồn tại. Vui lòng tạo tài khoản mới.';
        } else if (e.code == 'wrong-password') {
          _errorMessage = 'Mật khẩu không chính xác.';
        } else if (e.code == 'email-already-in-use') {
          _errorMessage = 'Email này đã được đăng ký trước đó.';
        } else if (e.code == 'weak-password') {
          _errorMessage = 'Mật khẩu quá yếu (tối thiểu 6 ký tự).';
        } else {
          _errorMessage = e.message ?? 'Đã xảy ra lỗi khi xác thực.';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (FirebaseService.instance.useMockMode) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const UserProfileScreen(
              email: 'google_user@gmail.com',
              displayName: 'Demo Google User',
              provider: 'Google Sign-In (Mock)',
              uid: 'mock_google_uid_123',
            ),
          ),
        );
        return;
      }

      final cred = await AuthService.instance.signInWithGoogle();
      if (cred != null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => UserProfileScreen(
              email: cred.user?.email ?? 'Google User',
              displayName: cred.user?.displayName ?? 'Google User',
              provider: 'Google Sign-In',
              uid: cred.user?.uid ?? '',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Đăng nhập Google thất bại: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGuestSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (FirebaseService.instance.useMockMode) {
        await Future.delayed(const Duration(milliseconds: 400));
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const UserProfileScreen(
              email: 'Khách (Guest)',
              displayName: 'Anonymous Guest',
              provider: 'Guest / Anonymous',
              uid: 'mock_guest_999',
            ),
          ),
        );
        return;
      }

      final cred = await AuthService.instance.signInAnonymously();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => UserProfileScreen(
              email: 'Khách ẩn danh',
              displayName: 'Guest User',
              provider: 'Anonymous Auth',
              uid: cred?.user?.uid ?? '',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi đăng nhập khách: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showPhoneAuthDialog() {
    final phoneController = TextEditingController(text: '+84');
    final otpController = TextEditingController();
    String? verificationId;
    bool codeSent = false;
    bool isPhoneLoading = false;
    String? phoneError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Xác thực Số điện thoại (Phone Auth)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (phoneError != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      phoneError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                if (!codeSent) ...[
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Số điện thoại (kèm mã quốc gia)',
                      hintText: '+84 987 654 321',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: isPhoneLoading
                        ? null
                        : () async {
                            final phone = phoneController.text.trim();
                            if (phone.length < 9) {
                              setModalState(() {
                                phoneError = 'Vui lòng nhập số điện thoại hợp lệ';
                              });
                              return;
                            }
                            setModalState(() {
                              isPhoneLoading = true;
                              phoneError = null;
                            });
                            try {
                              await AuthService.instance.verifyPhoneNumber(
                                phoneNumber: phone,
                                onCodeSent: (vId) {
                                  setModalState(() {
                                    verificationId = vId;
                                    codeSent = true;
                                    isPhoneLoading = false;
                                  });
                                },
                                onVerificationFailed: (e) {
                                  setModalState(() {
                                    phoneError = e.message ?? 'Lỗi gửi mã SMS';
                                    isPhoneLoading = false;
                                  });
                                },
                                onVerificationCompleted: (cred) async {
                                  Navigator.of(ctx).pop();
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => UserProfileScreen(
                                        email: phone,
                                        displayName: 'Phone User',
                                        provider: 'Phone Authentication',
                                        uid: cred.smsCode ?? 'phone_auto_verified',
                                      ),
                                    ),
                                  );
                                },
                              );
                            } catch (e) {
                              setModalState(() {
                                phoneError = e.toString();
                                isPhoneLoading = false;
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF3366),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: isPhoneLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Gửi mã OTP qua SMS'),
                  ),
                ] else ...[
                  Text(
                    'Đã gửi mã xác minh 6 số đến ${phoneController.text}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      labelText: 'Nhập mã OTP (6 số)',
                      hintText: '123456',
                      prefixIcon: const Icon(Icons.lock_clock),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: isPhoneLoading
                        ? null
                        : () async {
                            final code = otpController.text.trim();
                            if (code.length < 6) {
                              setModalState(() {
                                phoneError = 'Mã OTP gồm 6 chữ số';
                              });
                              return;
                            }
                            setModalState(() {
                              isPhoneLoading = true;
                              phoneError = null;
                            });
                            try {
                              final cred = await AuthService.instance.signInWithSmsCode(
                                verificationId: verificationId ?? '',
                                smsCode: code,
                              );
                              if (context.mounted) {
                                Navigator.of(ctx).pop();
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => UserProfileScreen(
                                      email: phoneController.text,
                                      displayName: 'Phone User',
                                      provider: 'Phone Authentication',
                                      uid: cred?.user?.uid ?? 'phone_verified',
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              setModalState(() {
                                phoneError = e.toString();
                                isPhoneLoading = false;
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF3366),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: isPhoneLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Xác nhận OTP & Đăng nhập'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header full màn hình tràn viền (Edge-to-Edge) theo đúng giao diện Bài 1
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 36),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF3366), Color(0xFFFF5E62)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
              ),
              child: Column(
                children: [
                  // Thanh điều hướng trên Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                        tooltip: 'Về trang chủ',
                      ),
                      const Text(
                        'Appwrite App',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      // Menu chọn nhanh các bài tập khác
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        tooltip: 'Chuyển bài tập',
                        onSelected: (value) {
                          if (value == 'bai2') {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const UploadScreen()),
                            );
                          } else if (value == 'bai3') {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const ProductListScreen()),
                            );
                          } else if (value == 'zhippay') {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const ZhippayOnboardingScreen()),
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'bai2',
                            child: Row(
                              children: [
                                Icon(Icons.cloud_upload_outlined, color: Colors.blue, size: 20),
                                SizedBox(width: 8),
                                Text('Bài 2: Upload File'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'bai3',
                            child: Row(
                              children: [
                                Icon(Icons.pedal_bike, color: Colors.purple, size: 20),
                                SizedBox(width: 8),
                                Text('Bài 3: Quản lý Sản phẩm'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'zhippay',
                            child: Row(
                              children: [
                                Icon(Icons.account_balance_wallet_outlined, color: Colors.indigo, size: 20),
                                SizedBox(width: 8),
                                Text('Bài về nhà: Ví Zhippay'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isSignUpMode
                        ? 'Tạo tài khoản mới'
                        : 'Đăng nhập vào hệ thống Firebase',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // Form đăng nhập chiếm toàn bộ chiều rộng màn hình (Full Screen Form)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(fontSize: 13, color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Email Field
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Nhập email...',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Nhập mật khẩu...',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sign In / Sign Up Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleEmailAuth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF3366),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.login, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  _isSignUpMode ? 'Sign Up' : 'Sign In',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Switch between Sign In and Create Account
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isSignUpMode = !_isSignUpMode;
                        _errorMessage = null;
                      });
                    },
                    child: Text(
                      _isSignUpMode
                          ? 'Already have an account? Sign In'
                          : 'Create Account',
                      style: const TextStyle(
                        color: Color(0xFFFF3366),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  // Guest Mode
                  TextButton(
                    onPressed: _isLoading ? null : _handleGuestSignIn,
                    child: const Text(
                      'Read Messages as Guest',
                      style: TextStyle(
                        color: Color(0xFFE53935),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Phone Authentication Button
                  OutlinedButton.icon(
                    onPressed: _showPhoneAuthDialog,
                    icon: const Icon(Icons.phone_android, size: 18),
                    label: const Text(
                      'Đăng nhập bằng Số điện thoại (Phone Auth)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFF3366),
                      side: const BorderSide(color: Color(0xFFFF3366)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Social Login Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SocialButton(
                        icon: FontAwesomeIcons.google,
                        color: Colors.red,
                        onTap: _handleGoogleSignIn,
                      ),
                      const SizedBox(width: 16),
                      _SocialButton(
                        icon: FontAwesomeIcons.apple,
                        color: Colors.black,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Apple Sign-In (chỉ hỗ trợ trên iOS)')),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      _SocialButton(
                        icon: FontAwesomeIcons.github,
                        color: const Color(0xFF24292E),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('GitHub OAuth Provider')),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      _SocialButton(
                        icon: FontAwesomeIcons.twitter,
                        color: const Color(0xFF1DA1F2),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Twitter / X OAuth Provider')),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final FaIconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: FaIcon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}
