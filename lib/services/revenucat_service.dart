import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter/foundation.dart';

class RevenueCatService {
  // NOTE: Replace this with your actual RevenueCat API Key from https://dashboard.revenuecat.com/
  // Format should be: pk_prod_XXXXX or pk_test_XXXXX or test_XXXXX
  static const String _apiKey = 'test_CAkMvkRlcWXZcKBeWszBdhchAmb';

  static final RevenueCatService _instance = RevenueCatService._internal();

  factory RevenueCatService() {
    return _instance;
  }

  RevenueCatService._internal();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('RevenueCat already initialized');
      return;
    }

    try {
      debugPrint('RevenueCatService: Starting initialization with API Key: ${_apiKey.substring(0, 10)}...');

      // 配置Purchases SDK
      debugPrint('RevenueCatService: Setting log level to debug');
      await Purchases.setLogLevel(LogLevel.debug);
      debugPrint('RevenueCatService: Log level set');

      // 初始化RevenueCat
      debugPrint('RevenueCatService: Creating PurchasesConfiguration');
      PurchasesConfiguration configuration = PurchasesConfiguration(_apiKey);

      debugPrint('RevenueCatService: Configuring Purchases');
      await Purchases.configure(configuration);

      _isInitialized = true;
      debugPrint('✅ RevenueCat initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing RevenueCat: $e');
      debugPrint('Error type: ${e.runtimeType}');
      _isInitialized = false;
      rethrow;
    }
  }

  /// 获取所有可用的套餐
  Future<List<Package>> getPackages() async {
    try {
      debugPrint('RevenueCatService: Fetching offerings');
      Offerings offerings = await Purchases.getOfferings();
      debugPrint('RevenueCatService: Got offerings, current offering: ${offerings.current?.identifier}');

      if (offerings.current != null) {
        List<Package> packages = offerings.current!.availablePackages;
        debugPrint('RevenueCatService: Found ${packages.length} packages');
        for (var pkg in packages) {
          debugPrint('  - Package: ${pkg.identifier}');
        }
        return packages;
      }
      debugPrint('RevenueCatService: No current offering available');
      return [];
    } catch (e) {
      debugPrint('❌ Error getting packages: $e');
      debugPrint('Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  /// 根据套餐ID购买
  Future<CustomerInfo> purchasePackage(Package package) async {
    try {
      PurchaseResult result = await Purchases.purchase(PurchaseParams.package(package));
      debugPrint('Purchase successful: ${result.customerInfo.activeSubscriptions}');
      return result.customerInfo;
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('Purchase cancelled by user');
      } else {
        debugPrint('Purchase error: ${e.toString()}');
      }
      rethrow;
    }
  }

  /// 恢复之前的购买
  Future<CustomerInfo> restorePurchases() async {
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      debugPrint('Purchases restored successfully');
      return customerInfo;
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
      rethrow;
    }
  }

  /// 获取当前客户信息（包括订阅和购买信息）
  Future<CustomerInfo> getCustomerInfo() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      return customerInfo;
    } catch (e) {
      debugPrint('Error getting customer info: $e');
      rethrow;
    }
  }

  /// 获取用户的积分余额（根据购买历史计算）
  Future<int> getUserCoinsBalance() async {
    try {
      debugPrint('RevenueCatService: Fetching customer info for coins balance');
      CustomerInfo customerInfo = await getCustomerInfo();
      debugPrint('RevenueCatService: Got customer info, entitlements count: ${customerInfo.entitlements.all.length}');

      // 计算用户的总积分
      // 这里假设非消耗性产品对应积分数量
      int totalCoins = 0;

      for (var entitlement in customerInfo.entitlements.all.values) {
        debugPrint('RevenueCatService: Checking entitlement: ${entitlement.identifier}, isActive: ${entitlement.isActive}');
        if (entitlement.isActive) {
          // 根据entitlement ID映射到积分数量
          int coins = _getCoinsForEntitlement(entitlement.identifier);
          debugPrint('RevenueCatService: Added $coins coins for ${entitlement.identifier}');
          totalCoins += coins;
        }
      }

      debugPrint('RevenueCatService: Total coins calculated: $totalCoins');
      return totalCoins;
    } catch (e) {
      debugPrint('❌ Error getting coins balance: $e');
      debugPrint('Error type: ${e.runtimeType}');
      return 0;
    }
  }

  /// 根据entitlement ID获取对应的积分数量
  int _getCoinsForEntitlement(String entitlementId) {
    switch (entitlementId) {
      case 'coins_10':
        return 10;
      case 'coins_50':
        return 50;
      case 'coins_100':
        return 100;
      case 'coins_500':
        return 500;
      case 'coins_1000':
        return 1000;
      case 'coins_2000':
        return 2000;
      default:
        return 0;
    }
  }

  /// 获取特定的套餐对象
  Future<Package?> getPackageById(String packageIdentifier) async {
    try {
      List<Package> packages = await getPackages();
      for (var package in packages) {
        if (package.identifier == packageIdentifier) {
          return package;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting package by ID: $e');
      return null;
    }
  }
}
