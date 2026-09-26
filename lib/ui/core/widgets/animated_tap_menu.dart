import 'package:flutter/material.dart';
import 'package:quest_kalender/ui/core/themes/app_theme.dart';

/// Widget pembungkus ringan (GPU transform only, 0 layout rebuild) yang
/// memberikan efek tekan halus (press scale) dan pantulan ringan saat dipilih.
class AnimatedPressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool isSelected;
  final double pressedScale;
  final double selectedScale;
  final BorderRadius? borderRadius;

  const AnimatedPressScale({
    super.key,
    required this.child,
    this.onTap,
    this.isSelected = false,
    this.pressedScale = 0.94,
    this.selectedScale = 1.03,
    this.borderRadius,
  });

  @override
  State<AnimatedPressScale> createState() => _AnimatedPressScaleState();
}

class _AnimatedPressScaleState extends State<AnimatedPressScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final targetScale = _pressed
        ? widget.pressedScale
        : (widget.isSelected ? widget.selectedScale : 1.0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.onTap != null
          ? (_) => setState(() => _pressed = true)
          : null,
      onTapUp: widget.onTap != null
          ? (_) => setState(() => _pressed = false)
          : null,
      onTapCancel: widget.onTap != null
          ? () => setState(() => _pressed = false)
          : null,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: targetScale,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        child: AnimatedSlide(
          offset: _pressed ? const Offset(0, 0.02) : Offset.zero,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Chip menu pilihan dengan animasi warna, border, dan skala yang ringan (60fps+).
class AnimatedMenuChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color activeColor;
  final bool selected;
  final VoidCallback onTap;

  const AnimatedMenuChip({
    super.key,
    required this.label,
    this.icon,
    required this.activeColor,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPressScale(
      isSelected: selected,
      selectedScale: 1.03,
      pressedScale: 0.94,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? activeColor.withAlpha(65) : AppTheme.surfaceLighter,
          borderRadius: BorderRadius.circular(14),
          gradient: selected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    activeColor.withAlpha(90),
                    activeColor.withAlpha(45),
                  ],
                )
              : null,
          border: Border.all(
            color: selected ? activeColor : Colors.white.withAlpha(24),
            width: selected ? 1.5 : 1.0,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: activeColor.withAlpha(90),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.white.withAlpha(50),
                    blurRadius: 3,
                    offset: const Offset(0, -1),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(60),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              AnimatedScale(
                scale: selected ? 1.12 : 1.0,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                child: Icon(
                  icon,
                  size: 14,
                  color: selected ? activeColor : activeColor.withAlpha(200),
                ),
              ),
              const SizedBox(width: 6),
            ],
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
                fontSize: 12,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                color: selected ? activeColor : Colors.white70,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

/// Item data untuk Bottom Navigation Bar beranimasi ringan.
class AnimatedNavItem {
  final IconData icon;
  final String label;

  const AnimatedNavItem({required this.icon, required this.label});
}

/// Bottom Navigation Bar RPG dengan animasi pilih menu yang halus namun sangat ringan.
class AnimatedRpgBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AnimatedNavItem> items;

  const AnimatedRpgBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        border: Border(
          top: BorderSide(color: Colors.white.withAlpha(25), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(120),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = currentIndex == index;

              return Expanded(
                child: AnimatedPressScale(
                  isSelected: false,
                  pressedScale: 0.93,
                  onTap: () => onTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryGold.withAlpha(45)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      gradient: isSelected
                          ? LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppTheme.primaryGold.withAlpha(60),
                                AppTheme.primaryGold.withAlpha(25),
                              ],
                            )
                          : null,
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryGold.withAlpha(120)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppTheme.primaryGold.withAlpha(60),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                              BoxShadow(
                                color: Colors.white.withAlpha(50),
                                blurRadius: 3,
                                offset: const Offset(0, -1),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSlide(
                          offset: isSelected
                              ? const Offset(0, -0.05)
                              : Offset.zero,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          child: AnimatedScale(
                            scale: isSelected ? 1.14 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutCubic,
                            child: Icon(
                              item.icon,
                              size: 22,
                              color: isSelected
                                  ? AppTheme.primaryGold
                                  : AppTheme.textMuted,
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          style: TextStyle(
                            fontFamily: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.fontFamily,
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected
                                ? AppTheme.primaryGold
                                : AppTheme.textMuted,
                          ),
                          child: Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
