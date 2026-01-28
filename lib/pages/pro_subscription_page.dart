import 'package:flutter/material.dart';
import '../theme/starry_theme.dart';

/// Pro 会员订阅页面
class ProSubscriptionPage extends StatefulWidget {
  const ProSubscriptionPage({super.key});

  @override
  State<ProSubscriptionPage> createState() => _ProSubscriptionPageState();
}

class _ProSubscriptionPageState extends State<ProSubscriptionPage> {
  late SubscriptionPlan _selectedPlan;

  @override
  void initState() {
    super.initState();
    // 默认选中年度计划
    _selectedPlan = SubscriptionPlan.yearly;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StarryTheme.darkBackground,
      body: Stack(
        children: [
          // 背景
          Container(
            decoration: const BoxDecoration(
              gradient: StarryTheme.mainBackgroundGradient,
            ),
          ),
          // 内容
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 顶部栏
                    _buildTopBar(),
                    const SizedBox(height: 40),
                    // 主标题
                    _buildHeader(),
                    const SizedBox(height: 40),
                    // Pro Benefits
                    _buildProBenefits(),
                    const SizedBox(height: 40),
                    // 特性列表
                    _buildFeaturesList(),
                    const SizedBox(height: 40),
                    // 订阅计划
                    _buildSubscriptionPlans(),
                    const SizedBox(height: 24),
                    // Continue按钮
                    _buildContinueButton(),
                    const SizedBox(height: 24),
                    // 法律文本
                    _buildLegalText(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 顶部栏
  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        const Text(
          'Get Pro',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        GestureDetector(
          onTap: () {
            // 处理恢复购买
          },
          child: const Text(
            'Restore',
            style: TextStyle(
              color: Color(0xFF999999),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  // 主标题和描述
  Widget _buildHeader() {
    return Column(
      children: [
        const Text(
          'Unleash the Full Power of AI',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Unlimited access all',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFCCCCCC),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  // Pro Benefits 标签
  Widget _buildProBenefits() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            StarryTheme.accentGold.withValues(alpha: 0.1),
            StarryTheme.accentGold.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: StarryTheme.accentGold.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.star,
                color: StarryTheme.accentGold,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                '9 Pro benefits',
                style: TextStyle(
                  color: StarryTheme.accentGold,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Text(
                'Free',
                style: TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: StarryTheme.accentGold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: StarryTheme.accentGold),
                ),
                child: const Text(
                  'Pro',
                  style: TextStyle(
                    color: StarryTheme.accentGold,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 特性列表
  Widget _buildFeaturesList() {
    final features = [
      ('Access to all ', 'AI companions'),
      ('Better memory', ''),
      ('Create your ', 'own characters'),
      ('Better ', 'voice tones selection'),
    ];

    return Column(
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: feature.$1,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      TextSpan(
                        text: feature.$2,
                        style: const TextStyle(
                          color: StarryTheme.accentGold,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Icon(
                Icons.check_circle,
                color: StarryTheme.accentGold,
                size: 24,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // 订阅计划
  Widget _buildSubscriptionPlans() {
    return Column(
      children: [
        _buildSubscriptionCard(
          plan: SubscriptionPlan.monthly,
          duration: '1 month',
          price: '\$14.99',
          period: '/month',
          weeklyPrice: '\$3.50/wk',
          savings: null,
          isSelected: _selectedPlan == SubscriptionPlan.monthly,
          isBestValue: false,
        ),
        const SizedBox(height: 12),
        _buildSubscriptionCard(
          plan: SubscriptionPlan.yearly,
          duration: '12 months',
          price: '\$69.99',
          period: '/year',
          weeklyPrice: '\$1.34/wk',
          savings: 'Save\n87%',
          isSelected: _selectedPlan == SubscriptionPlan.yearly,
          isBestValue: true,
        ),
      ],
    );
  }

  // 订阅卡片
  Widget _buildSubscriptionCard({
    required SubscriptionPlan plan,
    required String duration,
    required String price,
    required String period,
    required String weeklyPrice,
    String? savings,
    required bool isSelected,
    required bool isBestValue,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlan = plan;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    StarryTheme.accentPink.withValues(alpha: 0.15),
                    StarryTheme.accentCyan.withValues(alpha: 0.1),
                  ],
                )
              : LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.05),
                    Colors.white.withValues(alpha: 0.02),
                  ],
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? StarryTheme.accentPink.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 左侧：时长和周价格
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        duration,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        weeklyPrice,
                        style: const TextStyle(
                          color: Color(0xFF999999),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  // 右侧：价格
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: price,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: period,
                              style: const TextStyle(
                                color: Color(0xFF999999),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // 节省标签
                  if (savings != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: StarryTheme.accentGold,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        savings,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Best Value 标签
            if (isBestValue)
              Positioned(
                top: -8,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: StarryTheme.accentGold,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: StarryTheme.accentGold,
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'BEST VALUE',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Continue 按钮
  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // 处理订阅逻辑
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: StarryTheme.accentGold,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Continue',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // 法律文本
  Widget _buildLegalText() {
    return Text(
      'Subscription payments will be charged to your Apple iTunes Store account at confirmation of your purchase and upon commencement of each renewal term. You can cancel your subscription.',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.5),
        fontSize: 12,
        height: 1.5,
      ),
    );
  }
}

enum SubscriptionPlan { monthly, yearly }
