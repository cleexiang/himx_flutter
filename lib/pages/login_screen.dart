import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:himx/models/user_model.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:himx/pages/home_page.dart';
import 'package:himx/services/api_client.dart';
import 'package:himx/services/auth_service.dart';
import 'package:himx/theme/app_theme.dart';

/// 登录页面 - Apple 登录
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final ApiClient _apiClient = ApiClient();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // 淡入动画
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    // 滑入动画
    _slideController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<bool> _isSimulator() async {
    if (Platform.isIOS) {
      final deviceInfo = await DeviceInfoPlugin().iosInfo;
      return !deviceInfo.isPhysicalDevice;
    }
    return false;
  }

  /// Apple 登录
  Future<void> _loginWithApple() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String userIdentifier;
      String email;
      String fullName;
      if (Platform.isIOS && !await _isSimulator()) {
        final credential = await SignInWithApple.getAppleIDCredential(
          scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
        );
        userIdentifier = credential.userIdentifier ?? '';
        email = credential.email ?? '';
        fullName = (credential.familyName ?? '') + (credential.givenName ?? '');
      } else {
        userIdentifier = '000437.b0fdbdd7e5b149dbac557fbe7f1940ae.0923';
        email = 'mock@example.com';
        fullName = 'Mock User';
      }
      if (userIdentifier.isEmpty) {
        throw Exception('Failed to get Apple user ID');
      }

      final data = {'user': userIdentifier, 'email': email, 'fullName': fullName};

      final userInfo = await _apiClient.post<UserInfo>(
        path: '/auth/login/apple',
        data: data,
        fromJson: (dynamic json) => UserInfo.fromJson(json as Map<String, dynamic>),
      );

      if (userInfo.token != null) {
        // 保存用户信息
        await _authService.saveUser(userInfo, userInfo.token!);

        if (!mounted) return;

        // 导航到首页
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
      } else {
        throw Exception('未返回有效的token');
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      setState(() {
        _isLoading = false;
        if (e.code == AuthorizationErrorCode.canceled) {
          _errorMessage = '登录已取消';
        } else {
          _errorMessage = 'Apple 登录失败: ${e.message}';
        }
      });

      if (mounted && e.code != AuthorizationErrorCode.canceled) {
        _showErrorSnackBar(_errorMessage!);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '登录失败: $e';
      });

      if (mounted) {
        _showErrorSnackBar(_errorMessage!);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.pageBackground,
              AppTheme.unselectedBackground,
              AppTheme.selectedBackground.withValues(alpha: 0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      _buildLogo(),
                      const SizedBox(height: 40),

                      // 标题
                      const Text(
                        'Welcome to Date Him',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.titleText,
                          fontFamily: 'IBMPlexSans',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),

                      // 副标题
                      const Text(
                        'Your AI dating companion awaits',
                        style: TextStyle(fontSize: 16, color: AppTheme.bodyText, fontFamily: 'IBMPlexSans'),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 60),

                      // Apple 登录按钮
                      _buildAppleLoginButton(),

                      const SizedBox(height: 20),

                      // 错误提示
                      if (_errorMessage != null) _buildErrorMessage(),

                      const SizedBox(height: 40),

                      // 隐私政策提示
                      _buildPrivacyNote(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Logo
  Widget _buildLogo() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: AppTheme.selectedBackground,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: AppTheme.shadowOverlay.withValues(alpha: 0.4), blurRadius: 30, spreadRadius: 5)],
      ),
      child: const Icon(Icons.favorite, size: 70, color: AppTheme.buttonText),
    );
  }

  /// Apple 登录按钮
  Widget _buildAppleLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _loginWithApple,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          elevation: 4,
          shadowColor: Colors.black.withValues(alpha: 0.3),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.apple, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  const Text(
                    'Sign in with Apple',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'IBMPlexSans',
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// 错误提示
  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(_errorMessage!, style: TextStyle(fontSize: 14, color: Colors.red.shade700)),
          ),
        ],
      ),
    );
  }

  /// 隐私政策提示
  Widget _buildPrivacyNote() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'By continuing, you agree to our Terms of Service and Privacy Policy',
        style: TextStyle(fontSize: 12, color: AppTheme.bodyText.withValues(alpha: 0.6), fontFamily: 'IBMPlexSans'),
        textAlign: TextAlign.center,
      ),
    );
  }
}
