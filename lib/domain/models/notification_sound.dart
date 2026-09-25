/// Nada pengingat yang bisa dipilih pengguna.
class NotificationSoundOption {
  final String id;
  final String label;

  /// Nama file di `res/raw`, tanpa ekstensi. Kosong untuk nada sistem.
  final String? rawResource;

  const NotificationSoundOption({
    required this.id,
    required this.label,
    this.rawResource,
  });
}

class NotificationSounds {
  static const List<NotificationSoundOption> options = [
    NotificationSoundOption(id: 'default', label: 'Nada sistem'),
    NotificationSoundOption(id: 'silent', label: 'Senyap'),
    NotificationSoundOption(id: 'bell', label: 'Lonceng', rawResource: 'bell'),
    NotificationSoundOption(
      id: 'chime',
      label: 'Lonceng angin',
      rawResource: 'chime',
    ),
    NotificationSoundOption(
      id: 'horn',
      label: 'Terompet guild',
      rawResource: 'horn',
    ),
    NotificationSoundOption(id: 'pulse', label: 'Denyut', rawResource: 'pulse'),
  ];

  static NotificationSoundOption byId(String? id) {
    return options.firstWhere(
      (sound) => sound.id == id,
      orElse: () => options.first,
    );
  }

  /// Channel Android mengunci suara saat pertama dibuat, jadi tiap nada punya channel sendiri.
  static String channelIdFor(String soundId) {
    final sound = byId(soundId);
    return 'quest_reminders_v3_${sound.id}';
  }
}
