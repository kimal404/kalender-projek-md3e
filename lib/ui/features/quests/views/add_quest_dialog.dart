import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:quest_kalender/domain/models/quest_model.dart';
import 'package:quest_kalender/ui/core/themes/app_theme.dart';

class AddQuestDialog extends StatefulWidget {
  final DateTime initialDate;
  final Quest? existingQuest;

  const AddQuestDialog({
    super.key,
    required this.initialDate,
    this.existingQuest,
  });

  static Future<Quest?> show(
    BuildContext context, {
    required DateTime initialDate,
    Quest? existingQuest,
  }) {
    final navigator = Navigator.of(context, rootNavigator: true);
    return navigator.push<Quest>(
      PageRouteBuilder<Quest>(
        opaque: false,
        barrierDismissible: true,
        barrierColor: const Color(0x8A000000),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (context, animation, secondaryAnimation) {
          return AddQuestDialog(
            initialDate: initialDate,
            existingQuest: existingQuest,
          );
        },
      ),
    );
  }

  @override
  State<AddQuestDialog> createState() => _AddQuestDialogState();
}

class _AddQuestDialogState extends State<AddQuestDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;

  late DateTime _selectedDate;
  String? _startTime;
  String? _endTime;
  late QuestRank _selectedRank;
  late QuestCategory _selectedCategory;

  @override
  void initState() {
    super.initState();
    final q = widget.existingQuest;
    _titleController = TextEditingController(text: q?.title ?? '');
    _descController = TextEditingController(text: q?.description ?? '');
    _selectedDate = q?.date ?? widget.initialDate;
    _startTime = q?.startTime;
    _endTime = q?.endTime;
    _selectedRank = q?.rank ?? QuestRank.d;
    _selectedCategory = q?.category ?? QuestCategory.discipline;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryGold,
              onPrimary: Colors.black,
              surface: AppTheme.cardBackground,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime({required bool isStartTime}) async {
    final currentStr = isStartTime ? _startTime : _endTime;
    TimeOfDay initial = TimeOfDay.now();
    if (currentStr != null) {
      final parts = currentStr.split(':');
      if (parts.length == 2) {
        initial = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 12,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryGold,
              onPrimary: Colors.black,
              surface: AppTheme.cardBackground,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        if (isStartTime) {
          _startTime = formatted;
        } else {
          _endTime = formatted;
        }
      });
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final quest = Quest(
      id: widget.existingQuest?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      date: _selectedDate,
      startTime: _startTime,
      endTime: _endTime,
      rank: _selectedRank,
      category: _selectedCategory,
      expReward: _selectedRank.defaultExp,
      coinReward: _selectedRank.defaultCoins,
      isCompleted: widget.existingQuest?.isCompleted ?? false,
      completedAt: widget.existingQuest?.completedAt,
    );

    Navigator.of(context).pop(quest);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingQuest != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.all(Radius.circular(20)),
          border: Border.fromBorderSide(
            BorderSide(color: AppTheme.surfaceLighter, width: 1.5),
          ),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 680),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul Dialog
                    Row(
                      children: [
                        const Icon(
                          Icons.shield,
                          color: AppTheme.primaryGold,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isEditing ? 'Ubah Quest' : 'Terbitkan Quest Baru',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: AppTheme.textMuted,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const Divider(color: AppTheme.surfaceLighter),
                    const SizedBox(height: 12),

                    // Judul Quest
                    TextFormField(
                      controller: _titleController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Judul Quest / Tugas',
                        hintText: 'Misal: Selesaikan Bab 3 Matematika',
                        filled: true,
                        fillColor: Color(0x802B304A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Judul quest tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Deskripsi
                    TextFormField(
                      controller: _descController,
                      maxLines: 2,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi / Catatan (Opsional)',
                        hintText: 'Detail sasaran misi...',
                        filled: true,
                        fillColor: Color(0x802B304A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tanggal & Waktu
                    const Text(
                      'Jadwal & Waktu',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: AppTheme.surfaceLighter,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _pickDate,
                            icon: const Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: AppTheme.primaryGold,
                            ),
                            label: Text(
                              DateFormat('dd MMM yyyy').format(_selectedDate),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: AppTheme.surfaceLighter,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => _pickTime(isStartTime: true),
                            icon: const Icon(
                              Icons.alarm,
                              size: 16,
                              color: AppTheme.neonCyan,
                            ),
                            label: Text(
                              _startTime ?? 'Mulai (Opsional)',
                              style: TextStyle(
                                fontSize: 12,
                                color: _startTime != null
                                    ? Colors.white
                                    : AppTheme.textMuted,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: AppTheme.surfaceLighter,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => _pickTime(isStartTime: false),
                            icon: const Icon(
                              Icons.alarm_on,
                              size: 16,
                              color: AppTheme.neonCyan,
                            ),
                            label: Text(
                              _endTime ?? 'Selesai (Opsional)',
                              style: TextStyle(
                                fontSize: 12,
                                color: _endTime != null
                                    ? Colors.white
                                    : AppTheme.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Pilihan Rank Kesulitan Quest
                    const Text(
                      'Tingkat Kesulitan (Rank)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: QuestRank.values.map((rank) {
                        final isSelected = _selectedRank == rank;
                        return ChoiceChip(
                          selectedColor: rank.color.withAlpha(60),
                          backgroundColor: AppTheme.surfaceLighter,
                          side: BorderSide(
                            color: isSelected ? rank.color : Colors.transparent,
                            width: 1.5,
                          ),
                          label: Text(
                            'Rank ${rank.code} (${rank.label})',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected ? rank.color : Colors.white70,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedRank = rank);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Kategori Atribut Karakter
                    const Text(
                      'Kategori Atribut RPG',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: QuestCategory.values.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return ChoiceChip(
                          avatar: Icon(cat.icon, size: 14, color: cat.color),
                          selectedColor: cat.color.withAlpha(60),
                          backgroundColor: AppTheme.surfaceLighter,
                          side: BorderSide(
                            color: isSelected ? cat.color : Colors.transparent,
                            width: 1.5,
                          ),
                          label: Text(
                            cat.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected ? cat.color : Colors.white70,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedCategory = cat);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Ringkasan Reward
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLighter,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'Hadiah Misi:',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.bolt,
                            size: 16,
                            color: AppTheme.neonPurple,
                          ),
                          Text(
                            ' +${_selectedRank.defaultExp} EXP',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.neonPurple,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.monetization_on,
                            size: 16,
                            color: AppTheme.primaryGold,
                          ),
                          Text(
                            ' +${_selectedRank.defaultCoins} Gold',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryGold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tombol Simpan
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGold,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _save,
                        child: Text(
                          isEditing
                              ? 'Simpan Perubahan'
                              : 'Terbitkan Quest ke Guild',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
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
