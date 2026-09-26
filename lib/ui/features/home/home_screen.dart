import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quest_kalender/data/services/notification_service.dart';
import 'package:quest_kalender/domain/models/notification_sound.dart';
import 'package:quest_kalender/domain/models/quest_model.dart';
import 'package:quest_kalender/domain/models/user_profile_model.dart';
import 'package:quest_kalender/ui/core/themes/app_theme.dart';
import 'package:quest_kalender/ui/core/widgets/animated_tap_menu.dart';
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
  final TextEditingController _searchController = TextEditingController();
  bool _hasCheckedWelcome = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final charVM = context.read<CharacterViewModel>();
      final questVM = context.read<QuestViewModel>();

      await charVM.init();
      await questVM.init();

      charVM.onLevelUp = (newLevel, title) {
        LevelUpDialog.show(
          context,
          newLevel: newLevel,
          title: title,
          profile: charVM.profile,
        );
      };

      if (!_hasCheckedWelcome && mounted) {
        _hasCheckedWelcome = true;
        if (charVM.profile.name == 'Petualang' &&
            charVM.profile.completedQuestsCount == 0) {
          _showWelcomeRegistrationDialog(charVM);
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      backgroundColor: AppTheme.darkBackground,
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
                duration: const Duration(milliseconds: 210),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.015),
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
      bottomNavigationBar: AnimatedRpgBottomNav(
        currentIndex: _currentTabIndex,
        onTap: (index) {
          if (_currentTabIndex != index) {
            setState(() => _currentTabIndex = index);
          }
        },
        items: const [
          AnimatedNavItem(
            icon: Icons.calendar_month,
            label: 'Kalender & Quest',
          ),
          AnimatedNavItem(
            icon: Icons.person,
            label: 'Profil Saya',
          ),
          AnimatedNavItem(
            icon: Icons.shield,
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

  // Header RPG di bagian atas dengan Dark Arcane Glassmorphism
  Widget _buildTopRpgHeader(UserProfile profile) {
    final expPercent = (profile.currentExp / profile.maxExp).clamp(0.0, 1.0);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF1A1730).withAlpha(195),
                AppTheme.darkBackground.withAlpha(165),
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withAlpha(28),
                width: 1.0,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(70),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
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

                  // Streak Harian dengan animasi pulse & glass pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 5,
                    ),
                    decoration: AppTheme.glassPillDecoration(
                      color: Colors.deepOrange.withAlpha(35),
                      borderColor: Colors.deepOrange.withAlpha(160),
                      radius: 14,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          size: 16,
                          color: Colors.deepOrange,
                        ),
                        const SizedBox(width: 3),
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
                ],
              ),
              const SizedBox(height: 8),

              // EXP Bar dengan track recessed glass dan animasi luncur halus
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 8,
                      decoration: AppTheme.glassRecessedDecoration(radius: 6),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.0, end: expPercent),
                          duration: const Duration(milliseconds: 650),
                          curve: Curves.easeOutCubic,
                          builder: (context, animatedExp, child) {
                            return LinearProgressIndicator(
                              value: animatedExp,
                              minHeight: 8,
                              backgroundColor: Colors.transparent,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppTheme.neonPurple,
                              ),
                            );
                          },
                        ),
                      ),
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
        ),
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

        // Pencarian Quest
        _buildQuestSearchBar(questVM),
        const SizedBox(height: 12),

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
              '${questVM.selectedDate.year}-${questVM.selectedDate.month}-${questVM.selectedDate.day}-${questVM.selectedCategory?.name}-${questVM.selectedRank?.code}-${questVM.searchQuery}-${quests.length}',
            ),
            child: quests.isEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: AppTheme.glassCardDecoration(radius: 18),
                        child: Column(
                          children: [
                            Icon(
                              questVM.searchQuery.isNotEmpty
                                  ? Icons.search_off_rounded
                                  : Icons.auto_stories,
                              size: 48,
                              color: AppTheme.textMuted,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              questVM.searchQuery.isNotEmpty
                                  ? 'Quest tidak ditemukan'
                                  : 'Tidak ada quest pada tanggal ini.',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              questVM.searchQuery.isNotEmpty
                                  ? 'Tidak ada misi yang cocok dengan kata kunci "${questVM.searchQuery}".'
                                  : 'Ambil misi baru dari Guild untuk meningkatkan level dan atribut karaktermu!',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textMuted,
                              ),
                            ),
                            const SizedBox(height: 14),
                            questVM.searchQuery.isNotEmpty
                                ? OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: AppTheme.primaryGold,
                                      ),
                                      foregroundColor: AppTheme.primaryGold,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      questVM.setSearchQuery('');
                                    },
                                    icon: const Icon(Icons.clear, size: 16),
                                    label: const Text('Reset Pencarian'),
                                  )
                                : ElevatedButton.icon(
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
                      ),
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
                        onToggleComplete: () async {
                          final result = await questVM.toggleQuestCompletion(
                            quest,
                          );
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          if (result.status ==
                              QuestCompletionStatus.alreadyCompleted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Quest sudah diselesaikan & terkunci! Setiap tugas hanya bisa digunakan 1 kali.',
                                ),
                              ),
                            );
                          } else if (result.status ==
                              QuestCompletionStatus.dailyLimitReached) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Quest selesai! Batas maksimal EXP harian (500 EXP/hari) telah tercapai.',
                                ),
                              ),
                            );
                          } else {
                            final earnedToday = questVM
                                .getEarnedDailyExpForDate(quest.date);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Quest tuntas! +${result.expGranted} EXP diperoleh (EXP Hari Ini: $earnedToday/${UserProfile.maxDailyExp} EXP)',
                                ),
                              ),
                            );
                          }
                        },
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
    final earnedDailyExp = questVM.getEarnedDailyExpForDate(
      questVM.selectedDate,
    );
    final committedDailyExp = questVM.getTotalCommittedExpForDate(
      questVM.selectedDate,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.glassCardDecoration(
            radius: 20,
            accentColor: accent,
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
                    : 'Selesaikan $total misi untuk menutup kontrak hari ini (1x pakai per misi).',
                style: const TextStyle(fontSize: 13, color: Colors.white70),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: AppTheme.glassRecessedDecoration(
                  radius: 10,
                  borderColor: accent.withAlpha(60),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.bolt, size: 14, color: AppTheme.neonCyan),
                          const SizedBox(width: 4),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Limit: $earnedDailyExp/${UserProfile.maxDailyExp} EXP Diklaim',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.neonCyan,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      height: 12,
                      width: 1,
                      color: Colors.white24,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Terjadwal: $committedDailyExp/${UserProfile.maxDailyExp}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 7,
                decoration: AppTheme.glassRecessedDecoration(radius: 6),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: 7,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(accent),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestSearchBar(QuestViewModel questVM) {
    return Container(
      decoration: AppTheme.glassRecessedDecoration(
        radius: 14,
        borderColor: AppTheme.primaryGold.withAlpha(50),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: questVM.setSearchQuery,
        style: const TextStyle(color: Colors.white, fontSize: 13.5),
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Cari nama atau deskripsi quest...',
          hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
          prefixIcon: const Icon(
            Icons.search,
            color: AppTheme.primaryGold,
            size: 20,
          ),
          suffixIcon: questVM.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: AppTheme.textMuted,
                    size: 18,
                  ),
                  tooltip: 'Hapus pencarian',
                  onPressed: () {
                    _searchController.clear();
                    questVM.setSearchQuery('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(QuestViewModel questVM) {
    final isAllSelected =
        questVM.selectedCategory == null && questVM.selectedRank == null;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          // Filter Semua
          AnimatedMenuChip(
            label: 'Semua',
            icon: Icons.apps_rounded,
            activeColor: AppTheme.primaryGold,
            selected: isAllSelected,
            onTap: () {
              questVM.setCategoryFilter(null);
              questVM.setRankFilter(null);
            },
          ),
          const SizedBox(width: 8),

          // Filter Kategori
          ...QuestCategory.values.map((cat) {
            final isSelected = questVM.selectedCategory == cat;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: AnimatedMenuChip(
                icon: cat.icon,
                label: cat.label,
                activeColor: cat.color,
                selected: isSelected,
                onTap: () {
                  questVM.setCategoryFilter(isSelected ? null : cat);
                },
              ),
            );
          }),

          // Filter Rank
          ...QuestRank.values.map((rank) {
            final isSelected = questVM.selectedRank == rank;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: AnimatedMenuChip(
                label: 'Rank ${rank.code}',
                activeColor: rank.color,
                selected: isSelected,
                onTap: () {
                  questVM.setRankFilter(isSelected ? null : rank);
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.glassCardDecoration(
                  radius: 20,
                  accentColor: AppTheme.primaryGold,
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
                              padding: const EdgeInsets.all(7),
                              decoration: AppTheme.glassButtonDecoration(
                                primaryColor: AppTheme.primaryGold,
                                radius: 16,
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
                    InkWell(
                      onTap: () => _showEditNameDialog(charVM),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Kotak pengimbang selebar 22px (16px ikon + 6px spasi)
                            // agar teks nama petualang berada tepat di tengah geometris card
                            const SizedBox(width: 22),
                            Text(
                              profile.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.edit,
                              size: 16,
                              color: AppTheme.textMuted,
                            ),
                          ],
                        ),
                      ),
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
                          'Level Karakter',
                          'Lv. ${profile.level}',
                          Icons.military_tech,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: AppTheme.glassRecessedDecoration(
        radius: 12,
        borderColor: Colors.white.withAlpha(20),
      ),
      child: Column(
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
            style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildAttributeCard({
    required String title,
    required String description,
    required int value,
    required Color color,
    required IconData icon,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: AppTheme.glassCardDecoration(
            radius: 16,
            accentColor: color,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: AppTheme.glassPillDecoration(
                  color: color.withAlpha(35),
                  borderColor: color.withAlpha(120),
                  radius: 12,
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
                decoration: AppTheme.glassRecessedDecoration(
                  radius: 10,
                  borderColor: color.withAlpha(70),
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
        ),
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

  void _showWelcomeRegistrationDialog(CharacterViewModel charVM) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _WelcomeRegistrationDialog(
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
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: AppTheme.glassCardDecoration(
                radius: 18,
                accentColor: AppTheme.primaryGold,
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
          ),
        ),
        const SizedBox(height: 16),

        // Statistik Berdasarkan Tingkat Kesulitan Rank
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: AppTheme.glassCardDecoration(radius: 18),
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
                            child: Container(
                              height: 7,
                              decoration: AppTheme.glassRecessedDecoration(
                                radius: 4,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: allQuests.isEmpty
                                      ? 0.0
                                      : count / allQuests.length,
                                  minHeight: 7,
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    rank.color,
                                  ),
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
          ),
        ),
        const SizedBox(height: 16),

        _buildSoundCard(charVM),
        const SizedBox(height: 16),

        // Penyimpanan Offline Lokal Aktif (Hive Database)
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: AppTheme.glassCardDecoration(
                radius: 18,
                accentColor: AppTheme.neonCyan,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shield_outlined, color: AppTheme.neonCyan),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Penyimpanan Offline Lokal',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: AppTheme.glassPillDecoration(
                          color: const Color(0xFF69F0AE).withAlpha(30),
                          borderColor: const Color(0xFF69F0AE).withAlpha(120),
                          radius: 8,
                        ),
                        child: const Text(
                          'AMAN & LOKAL',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF69F0AE),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Semua data misi, riwayat quest, dan profil petualang tersimpan di penyimpanan lokal perangkat (Hive). Tanpa ketergantungan internet dan bebas pelacakan.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: AppTheme.glassRecessedDecoration(
                      radius: 10,
                      borderColor: AppTheme.neonCyan.withAlpha(50),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.storage_rounded,
                          size: 16,
                          color: AppTheme.neonCyan,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Total Terdaftar: ${allQuests.length} Quest • $completed Selesai',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSoundCard(CharacterViewModel charVM) {
    final selected = NotificationSounds.byId(
      charVM.profile.notificationSoundId,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: AppTheme.glassCardDecoration(
            radius: 18,
            accentColor: AppTheme.primaryGold,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.music_note, color: AppTheme.primaryGold),
                  SizedBox(width: 8),
                  Text(
                    'Suara Pengingat',
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
                'Pilih nada yang berbunyi saat quest dimulai. Quest yang masih menunggu ikut memakai nada baru.',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 12),
              ...NotificationSounds.options.map((sound) {
                final isSelected = sound.id == selected.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: AnimatedPressScale(
                    isSelected: isSelected,
                    selectedScale: 1.01,
                    pressedScale: 0.97,
                    onTap: () async {
                      final questVM = context.read<QuestViewModel>();
                      NotificationService.instance.previewCurrentSound(sound.id);
                      await charVM.updateNotificationSound(sound.id);
                      await questVM.rescheduleNotifications();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: isSelected
                          ? AppTheme.glassCardDecoration(
                              radius: 12,
                              accentColor: AppTheme.primaryGold,
                              color: AppTheme.primaryGold.withAlpha(30),
                            )
                          : AppTheme.glassRecessedDecoration(
                              radius: 12,
                              borderColor: Colors.white.withAlpha(15),
                            ),
                      child: Row(
                        children: [
                          AnimatedScale(
                            scale: isSelected ? 1.12 : 1.0,
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOutCubic,
                            child: Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              size: 20,
                              color: isSelected
                                  ? AppTheme.primaryGold
                                  : AppTheme.textMuted,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeOutCubic,
                              style: TextStyle(
                                fontFamily: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.fontFamily,
                                color: isSelected
                                    ? AppTheme.primaryGold
                                    : Colors.white,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 14,
                              ),
                              child: Text(sound.label),
                            ),
                          ),
                          IconButton(
                            tooltip: sound.id == 'silent'
                                ? 'Mode senyap'
                                : 'Putar suara ${sound.label}',
                            icon: Icon(
                              sound.id == 'silent'
                                  ? Icons.volume_off_rounded
                                  : Icons.volume_up_rounded,
                              size: 20,
                              color: isSelected
                                  ? AppTheme.primaryGold
                                  : AppTheme.textMuted,
                            ),
                            onPressed: () {
                              NotificationService.instance.previewCurrentSound(
                                sound.id,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoardMetric(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: AppTheme.glassRecessedDecoration(
        radius: 12,
        borderColor: color.withAlpha(50),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted),
          ),
        ],
      ),
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

/// Dialog sambutan dan registrasi nama untuk petualang baru pada peluncuran perdana
class _WelcomeRegistrationDialog extends StatefulWidget {
  final Future<void> Function(String name) onSave;

  const _WelcomeRegistrationDialog({required this.onSave});

  @override
  State<_WelcomeRegistrationDialog> createState() =>
      _WelcomeRegistrationDialogState();
}

class _WelcomeRegistrationDialogState
    extends State<_WelcomeRegistrationDialog> {
  late final TextEditingController _controller;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: 'Petualang');
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.text.length,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _saving) return;
    setState(() => _saving = true);
    await widget.onSave(text);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.shield, color: AppTheme.primaryGold, size: 22),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Pendaftaran Guild',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selamat datang di Guild Quest Kalender! Daftarkan nama panggilan petualangmu untuk memulai petualangan produktivitas.',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textMuted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            enabled: !_saving,
            maxLength: 24,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Nama Petualang',
              hintText: 'Contoh: Arthur, Kael, dsb...',
              counterText: '',
            ),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text(
            'Nanti Saja',
            style: TextStyle(color: AppTheme.textMuted),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGold,
            foregroundColor: Colors.black,
          ),
          onPressed: _saving ? null : _submit,
          child: const Text(
            'Mulai Petualangan',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
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
