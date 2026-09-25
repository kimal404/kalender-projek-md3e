import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quest_kalender/domain/models/quest_model.dart';
import 'package:quest_kalender/domain/models/user_profile_model.dart';
import 'package:quest_kalender/ui/core/themes/app_theme.dart';
import 'package:quest_kalender/ui/core/widgets/guild_backdrop.dart';
import 'package:quest_kalender/ui/features/calendar/views/calendar_widget.dart';
import 'package:quest_kalender/ui/features/character/view_models/character_view_model.dart';
import 'package:quest_kalender/ui/features/character/views/avatar_picker_sheet.dart';
import 'package:quest_kalender/ui/features/character/views/avatar_view.dart';
import 'package:quest_kalender/ui/features/character/views/level_up_dialog.dart';
import 'package:quest_kalender/ui/features/quests/view_models/quest_view_model.dart';
import 'package:quest_kalender/ui/features/quests/views/add_quest_dialog.dart';
import 'package:quest_kalender/ui/features/quests/views/quest_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final charVM = context.read<CharacterViewModel>();
      final questVM = context.read<QuestViewModel>();

      charVM.init();
      questVM.init();

      charVM.onLevelUp = (newLevel, title) {
        LevelUpDialog.show(
          context,
          newLevel: newLevel,
          title: title,
          profile: charVM.profile,
        );
      };
    });
  }

  void _openAddQuestDialog({Quest? existingQuest}) async {
    final questVM = context.read<QuestViewModel>();
    final result = await AddQuestDialog.show(
      context,
      initialDate: questVM.selectedDate,
      existingQuest: existingQuest,
    );

    if (result != null) {
      if (existingQuest != null) {
        await questVM.updateQuest(result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Quest berhasil diperbarui!')),
          );
        }
      } else {
        await questVM.addQuest(result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Quest baru diterbitkan ke Guild!')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final charVM = context.watch<CharacterViewModel>();
    final questVM = context.watch<QuestViewModel>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.paddingOf(context).top + 88),
        child: _buildTopRpgHeader(charVM.profile),
      ),
      body: GuildBackdrop(
        child: charVM.isLoading || questVM.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryGold),
              )
            : AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.02),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(_currentTabIndex),
                  child: [
                    _buildQuestCalendarTab(questVM),
                    _buildCharacterSheetTab(charVM),
                    _buildGuildBoardTab(questVM, charVM),
                  ][_currentTabIndex],
                ),
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: (index) => setState(() => _currentTabIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Kalender & Quest',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil Saya',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shield),
            label: 'Papan Guild',
          ),
        ],
      ),
      floatingActionButton: _currentTabIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => _openAddQuestDialog(),
              icon: const Icon(Icons.add_task),
              label: const Text(
                'Quest Baru',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }

  // Header RPG di bagian atas
  Widget _buildTopRpgHeader(UserProfile profile) {
    final expPercent = (profile.currentExp / profile.maxExp).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1A1730).withAlpha(245),
            AppTheme.darkBackground.withAlpha(210),
          ],
        ),
        border: Border(
          bottom: BorderSide(color: AppTheme.primaryGold.withAlpha(50)),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + 8,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              AvatarView(profile: profile, size: 44),
              const SizedBox(width: 12),

              // Nama & Gelar Petualang
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, ${profile.name}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        profile.title,
                        key: ValueKey<String>(profile.title),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.neonCyan,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Streak Harian dengan animasi pulse
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.deepOrange, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      size: 16,
                      color: Colors.deepOrange,
                    ),
                    const SizedBox(width: 2),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutBack,
                          ),
                          child: child,
                        );
                      },
                      child: Text(
                        '${profile.streakDays} Hari',
                        key: ValueKey<int>(profile.streakDays),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Koin / Emas dengan animasi pop
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGold.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryGold, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      size: 16,
                      color: AppTheme.primaryGold,
                    ),
                    const SizedBox(width: 2),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutBack,
                          ),
                          child: child,
                        );
                      },
                      child: Text(
                        '${profile.coins} G',
                        key: ValueKey<int>(profile.coins),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // EXP Bar dengan animasi luncur halus (smooth easing)
          Row(
            children: [
              Expanded(
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: expPercent),
                  duration: const Duration(milliseconds: 650),
                  curve: Curves.easeOutCubic,
                  builder: (context, animatedExp, child) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: animatedExp,
                        minHeight: 8,
                        backgroundColor: AppTheme.surfaceLighter,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.neonPurple,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  '${profile.currentExp}/${profile.maxExp} EXP',
                  key: ValueKey<String>(
                    '${profile.currentExp}/${profile.maxExp}',
                  ),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // TAB 1: Kalender & Quest
  Widget _buildQuestCalendarTab(QuestViewModel questVM) {
    final quests = questVM.questsForSelectedDate;
    final selectedDateStr = DateFormat('EEEE, dd MMMM yyyy')
        .format(questVM.selectedDate);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildDailyContract(questVM),
        const SizedBox(height: 16),

        // Kalender Interaktif
        CalendarWidget(viewModel: questVM),
        const SizedBox(height: 16),

        // Filter Rank & Kategori
        _buildFilterChips(questVM),
        const SizedBox(height: 16),

        // Judul Bagian Quest Hari Ini
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Quest: $selectedDateStr',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            Text(
              '${quests.length} Quest',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.primaryGold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Daftar Quest dengan animasi transisi halus
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: KeyedSubtree(
            key: ValueKey<String>(
              '${questVM.selectedDate.year}-${questVM.selectedDate.month}-${questVM.selectedDate.day}-${questVM.selectedCategory?.name}-${questVM.selectedRank?.code}-${quests.length}',
            ),
            child: quests.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.surfaceLighter),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.auto_stories,
                          size: 48,
                          color: AppTheme.textMuted,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Tidak ada quest pada tanggal ini.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Ambil misi baru dari Guild untuk meningkatkan level dan mengumpulkan koin!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGold,
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () => _openAddQuestDialog(),
                          icon: const Icon(Icons.add),
                          label: const Text('Tambah Quest'),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: quests.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final quest = entry.value;
                      return QuestCard(
                        key: ValueKey(quest.id),
                        quest: quest,
                        index: idx,
                        onToggleComplete: () =>
                            questVM.toggleQuestCompletion(quest),
                        onEdit: () => _openAddQuestDialog(existingQuest: quest),
                        onDelete: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Hapus Quest?'),
                              content: Text(
                                'Apakah kamu yakin ingin menghapus "${quest.title}"?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.redAccent,
                                  ),
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text('Hapus'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await questVM.deleteQuest(quest.id);
                          }
                        },
                      );
                    }).toList(),
                  ),
          ),
        ),
        const SizedBox(height: 60), // Spacing untuk FAB
      ],
    );
  }

  Widget _buildDailyContract(QuestViewModel questVM) {
    final quests = questVM.questsForSelectedDate;
    final done = quests.where((q) => q.isCompleted).length;
    final total = quests.length;
    final progress = total == 0 ? 0.0 : done / total;
    final isClear = total > 0 && done == total;
    final accent = isClear ? const Color(0xFF69F0AE) : AppTheme.primaryGold;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withAlpha(48),
            AppTheme.cardBackground.withAlpha(220),
          ],
        ),
        border: Border.all(color: accent.withAlpha(140)),
        boxShadow: [
          BoxShadow(
            color: accent.withAlpha(36),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isClear ? Icons.verified : Icons.auto_awesome,
                color: accent,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isClear ? 'KONTRAK HARIAN SELESAI' : 'KONTRAK HARIAN GUILD',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    color: accent,
                  ),
                ),
              ),
              Text(
                total == 0 ? '0/0' : '$done/$total',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            total == 0
                ? 'Guild masih sepi. Terbitkan quest pertama untuk hari ini.'
                : isClear
                ? 'Semua misi hari ini tuntas. Kamu layak istirahat, petualang.'
                : 'Selesaikan $total misi untuk menutup kontrak hari ini.',
            style: const TextStyle(fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 7,
                  backgroundColor: AppTheme.surfaceLighter,
                  valueColor: AlwaysStoppedAnimation<Color>(accent),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(QuestViewModel questVM) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Filter Semua
          FilterChip(
            label: const Text('Semua'),
            selected:
                questVM.selectedCategory == null &&
                questVM.selectedRank == null,
            onSelected: (_) {
              questVM.setCategoryFilter(null);
              questVM.setRankFilter(null);
            },
            selectedColor: AppTheme.primaryGold.withAlpha(60),
          ),
          const SizedBox(width: 8),

          // Filter Kategori
          ...QuestCategory.values.map((cat) {
            final isSelected = questVM.selectedCategory == cat;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                avatar: Icon(cat.icon, size: 14, color: cat.color),
                label: Text(cat.label),
                selected: isSelected,
                selectedColor: cat.color.withAlpha(60),
                onSelected: (val) {
                  questVM.setCategoryFilter(val ? cat : null);
                },
              ),
            );
          }),

          // Filter Rank
          ...QuestRank.values.map((rank) {
            final isSelected = questVM.selectedRank == rank;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text('Rank ${rank.code}'),
                selected: isSelected,
                selectedColor: rank.color.withAlpha(60),
                onSelected: (val) {
                  questVM.setRankFilter(val ? rank : null);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  // TAB 2: Status Karakter (Character Sheet) dengan stagger animasi
  Widget _buildCharacterSheetTab(CharacterViewModel charVM) {
    final profile = charVM.profile;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Kartu Profil Utama – entrance fade+slide
        _StaggerFadeSlide(
          delayMs: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.surfaceLighter),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.surfaceLighter.withAlpha(100),
                  AppTheme.cardBackground,
                ],
              ),
            ),
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'DASHBOARD SAYA',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: AppTheme.primaryGold,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () => AvatarPickerSheet.show(context, charVM),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AvatarView(profile: profile, size: 96),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryGold,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.photo_camera,
                            size: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => AvatarPickerSheet.show(context, charVM),
                  child: const Text('Ganti avatar'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      profile.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        size: 16,
                        color: AppTheme.textMuted,
                      ),
                      onPressed: () => _showEditNameDialog(charVM),
                    ),
                  ],
                ),
                Text(
                  '${profile.title} (Level ${profile.level})',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.neonCyan,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatPill(
                      'Quest Tuntas',
                      '${profile.completedQuestsCount}',
                      Icons.task_alt,
                    ),
                    _buildStatPill(
                      'Streak Aktif',
                      '${profile.streakDays} Hari',
                      Icons.local_fire_department,
                    ),
                    _buildStatPill(
                      'Kekayaan',
                      '${profile.coins} G',
                      Icons.monetization_on,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Label seksi
        _StaggerFadeSlide(
          delayMs: 80,
          child: const Text(
            'Atribut Karakter (Stat RPG)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Attribute cards dengan stagger delay
        _StaggerFadeSlide(
          delayMs: 140,
          child: _buildAttributeCard(
            title: 'Kekuatan (STR)',
            description: 'Meningkat dari latihan fisik, workout, dan olahraga.',
            value: profile.strength,
            color: const Color(0xFFEF5350),
            icon: Icons.fitness_center,
          ),
        ),
        const SizedBox(height: 10),
        _StaggerFadeSlide(
          delayMs: 210,
          child: _buildAttributeCard(
            title: 'Kecerdasan (INT)',
            description: 'Meningkat dari belajar, membaca buku, dan riset.',
            value: profile.intellect,
            color: const Color(0xFF42A5F5),
            icon: Icons.psychology,
          ),
        ),
        const SizedBox(height: 10),
        _StaggerFadeSlide(
          delayMs: 280,
          child: _buildAttributeCard(
            title: 'Disiplin (DIS)',
            description:
                'Meningkat dari penyelesaian tugas kerja dan rutinitas.',
            value: profile.discipline,
            color: const Color(0xFFAB47BC),
            icon: Icons.task_alt,
          ),
        ),
        const SizedBox(height: 10),
        _StaggerFadeSlide(
          delayMs: 350,
          child: _buildAttributeCard(
            title: 'Kebugaran (VIT)',
            description:
                'Meningkat dari hidrasi cukup, istirahat, dan meditasi.',
            value: profile.vitality,
            color: const Color(0xFF66BB6A),
            icon: Icons.favorite,
          ),
        ),
      ],
    );
  }

  Widget _buildStatPill(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryGold),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
        ),
      ],
    );
  }

  Widget _buildAttributeCard({
    required String title,
    required String description,
    required int value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(40),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLighter,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$value Pts',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog(CharacterViewModel charVM) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _EditNameDialog(
        initialName: charVM.profile.name,
        onSave: charVM.updateName,
      ),
    );
  }

  // TAB 3: Papan Pengumuman Guild (Guild Board)
  Widget _buildGuildBoardTab(
    QuestViewModel questVM,
    CharacterViewModel charVM,
  ) {
    final allQuests = questVM.getAllQuests();
    final completed = allQuests.where((q) => q.isCompleted).length;
    final pending = allQuests.length - completed;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Ringkasan Papan Misi
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.surfaceLighter),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.assignment, color: AppTheme.primaryGold),
                  SizedBox(width: 8),
                  Text(
                    'Ringkasan Guild Misi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildBoardMetric(
                      'Total Quest',
                      '${allQuests.length}',
                      Colors.white,
                    ),
                  ),
                  Expanded(
                    child: _buildBoardMetric(
                      'Terselesaikan',
                      '$completed',
                      Colors.greenAccent,
                    ),
                  ),
                  Expanded(
                    child: _buildBoardMetric(
                      'Menunggu',
                      '$pending',
                      AppTheme.primaryGold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Statistik Berdasarkan Tingkat Kesulitan Rank
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.surfaceLighter),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Penyebaran Quest Berdasarkan Rank',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              ...QuestRank.values.map((rank) {
                final count = allQuests.where((q) => q.rank == rank).length;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        alignment: Alignment.center,
                        child: Text(
                          rank.code,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: rank.color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: allQuests.isEmpty
                                ? 0.0
                                : count / allQuests.length,
                            minHeight: 6,
                            backgroundColor: AppTheme.surfaceLighter,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              rank.color,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$count Misi',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Sinkronisasi Cloud (Firebase / Supabase)
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.surfaceLighter),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.cloud_sync, color: AppTheme.neonCyan),
                  SizedBox(width: 8),
                  Text(
                    'Sinkronisasi Cloud & Backup',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Data tersimpan secara lokal dan aman di perangkat ini. Kamu dapat menghubungkan akun untuk sinkronisasi antar perangkat.',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.neonCyan),
                  foregroundColor: AppTheme.neonCyan,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Status: Penyimpanan offline lokal aktif & sinkron.',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.sync),
                label: const Text('Periksa Sinkronisasi'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBoardMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
        ),
      ],
    );
  }
}

/// Dialog ubah nama. Controller hidup bersama dialog, bukan di luarnya,
/// supaya tidak dibuang saat field masih dipakai.
class _EditNameDialog extends StatefulWidget {
  final String initialName;
  final Future<void> Function(String name) onSave;

  const _EditNameDialog({required this.initialName, required this.onSave});

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  late final TextEditingController _controller;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _controller.text.trim();
    if (name.isEmpty || _saving) return;
    setState(() => _saving = true);
    await widget.onSave(name);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ubah Nama Petualang'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        enabled: !_saving,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
          labelText: 'Nama Karakter',
          hintText: 'Masukkan nama...',
        ),
        onSubmitted: (_) => _save(),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGold,
          ),
          onPressed: _saving ? null : _save,
          child: const Text('Simpan', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Widget helper: stagger fade + slide-up entrance dengan delay
// ─────────────────────────────────────────────────────────────
class _StaggerFadeSlide extends StatefulWidget {
  final Widget child;
  final int delayMs;

  const _StaggerFadeSlide({required this.child, this.delayMs = 0});

  @override
  State<_StaggerFadeSlide> createState() => _StaggerFadeSlideState();
}

class _StaggerFadeSlideState extends State<_StaggerFadeSlide>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.10),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
