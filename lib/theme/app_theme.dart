import 'package:flutter/material.dart';

/// 应用统一主题配置
class AppTheme {
  // 私有构造函数，防止实例化
  AppTheme._();

  // 页面主背景色
  static const Color pageBackground = Color(0xFFFFF4E9);

  // 主标题字体颜色
  static const Color titleText = Color(0xFF553630);

  // 正文字体颜色
  static const Color bodyText = Color(0xFF333333);

  // 选中状态背景色
  static const Color selectedBackground = Color(0xFFFFBCBA);

  // 叠加阴影颜色
  static const Color shadowOverlay = Color(0xFFEB8788);

  // 未选中状态背景色
  static const Color unselectedBackground = Color(0xFFFFE6D0);

  // 普通按钮背景色
  static const Color buttonBackground = Color(0xFFEB8788);

  // 普通按钮字体颜色
  static const Color buttonText = Color(0xFF1C1E21);

  /// 创建带阴影的容器装饰
  static BoxDecoration selectedBoxDecoration({
    double borderRadius = 12,
    bool withShadow = true,
  }) {
    return BoxDecoration(
      color: selectedBackground,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: withShadow
          ? [
              BoxShadow(
                color: shadowOverlay.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
    );
  }

  /// 创建未选中状态的容器装饰
  static BoxDecoration unselectedBoxDecoration({
    double borderRadius = 12,
  }) {
    return BoxDecoration(
      color: unselectedBackground,
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }

  /// 创建普通按钮样式
  static ButtonStyle primaryButtonStyle({
    double borderRadius = 25,
    EdgeInsetsGeometry? padding,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: buttonBackground,
      foregroundColor: buttonText,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      elevation: 4,
      shadowColor: shadowOverlay.withValues(alpha: 0.3),
    );
  }

  /// 标题文本样式
  static const TextStyle titleTextStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: titleText,
    fontFamily: 'IBMPlexSans',
  );

  /// 正文文本样式
  static const TextStyle bodyTextStyle = TextStyle(
    fontSize: 16,
    color: bodyText,
    fontFamily: 'IBMPlexSans',
  );

  /// 按钮文本样式
  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: buttonText,
    fontFamily: 'IBMPlexSans',
  );
}
