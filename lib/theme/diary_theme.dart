import 'package:flutter/material.dart';

/// 日记页面专用深色主题配置
class DiaryTheme {
  // 私有构造函数，防止实例化
  DiaryTheme._();

  // ==================== 深色背景系列 ====================
  
  // 页面主背景色 - 纯黑
  static const Color pageBackground = Color(0xFF0F0F0F);
  
  // 卡片/容器背景色 - 深灰
  static const Color cardBackground = Color(0xFF1A1A1A);
  
  // 次级表面背景色
  static const Color surfaceBackground = Color(0xFF252525);

  // ==================== 文字颜色 ====================
  
  // 主标题字体颜色 - 白色
  static const Color titleText = Color(0xFFFFFFFF);
  
  // 正文字体颜色 - 浅灰
  static const Color bodyText = Color(0xFFB3B3B3);
  
  // 次要文字颜色 - 中灰
  static const Color subtitleText = Color(0xFF888888);

  // ==================== 强调色（紫粉配色） ====================
  
  // 主强调色 - 紫色（时间线、重要按钮）
  static const Color primaryAccent = Color(0xFFBB86FC);
  
  // 次强调色 - 粉色（辅助元素、图标）
  static const Color secondaryAccent = Color(0xFFEB8788);
  
  // 选中状态背景色 - 深紫色
  static const Color selectedBackground = Color(0xFF2D1B3D);
  
  // 叠加阴影颜色 - 紫色光晕
  static const Color shadowOverlay = Color(0xFFBB86FC);
  
  // 未选中状态背景色 - 深灰
  static const Color unselectedBackground = Color(0xFF1E1E1E);
  
  // 普通按钮背景色 - 紫色
  static const Color buttonBackground = Color(0xFFBB86FC);
  
  // 普通按钮字体颜色 - 深色
  static const Color buttonText = Color(0xFF0F0F0F);

  // ==================== 日记特殊色 ====================
  
  // 时间线颜色
  static const Color timelineColor = Color(0xFFBB86FC);
  
  // 日记图标颜色
  static const Color diaryIconColor = Color(0xFFEB8788);

  /// 创建选中状态的容器装饰（带紫色光晕）
  static BoxDecoration selectedBoxDecoration({
    double borderRadius = 12,
    bool withShadow = true,
  }) {
    return BoxDecoration(
      color: selectedBackground,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: primaryAccent.withValues(alpha: 0.3),
        width: 1,
      ),
      boxShadow: withShadow
          ? [
              BoxShadow(
                color: primaryAccent.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
    );
  }

  /// 创建未选中状态的容器装饰（深灰卡片）
  static BoxDecoration unselectedBoxDecoration({
    double borderRadius = 12,
    bool withBorder = true,
  }) {
    return BoxDecoration(
      color: unselectedBackground,
      borderRadius: BorderRadius.circular(borderRadius),
      border: withBorder
          ? Border.all(
              color: surfaceBackground,
              width: 1,
            )
          : null,
    );
  }

  /// 创建日记卡片装饰（带微光边框）
  static BoxDecoration diaryCardDecoration({
    double borderRadius = 16,
  }) {
    return BoxDecoration(
      color: cardBackground,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: primaryAccent.withValues(alpha: 0.2),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: primaryAccent.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
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
      shadowColor: primaryAccent.withValues(alpha: 0.4),
    );
  }

  /// 次要按钮样式（粉色）
  static ButtonStyle secondaryButtonStyle({
    double borderRadius = 25,
    EdgeInsetsGeometry? padding,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: secondaryAccent,
      foregroundColor: Colors.white,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      elevation: 4,
      shadowColor: secondaryAccent.withValues(alpha: 0.4),
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
