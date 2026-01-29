import 'package:flutter/material.dart';
import 'package:himx/pages/home_page.dart';
import 'package:himx/pages/login_screen.dart';
import 'package:himx/services/auth_service.dart';
import 'package:himx/services/himx_api.dart';
import 'package:himx/theme/app_theme.dart';

/// 启动页 - 检查登录状态并导航
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final AuthService _authService = AuthService();
  final HimxApi _himxApi = HimxApi();

  @override
  void initState() {
    super.initState();

    // 初始化动画
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();

    // 延迟到下一帧再初始化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAndNavigate();
    });
  }

  Future<void> _initializeAndNavigate() async {
    // 初始化认证服务
    await _authService.init();

    // 等待动画完成（至少2秒）
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // 根据登录状态导航
    if (_authService.isLoggedIn) {
      // 已登录 -> 先获取最新用户信息，再进入主页
      try {
        final userInfo = await _himxApi.getUserInfo();
        // 更新本地用户信息
        await _authService.updateUser(userInfo);

        if (!mounted) return;
        // 进入主页
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
      } catch (e) {
        debugPrint('Failed to fetch user info: $e');
        if (!mounted) return;
        // 获取用户信息失败，返回登录页
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    } else {
      // 未登录 -> 进入登录页
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.pageBackground,
              AppTheme.unselectedBackground,
              AppTheme.selectedBackground.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo或App名称
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.selectedBackground,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.shadowOverlay.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.favorite, size: 60, color: AppTheme.buttonText),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Date Him',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.titleText,
                      fontFamily: 'IBMPlexSans',
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Find your perfect match',
                    style: TextStyle(fontSize: 16, color: AppTheme.bodyText, fontFamily: 'IBMPlexSans'),
                  ),
                  const SizedBox(height: 50),
                  // Loading indicator
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.shadowOverlay),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
