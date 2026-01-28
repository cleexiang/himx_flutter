import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../theme/starry_theme.dart';
import '../services/revenucat_service.dart';
import 'pro_subscription_page.dart';

/// 金币购买页面
class CoinsPurchasePage extends StatefulWidget {
  const CoinsPurchasePage({super.key});

  @override
  State<CoinsPurchasePage> createState() => _CoinsPurchasePageState();
}

class _CoinsPurchasePageState extends State<CoinsPurchasePage> {
  bool _isLoading = true;
  bool _isPurchasing = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _userCoinsBalance = 0;
  final RevenueCatService _revenueCatService = RevenueCatService();
  late List<Package> _revenueCatPackages;

  // 4个档次的积分购买选项（本地配置，用于显示）
  final Map<String, CoinPackage> _coinPackagesMap = {
    'coins_300': CoinPackage(id: 'coins_300', coins: 300, price: 2.99, originalPrice: 0, discount: ''),
    'coins_1050': CoinPackage(id: 'coins_1050', coins: 1050, price: 9.99, originalPrice: 10, discount: '5% Off'),
    'coins_3100': CoinPackage(
      id: 'coins_3100',
      coins: 3100,
      price: 24.99,
      originalPrice: 31,
      discount: '20% Off',
      isPopular: true,
    ),
    'coins_10000': CoinPackage(
      id: 'coins_10000',
      coins: 10000,
      price: 69.99,
      originalPrice: 100,
      discount: '30% Off',
    ),
  };

  late List<CoinPackage> _coinPackages;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      debugPrint('=== CoinsPurchasePage: Starting data load ===');

      // 初始化RevenueCat
      debugPrint('Step 1: Initializing RevenueCat...');
      await _revenueCatService.initialize();
      debugPrint('Step 1: RevenueCat initialized successfully');

      // 获取RevenueCat套餐
      debugPrint('Step 2: Fetching packages from RevenueCat...');
      _revenueCatPackages = await _revenueCatService.getPackages();
      debugPrint('Step 2: Fetched ${_revenueCatPackages.length} packages');

      // 构建显示用的包列表，按照本地定义的顺序
      debugPrint('Step 3: Building coin packages list...');
      _coinPackages = [
        _coinPackagesMap['coins_300']!,
        _coinPackagesMap['coins_1050']!,
        _coinPackagesMap['coins_3100']!,
        _coinPackagesMap['coins_10000']!,
      ];
      debugPrint('Step 3: Coin packages list created');

      // 获取用户积分余额
      debugPrint('Step 4: Fetching user coins balance...');
      _userCoinsBalance = await _revenueCatService.getUserCoinsBalance();
      debugPrint('Step 4: User coins balance: $_userCoinsBalance');

      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = false;
        });
        debugPrint('=== CoinsPurchasePage: Data load completed successfully ===');
      }
    } catch (e) {
      debugPrint('❌ Error loading data: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StarryTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: StarryTheme.darkBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Coins store',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: StarryTheme.accentGold,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.monetization_on, color: Colors.black, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '$_userCoinsBalance',
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: StarryTheme.accentPink))
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                      const SizedBox(height: 16),
                      const Text(
                        '加载失败',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _hasError = false;
                          });
                          _loadData();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: StarryTheme.accentPink,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        ),
                        child: const Text('重试', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProCard(),
                      const SizedBox(height: 16),
                      _buildPackagesGrid(),
                      const SizedBox(height: 16),
                      _buildContinueButton(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
    );
  }

  // Pro订阅卡片
  Widget _buildProCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            StarryTheme.purpleCardBg.withValues(alpha: 0.8),
            StarryTheme.purpleCardBg.withValues(alpha: 0.5),
          ],
        ),
        border: Border.all(
          color: StarryTheme.accentPink,
          width: 1.5,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Rosytalk ',
                        style: TextStyle(color: StarryTheme.accentGold, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: StarryTheme.accentGold,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Pro',
                          style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.check, color: StarryTheme.accentGold, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'Unlimited messages',
                        style: TextStyle(color: StarryTheme.accentGold, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.check, color: StarryTheme.accentGold, size: 14),
                      const SizedBox(width: 6),
                      const Text(
                        'Claim ',
                        style: TextStyle(color: StarryTheme.accentGold, fontSize: 12),
                      ),
                      const Icon(Icons.monetization_on, color: StarryTheme.accentGold, size: 12),
                      const Text(
                        ' 1500 instantly',
                        style: TextStyle(color: StarryTheme.accentGold, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProSubscriptionPage()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: StarryTheme.accentGold,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Join',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 产品网格
  Widget _buildPackagesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _coinPackages.length,
      itemBuilder: (context, index) => _buildCoinPackageCard(_coinPackages[index]),
    );
  }

  // 单个产品卡片
  Widget _buildCoinPackageCard(CoinPackage package) {
    return GestureDetector(
      onTap: _isPurchasing ? null : () => _purchaseCoinPackage(package),
      child: Opacity(
        opacity: _isPurchasing ? 0.6 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            gradient: package.isPopular
                ? LinearGradient(
                    colors: [
                      StarryTheme.purpleCardBg.withValues(alpha: 0.9),
                      StarryTheme.purpleCardBg.withValues(alpha: 0.6),
                    ],
                  )
                : LinearGradient(
                    colors: [
                      StarryTheme.purpleCardBg.withValues(alpha: 0.6),
                      StarryTheme.purpleCardBg.withValues(alpha: 0.3),
                    ],
                  ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: package.isPopular ? StarryTheme.accentPink : StarryTheme.accentCyan.withValues(alpha: 0.3),
              width: package.isPopular ? 2 : 1,
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 金币图标
                    _buildCoinIcon(package.coins),
                    // 金币数量
                    Text(
                      '${package.coins}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // 价格
                    Column(
                      children: [
                        Text(
                          '\$${package.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: StarryTheme.accentGold,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (package.originalPrice > 0)
                          Text(
                            '\$${package.originalPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 10,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // 折扣标签
              if (package.discount.isNotEmpty)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: const BoxDecoration(
                      color: StarryTheme.accentGold,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                    child: Text(
                      package.discount,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 金币图标 - 根据数量显示不同的视觉效果
  Widget _buildCoinIcon(int coins) {
    if (coins <= 1050) {
      return const Icon(Icons.monetization_on, color: StarryTheme.accentGold, size: 40);
    } else if (coins <= 3100) {
      return SizedBox(
        height: 48,
        width: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.monetization_on, color: StarryTheme.accentGold, size: 40),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(1),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.monetization_on, color: StarryTheme.accentGold, size: 20),
              ),
            ),
          ],
        ),
      );
    } else {
      return SizedBox(
        height: 48,
        width: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.monetization_on, color: StarryTheme.accentGold, size: 40),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(1),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.monetization_on, color: StarryTheme.accentGold, size: 20),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.all(1),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.monetization_on, color: StarryTheme.accentGold, size: 16),
              ),
            ),
          ],
        ),
      );
    }
  }

  // 继续按钮
  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isPurchasing ? null : () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.1),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          side: const BorderSide(color: StarryTheme.accentCyan, width: 1.5),
        ),
        child: const Text(
          'Continue',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  Future<void> _purchaseCoinPackage(CoinPackage package) async {
    setState(() => _isPurchasing = true);

    try {
      // 从RevenueCat包列表中查找对应的套餐
      Package? revenueCatPackage;
      for (var pkg in _revenueCatPackages) {
        if (pkg.identifier == package.id) {
          revenueCatPackage = pkg;
          break;
        }
      }

      if (revenueCatPackage == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('套餐不可用，请重试'), backgroundColor: Colors.red.shade700),
        );
        return;
      }

      // 执行购买
      await _revenueCatService.purchasePackage(revenueCatPackage);

      if (!mounted) return;

      // 购买成功后刷新用户余额
      int newBalance = await _revenueCatService.getUserCoinsBalance();
      setState(() => _userCoinsBalance = newBalance);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('成功购买 ${package.coins} 积分！'), backgroundColor: Colors.green.shade700),
      );
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) {
        // 用户取消购买，不显示错误信息
        return;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('购买失败: ${e.toString()}'), backgroundColor: Colors.red.shade700),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('购买失败，请重试'), backgroundColor: Colors.red.shade700),
      );
      debugPrint('Purchase error: $e');
    } finally {
      if (mounted) {
        setState(() => _isPurchasing = false);
      }
    }
  }
}

/// 金币套餐数据模型
class CoinPackage {
  final String id;
  final int coins;
  final double price;
  final double originalPrice;
  final String discount;
  final bool isPopular;

  CoinPackage({
    required this.id,
    required this.coins,
    required this.price,
    required this.originalPrice,
    this.discount = '',
    this.isPopular = false,
  });
}
