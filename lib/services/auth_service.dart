import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user_model.dart';
import 'user_progress_repository.dart';
import 'storage_helper.dart';

class RegisterResult {
  final UserModel? user;
  final bool requiresEmailVerification;
  final String email;

  RegisterResult({
    this.user,
    required this.requiresEmailVerification,
    required this.email,
  });
}

class AuthService extends ChangeNotifier {
  static final AuthService instance = AuthService._internal();
  AuthService._internal() {
    _initAuthListener();
  }

  UserModel? _currentUser;
  final Map<String, UserModel> _localRegisteredUsers = {};

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  void _initAuthListener() {
    _loadLocalUsers();
    
    if (SupabaseConfig.isConfigured) {
      try {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          _mapSupabaseUser(session.user);
        }

        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
          final session = data.session;
          if (session != null) {
            _mapSupabaseUser(session.user);
          } else {
            _currentUser = null;
            notifyListeners();
          }
        });
      } catch (e) {
        debugPrint('Supabase Auth init notice: $e');
      }
    }
  }

  void _mapSupabaseUser(User suUser) {
    final displayName = (suUser.userMetadata?['display_name'] as String?) ??
        suUser.email?.split('@').first ??
        'Cadet';

    _currentUser = UserModel(
      uid: suUser.id,
      email: suUser.email ?? 'cadet@maritime.com',
      displayName: displayName,
    );
    UserProgressRepository.instance.syncFromSupabase(suUser.id);
    notifyListeners();
  }

  void _loadLocalUsers() {
    try {
      final rawJson = StorageHelper.getItem('maritime_auth_users_v1');
      if (rawJson != null && rawJson.isNotEmpty) {
        final Map<String, dynamic> decoded = jsonDecode(rawJson);
        decoded.forEach((uid, val) {
          _localRegisteredUsers[uid] = UserModel.fromJson(Map<String, dynamic>.from(val));
        });
      }
    } catch (e) {
      debugPrint('Error loading local users: $e');
    }
  }

  void _saveLocalUsers() {
    try {
      final mapToSave = <String, dynamic>{};
      _localRegisteredUsers.forEach((uid, user) {
        mapToSave[uid] = user.toJson();
      });
      StorageHelper.setItem('maritime_auth_users_v1', jsonEncode(mapToSave));
    } catch (e) {
      debugPrint('Error saving local users: $e');
    }
  }

  /// Registers a new student account using Supabase Auth.
  Future<RegisterResult> registerUser({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final cleanEmail = email.trim();
    final cleanName = displayName.trim().isEmpty ? 'Cadet' : displayName.trim();

    if (SupabaseConfig.isConfigured) {
      try {
        final response = await Supabase.instance.client.auth.signUp(
          email: cleanEmail,
          password: password,
          data: {'display_name': cleanName},
        );

        final suUser = response.user;
        final hasSession = response.session != null;

        if (suUser != null) {
          final user = UserModel(
            uid: suUser.id,
            email: suUser.email ?? cleanEmail,
            displayName: cleanName,
          );

          if (hasSession) {
            _currentUser = user;
            UserProgressRepository.instance.initFreshUser(user.uid);
            notifyListeners();
            return RegisterResult(
              user: user,
              requiresEmailVerification: false,
              email: cleanEmail,
            );
          } else {
            return RegisterResult(
              user: null,
              requiresEmailVerification: true,
              email: cleanEmail,
            );
          }
        }
      } catch (e) {
        debugPrint('Supabase signup error: $e');
        rethrow;
      }
    }

    // Local authentication fallback
    final uid = cleanEmail.toLowerCase();
    final user = UserModel(
      uid: uid,
      email: cleanEmail,
      displayName: cleanName,
    );

    _localRegisteredUsers[uid] = user;
    _saveLocalUsers();

    UserProgressRepository.instance.initFreshUser(uid);
    _currentUser = user;
    notifyListeners();
    return RegisterResult(
      user: user,
      requiresEmailVerification: false,
      email: cleanEmail,
    );
  }

  /// Resends email verification link to user's email.
  Future<void> resendVerificationEmail(String email) async {
    if (SupabaseConfig.isConfigured) {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: email.trim(),
      );
    }
  }

  /// Triggers a password reset email for the given email address.
  Future<void> resetPasswordForEmail(String email) async {
    if (SupabaseConfig.isConfigured) {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email.trim(),
      );
    }
  }

  /// Logs in an existing student account using Supabase Auth.
  Future<UserModel> loginUser({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final cleanEmail = email.trim();

    if (SupabaseConfig.isConfigured) {
      try {
        final response = await Supabase.instance.client.auth.signInWithPassword(
          email: cleanEmail,
          password: password,
        );

        final suUser = response.user;
        if (suUser != null) {
          _mapSupabaseUser(suUser);
          return _currentUser!;
        }
      } catch (e) {
        debugPrint('Supabase login network notice: $e');
        // Fall back to local mode if offline/DNS host lookup failed
      }
    }

    // Local / Offline authentication fallback
    final uid = cleanEmail.toLowerCase();
    final name = displayName ?? (cleanEmail.contains('@') ? cleanEmail.split('@').first : 'Cadet');
    final user = UserModel(
      uid: uid,
      email: cleanEmail,
      displayName: name,
    );

    _currentUser = user;
    notifyListeners();
    return _currentUser!;
  }

  /// Instant offline / guest login for quick access.
  void loginAsGuest() {
    _currentUser = UserModel(
      uid: 'guest_cadet',
      email: 'cadet@maritime.com',
      displayName: 'Guest Cadet',
    );
    notifyListeners();
  }

  /// Logs out the active user session.
  Future<void> logout() async {
    if (SupabaseConfig.isConfigured) {
      try {
        await Supabase.instance.client.auth.signOut();
      } catch (e) {
        debugPrint('Supabase signout notice: $e');
      }
    }
    _currentUser = null;
    notifyListeners();
  }
}
