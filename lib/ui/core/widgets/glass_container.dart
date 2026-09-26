import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:quest_kalender/ui/core/themes/app_theme.dart';

/// Kontainer bergaya Dark Arcane Glassmorphism:
/// Menampilkan efek kaca buram (frosted glass blur) menggunakan BackdropFilter,
/// border kristal specular rim tipis bergradasi, dan ambient aura glow.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double radius;
  final double blur;
  final double opacity;
  final Color? color;
  final Color? accentColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final Clip clipBehavior;

  const GlassContainer({
    super.key,
    required this.child,
    this.radius = 18,
    this.blur = 0,
    this.opacity = 0.60,
    this.color,
    this.accentColor,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.alignment,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      width: width,
      height: height,
      alignment: alignment,
      padding: padding,
      decoration: AppTheme.glassCardDecoration(
        radius: radius,
        color: color,
        accentColor: accentColor,
        opacity: opacity,
      ),
      child: child,
    );

    if (blur > 0) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        clipBehavior: clipBehavior,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: content,
        ),
      );
    } else {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        clipBehavior: clipBehavior,
        child: content,
      );
    }

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    return content;
  }
}
