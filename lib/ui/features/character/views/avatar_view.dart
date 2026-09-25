import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quest_kalender/domain/models/avatar_catalog.dart';
import 'package:quest_kalender/domain/models/user_profile_model.dart';
import 'package:quest_kalender/ui/core/themes/app_theme.dart';

/// Lingkaran avatar: menampilkan foto kustom pengguna secara bulat penuh (1:1 cover)
/// dengan bingkai cincin yang merata 360 derajat, atau avatar SVG bawaan.
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

    final double borderWidth = size >= 64 ? 2.5 : 2.0;
    final double innerSize = (size - (borderWidth * 2)).clamp(1.0, size);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.surfaceLighter,
        boxShadow: [
          BoxShadow(
            color: avatar.color.withAlpha(70),
            blurRadius: 10,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Isi gambar dipaksa memenuhi bujur sangkar 1:1 lalu dipotong bulat sempurna
          SizedBox(
            width: innerSize,
            height: innerSize,
            child: ClipOval(
              clipBehavior: Clip.antiAlias,
              child: hasCustom
                  ? Image.file(
                      File(customPath),
                      key: ValueKey<String>(customPath),
                      width: innerSize,
                      height: innerSize,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      filterQuality: FilterQuality.medium,
                      errorBuilder: (_, _, _) =>
                          _DefaultFace(avatar: avatar, size: innerSize),
                    )
                  : _DefaultFace(avatar: avatar, size: innerSize),
            ),
          ),

          // Cincin border digambar di lapisan atas agar melingkar 360° secara merata
          // dan tidak tertutup oleh gambar kustom di bagian atas/bawah/samping
          IgnorePointer(
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: avatar.color,
                  width: borderWidth,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DefaultFace extends StatelessWidget {
  final DefaultAvatar avatar;
  final double size;

  const _DefaultFace({required this.avatar, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.asset(
        avatar.asset,
        width: size,
        height: size,
        fit: BoxFit.cover,
        alignment: Alignment.center,
      ),
    );
  }
}
