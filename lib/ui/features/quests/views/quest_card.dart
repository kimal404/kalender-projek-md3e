import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quest_kalender/domain/models/quest_model.dart';
import 'package:quest_kalender/ui/core/themes/app_theme.dart';

/// QuestCard dengan animasi elegan dan gaya Dark Arcane Glassmorphism:
/// - Frosted glass blur (BackdropFilter)
/// - Specular highlight crystal border
/// - Stagger slide-up entrance berdasarkan index
/// - Spring-bounce checkbox dengan TweenSequence physics
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
      duration: const Duration(milliseconds: 320),
    );

    _fadeAnim = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );

    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Stagger delay berdasarkan index kartu (dioptimalkan agar instan & halus)
    final delay = Duration(milliseconds: (widget.index * 25).clamp(0, 100));
    if (widget.index == 0) {
      _entranceController.forward();
    } else {
      Future.delayed(delay, () {
        if (mounted) _entranceController.forward();
      });
    }
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
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AnimatedContainer(
                duration: const Duration(milliseconds: 380),
                curve: Curves.easeOutCubic,
                decoration: isDone
                    ? BoxDecoration(
                        color: const Color(0xFF141933).withAlpha(120),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withAlpha(22),
                          width: 1.0,
                        ),
                      )
                    : AppTheme.glassCardDecoration(
                        accentColor: rankColor,
                        radius: 18,
                        opacity: 0.58,
                      ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    splashColor: rankColor.withAlpha(25),
                    highlightColor: rankColor.withAlpha(10),
                    onTap: widget.onEdit,
              child: Stack(
                children: [
                  // Konten detail quest
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
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
                                        icon: isDone
                                            ? Icons.lock_outline_rounded
                                            : Icons.verified_user_outlined,
                                        label: isDone
                                            ? 'Terkunci (1x Pakai)'
                                            : '1x Pakai',
                                        color: isDone
                                            ? const Color(0xFF69F0AE)
                                            : AppTheme.neonCyan,
                                        isDone: false,
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
                                          if (!isDone)
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
                  // Indikator garis rank di sisi kiri kartu
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 6,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 380),
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
                                  blurRadius: 6,
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
  ),
);
  }
}

// ─────────────────────────────────────────────────────────────
// Checkbox dengan TweenSequence spring-bounce physics bergaya Crystal Glass
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
                : const Color(0xFF141933).withAlpha(160),
            borderRadius: BorderRadius.circular(10),
            gradient: widget.isDone
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFD54F), AppTheme.primaryGold],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withAlpha(20),
                      const Color(0xFF141933).withAlpha(160),
                    ],
                  ),
            border: Border.all(
              color: widget.isDone
                  ? Colors.white.withAlpha(200)
                  : Colors.white.withAlpha(40),
              width: 1.4,
            ),
            boxShadow: widget.isDone
                ? [
                    BoxShadow(
                      color: AppTheme.primaryGold.withAlpha(130),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                    BoxShadow(
                      color: Colors.white.withAlpha(90),
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
// Reward badge dengan smooth fade saat quest selesai bergaya Glassmorphism
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
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: AppTheme.glassPillDecoration(
          color: color,
          radius: 10,
          selected: !isDone,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 3),
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
