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
        child: widget.child,
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? activeColor.withAlpha(55) : AppTheme.surfaceLighter,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? activeColor : Colors.white10,
            width: selected ? 1.5 : 1.0,
          ),
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
          top: BorderSide(color: AppTheme.primaryGold.withAlpha(38), width: 1),
        ),
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
                          ? AppTheme.primaryGold.withAlpha(32)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryGold.withAlpha(110)
                            : Colors.transparent,
                        width: 1,
                      ),
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
