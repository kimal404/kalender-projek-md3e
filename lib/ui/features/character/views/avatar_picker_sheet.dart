import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quest_kalender/domain/models/avatar_catalog.dart';
import 'package:quest_kalender/domain/models/user_profile_model.dart';
import 'package:quest_kalender/ui/core/themes/app_theme.dart';
import 'package:quest_kalender/ui/core/widgets/animated_tap_menu.dart';
import 'package:quest_kalender/ui/features/character/view_models/character_view_model.dart';
import 'package:quest_kalender/ui/features/character/views/avatar_view.dart';

/// Memilih salah satu dari 7 avatar bawaan, atau foto dari galeri dan kamera.
class AvatarPickerSheet extends StatelessWidget {
  final CharacterViewModel characterViewModel;

  const AvatarPickerSheet({super.key, required this.characterViewModel});

  static Future<void> show(
    BuildContext context,
    CharacterViewModel characterViewModel,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (_) => AvatarPickerSheet(characterViewModel: characterViewModel),
    );
  }

  Future<void> _pick(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    try {
      final photo = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (photo == null) return;

      final directory = await getApplicationDocumentsDirectory();
      final prevPath = characterViewModel.profile.customAvatarPath;
      final saved = File(
        '${directory.path}/user_avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await File(photo.path).copy(saved.path);

      if (prevPath != null && prevPath.isNotEmpty && prevPath != saved.path) {
        final oldFile = File(prevPath);
        if (oldFile.existsSync()) {
          try {
            await oldFile.delete();
          } catch (_) {}
        }
      }
      await FileImage(saved).evict();

      await characterViewModel.updateAvatar(
        avatarId: characterViewModel.profile.avatarId,
        customAvatarPath: saved.path,
      );
      if (context.mounted) Navigator.of(context).pop();
    } on PlatformException {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak bisa membuka kamera atau galeri.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = characterViewModel.profile;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: AppTheme.glassCardDecoration(radius: 24),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(40),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Pilih Avatar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Pakai wajah bawaan, atau unggah gambarmu sendiri.',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pick(context, ImageSource.gallery),
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Galeri'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pick(context, ImageSource.camera),
                          icon: const Icon(Icons.photo_camera),
                          label: const Text('Kamera'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: AvatarCatalog.defaults.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          mainAxisExtent: 86,
                        ),
                    itemBuilder: (context, index) {
                      final avatar = AvatarCatalog.defaults[index];
                      final selected =
                          profile.customAvatarPath == null &&
                          profile.avatarId == avatar.id;
                      return _AvatarChoice(
                        avatar: avatar,
                        selected: selected,
                        onTap: () async {
                          await characterViewModel.updateAvatar(
                            avatarId: avatar.id,
                          );
                          if (context.mounted) Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarChoice extends StatelessWidget {
  final DefaultAvatar avatar;
  final bool selected;
  final VoidCallback onTap;

  const _AvatarChoice({
    required this.avatar,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final preview = UserProfile(
      lastActiveDate: DateTime.now(),
      avatarId: avatar.id,
    );

    return AnimatedPressScale(
      isSelected: selected,
      selectedScale: 1.05,
      pressedScale: 0.92,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        decoration: selected
            ? AppTheme.glassCardDecoration(
                radius: 14,
                accentColor: AppTheme.primaryGold,
                color: AppTheme.primaryGold.withAlpha(30),
              )
            : BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                AvatarView(profile: preview, size: 48),
                if (selected)
                  const Positioned(
                    right: 0,
                    bottom: 0,
                    child: Icon(
                      Icons.check_circle,
                      color: AppTheme.primaryGold,
                      size: 16,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                fontSize: 11,
                color: selected ? AppTheme.primaryGold : Colors.white70,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
              child: Text(
                avatar.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
