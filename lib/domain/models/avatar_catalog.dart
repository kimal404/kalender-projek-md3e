import 'package:flutter/material.dart';

/// Satu avatar bawaan yang bisa dipilih pengguna.
class DefaultAvatar {
  final String id;
  final String label;
  final String asset;
  final IconData icon;
  final Color color;

  const DefaultAvatar({
    required this.id,
    required this.label,
    required this.asset,
    required this.icon,
    required this.color,
  });
}

/// Tujuh wajah petualang bawaan aplikasi.
class AvatarCatalog {
  static const List<DefaultAvatar> defaults = [
    DefaultAvatar(
      id: 'guardian',
      label: 'Penjaga',
      asset: 'assets/avatars/guardian.svg',
      icon: Icons.shield_moon,
      color: Color(0xFFFFB300),
    ),
    DefaultAvatar(
      id: 'mage',
      label: 'Penyihir',
      asset: 'assets/avatars/mage.svg',
      icon: Icons.auto_awesome,
      color: Color(0xFF42A5F5),
    ),
    DefaultAvatar(
      id: 'scout',
      label: 'Pengintai',
      asset: 'assets/avatars/scout.svg',
      icon: Icons.explore,
      color: Color(0xFF66BB6A),
    ),
    DefaultAvatar(
      id: 'knight',
      label: 'Ksatria',
      asset: 'assets/avatars/knight.svg',
      icon: Icons.security,
      color: Color(0xFFEF5350),
    ),
    DefaultAvatar(
      id: 'scholar',
      label: 'Cendekia',
      asset: 'assets/avatars/scholar.svg',
      icon: Icons.menu_book,
      color: Color(0xFF00E5FF),
    ),
    DefaultAvatar(
      id: 'ranger',
      label: 'Pemanah',
      asset: 'assets/avatars/ranger.svg',
      icon: Icons.architecture,
      color: Color(0xFFAB47BC),
    ),
    DefaultAvatar(
      id: 'healer',
      label: 'Penyembuh',
      asset: 'assets/avatars/healer.svg',
      icon: Icons.favorite,
      color: Color(0xFFD500F9),
    ),
  ];

  static DefaultAvatar byId(String? id) {
    return defaults.firstWhere(
      (avatar) => avatar.id == id,
      orElse: () => defaults.first,
    );
  }
}
