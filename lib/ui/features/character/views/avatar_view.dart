import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quest_kalender/domain/models/avatar_catalog.dart';
import 'package:quest_kalender/domain/models/user_profile_model.dart';
import 'package:quest_kalender/ui/core/themes/app_theme.dart';

/// Lingkaran avatar: foto pengguna jika ada, kalau tidak avatar bawaan.
class AvatarView extends StatelessWidget {
  final UserProfile profile;
  final double size;

  const AvatarView({super.key, required this.profile, this.size = 72});

  @override
  Widget build(BuildContext context) {
    final avatar = AvatarCatalog.byId(profile.avatarId);
    final customPath = profile.customAvatarPath;
    final hasCustom =
        customPath != null &&
        customPath.isNotEmpty &&
        File(customPath).existsSync();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.surfaceLighter,
        border: Border.all(color: avatar.color, width: 2),
        boxShadow: [
          BoxShadow(color: avatar.color.withAlpha(70), blurRadius: 12),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: hasCustom
          ? Image.file(
              File(customPath),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _DefaultFace(avatar: avatar),
            )
          : _DefaultFace(avatar: avatar),
    );
  }
}

class _DefaultFace extends StatelessWidget {
  final DefaultAvatar avatar;

  const _DefaultFace({required this.avatar});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(avatar.asset, fit: BoxFit.cover);
  }
}
