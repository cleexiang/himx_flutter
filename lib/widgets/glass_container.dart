import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/starry_theme.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double opacity;
  final double blur;
  final Border? border;
  final LinearGradient? gradient;

  const GlassContainer({
    super.key,
    required this.child,
    this.width = double.infinity,
    this.height,
    this.borderRadius,
    this.padding,
    this.opacity = 0.2,
    this.blur = 10.0,
    this.border,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05), // Fallback/Base
            gradient: gradient ?? StarryTheme.glassGradient(opacity: opacity),
            borderRadius: borderRadius ?? BorderRadius.circular(20),
            border:
                border ??
                Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1.0,
                ),
          ),
          child: child,
        ),
      ),
    );
  }
}
