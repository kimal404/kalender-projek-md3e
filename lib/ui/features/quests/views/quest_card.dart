import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quest_kalender/domain/models/quest_model.dart';
import 'package:quest_kalender/ui/core/themes/app_theme.dart';

/// QuestCard dengan animasi elegan:
/// - Stagger slide-up entrance berdasarkan index
/// - Spring-bounce checkbox dengan TweenSequence physics
/// - Glow shadow pulsing pada kartu aktif
/// - Reward badge fade-out halus saat quest selesai
class QuestCard extends StatefulWidget {
  final Quest quest;
  final VoidCallback onToggleComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  /// Index untuk stagger delay animasi entrance
  final int index;

  const QuestCard({
    super.key,
    required this.quest,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
    this.index = 0,
  });

  @override
  State<QuestCard> createState() => _QuestCardState();
}

class _QuestCardState extends State<QuestCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _fadeAnim = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );

    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Stagger delay berdasarkan index kartu
    final delay = Duration(milliseconds: 40 + widget.index * 55);
    Future.delayed(delay, () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rankColor = widget.quest.rank.color;
    final isDone = widget.quest.isCompleted;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDone
                ? AppTheme.cardBackground.withAlpha(130)
                : AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDone
                  ? AppTheme.surfaceLighter.withAlpha(70)
                  : rankColor.withAlpha(130),
              width: 1.5,
            ),
            boxShadow: isDone
                ? []
                : [
                    BoxShadow(
                      color: rankColor.withAlpha(30),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: rankColor.withAlpha(10),
                      blurRadius: 22,
                      spreadRadius: 2,
                      offset: Offset.zero,
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              splashColor: rankColor.withAlpha(25),
              highlightColor: rankColor.withAlpha(10),
              onTap: widget.onEdit,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 380),
                      width: 6,
                      decoration: BoxDecoration(
                        color: isDone
                            ? AppTheme.textMuted.withAlpha(90)
                            : rankColor,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(16),
                        ),
                        boxShadow: isDone
                            ? null
                            : [
                                BoxShadow(
                                  color: rankColor.withAlpha(120),
                                  blurRadius: 8,
                                ),
                              ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ─── Checkbox dengan spring-bounce physics ───
                            Padding(
                              padding: const EdgeInsets.only(top: 2, right: 12),
                              child: _SpringCheckbox(
                                isDone: isDone,
                                onTap: widget.onToggleComplete,
                              ),
                            ),

                            // ─── Detail Quest ───
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header: Rank badge & Kategori
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: rankColor.withAlpha(40),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          border: Border.all(
                                            color: rankColor,
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          'RANK ${widget.quest.rank.code}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: rankColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            widget.quest.category.icon,
                                            size: 13,
                                            color: widget.quest.category.color,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            widget.quest.category.label,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color:
                                                  widget.quest.category.color,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      if (widget.quest.startTime != null)
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.access_time,
                                              size: 12,
                                              color: AppTheme.textMuted,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              widget.quest.endTime != null
                                                  ? '${widget.quest.startTime} - ${widget.quest.endTime}'
                                                  : widget.quest.startTime!,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: AppTheme.textMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // Judul dengan strikethrough animasi
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 350),
                                    curve: Curves.easeInOut,
                                    style: TextStyle(
                                      fontFamily: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.fontFamily,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDone
                                          ? AppTheme.textMuted
                                          : Colors.white,
                                      decoration: isDone
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                      decorationColor: AppTheme.textMuted,
                                      decorationThickness: 2,
                                    ),
                                    child: Text(widget.quest.title),
                                  ),

                                  if (widget.quest.description.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    AnimatedOpacity(
                                      duration: const Duration(
                                        milliseconds: 350,
                                      ),
                                      opacity: isDone ? 0.45 : 0.85,
                                      child: Text(
                                        widget.quest.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 10),

                                  // Reward badges + menu
                                  Row(
                                    children: [
                                      _RewardBadge(
                                        icon: Icons.bolt,
                                        label: '+${widget.quest.expReward} EXP',
                                        color: AppTheme.neonPurple,
                                        isDone: isDone,
                                      ),
                                      const SizedBox(width: 6),
                                      _RewardBadge(
                                        icon: Icons.monetization_on,
                                        label: '+${widget.quest.coinReward} G',
                                        color: AppTheme.primaryGold,
                                        isDone: isDone,
                                      ),
                                      const Spacer(),
                                      PopupMenuButton<String>(
                                        icon: const Icon(
                                          Icons.more_vert,
                                          size: 18,
                                          color: AppTheme.textMuted,
                                        ),
                                        color: AppTheme.surfaceLighter,
                                        padding: EdgeInsets.zero,
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            widget.onEdit();
                                          } else if (value == 'delete') {
                                            widget.onDelete();
                                          }
                                        },
                                        itemBuilder: (ctx) => [
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.edit,
                                                  size: 16,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(width: 8),
                                                Text('Ubah Quest'),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.delete,
                                                  size: 16,
                                                  color: Colors.redAccent,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Hapus Quest',
                                                  style: TextStyle(
                                                    color: Colors.redAccent,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Checkbox dengan TweenSequence spring-bounce physics
// ─────────────────────────────────────────────────────────────
class _SpringCheckbox extends StatefulWidget {
  final bool isDone;
  final VoidCallback onTap;

  const _SpringCheckbox({required this.isDone, required this.onTap});

  @override
  State<_SpringCheckbox> createState() => _SpringCheckboxState();
}

class _SpringCheckboxState extends State<_SpringCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    // Squish → overshoot → settle (spring physics)
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.72,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.72,
          end: 1.22,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.22,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.isDone) {
      HapticFeedback.selectionClick();
    } else {
      HapticFeedback.mediumImpact();
    }
    _controller.forward(from: 0.0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: widget.isDone
                ? AppTheme.primaryGold
                : AppTheme.surfaceLighter,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isDone
                  ? AppTheme.primaryGold
                  : AppTheme.textMuted.withAlpha(100),
              width: 2,
            ),
            boxShadow: widget.isDone
                ? [
                    BoxShadow(
                      color: AppTheme.primaryGold.withAlpha(110),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 230),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
              child: child,
            ),
            child: widget.isDone
                ? const Icon(
                    Icons.check,
                    key: ValueKey('done_icon'),
                    size: 18,
                    color: Colors.black,
                  )
                : const SizedBox(key: ValueKey('empty_icon')),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Reward badge dengan smooth fade saat quest selesai
// ─────────────────────────────────────────────────────────────
class _RewardBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDone;

  const _RewardBadge({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: isDone ? 0.4 : 1.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withAlpha(isDone ? 12 : 30),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
