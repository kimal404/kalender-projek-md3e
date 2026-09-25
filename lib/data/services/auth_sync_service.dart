import 'package:quest_kalender/domain/models/quest_model.dart';
import 'package:quest_kalender/domain/models/user_profile_model.dart';

abstract class AuthSyncService {
  Future<bool> signIn(String email, String password);
  Future<void> signOut();
  bool get isAuthenticated;
  String? get currentUserId;
  Future<bool> syncWithCloud({
    required List<Quest> localQuests,
    required UserProfile profile,
  });
}

class LocalAuthSyncService implements AuthSyncService {
  bool _isLoggedIn = false;
  String? _userId;

  @override
  bool get isAuthenticated => _isLoggedIn;

  @override
  String? get currentUserId => _userId;

  @override
  Future<bool> signIn(String email, String password) async {
    // Simulasi autentikasi lokal
    await Future.delayed(const Duration(milliseconds: 300));
    _isLoggedIn = true;
    _userId = 'local-hero-${email.split('@').first}';
    return true;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _isLoggedIn = false;
    _userId = null;
  }

  @override
  Future<bool> syncWithCloud({
    required List<Quest> localQuests,
    required UserProfile profile,
  }) async {
    // Siap disambungkan ke Firebase Firestore / Supabase PostgREST
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }
}
