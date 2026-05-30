// AppProvider: auth session, current user, and global app state.
import 'package:flutter/foundation.dart';
import 'package:youmi_dev/core/supabase_api.dart';
import 'package:youmi_dev/models/user.dart';

class AppProvider extends ChangeNotifier {
  AppUser? _currentUser;
  bool _isAuthenticated = false;
  bool _isBusy = false;
  String? _lastError;

  AppUser? get currentUser {
    return _currentUser;
  }

  bool get isAuthenticated {
    return _isAuthenticated;
  }

  bool get isBusy {
    return _isBusy;
  }

  String? get lastError {
    return _lastError;
  }

  Future<bool> signIn(String email, String password) async {
    _setBusy(true);
    try {
      final session = await SupabaseApi.instance.signIn(email, password);
      SupabaseApi.instance.updateSession(session);
      final profile = await _loadOrCreateProfile(session);
      _currentUser = profile;
      _isAuthenticated = true;
      _lastError = null;
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = _formatError(e);
      _isAuthenticated = false;
      notifyListeners();
      return false;
    } finally {
      _setBusy(false);
    }
  }

  Future<bool> signUp(String email, String password) async {
    _setBusy(true);
    try {
      final session = await SupabaseApi.instance.signUp(email, password);
      SupabaseApi.instance.updateSession(session);
      final profile = await _loadOrCreateProfile(session);
      _currentUser = profile;
      _isAuthenticated = true;
      _lastError = null;
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = _formatError(e);
      _isAuthenticated = false;
      notifyListeners();
      return false;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> signOut() async {
    _setBusy(true);
    try {
      await SupabaseApi.instance.signOut();
      _currentUser = null;
      _isAuthenticated = false;
      _lastError = null;
      notifyListeners();
    } catch (e) {
      _lastError = _formatError(e);
      notifyListeners();
    } finally {
      _setBusy(false);
    }
  }

  Future<AppUser> _loadOrCreateProfile(AuthSession session) async {
    final existing = await SupabaseApi.instance.fetchProfile(session.userId);
    if (existing != null) {
      return existing;
    }
    final fresh = AppUser(
      id: session.userId,
      email: session.email,
      themePref: 'gruvbox_material_dark',
    );
    return SupabaseApi.instance.upsertProfile(fresh);
  }

  Future<bool> updateThemePreference(String themeName) async {
    if (_currentUser == null) {
      _lastError = 'No active user session';
      notifyListeners();
      return false;
    }
    try {
      final updated = AppUser(
        id: _currentUser!.id,
        email: _currentUser!.email,
        themePref: themeName,
      );
      _currentUser = await SupabaseApi.instance.upsertProfile(updated);
      _lastError = null;
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = _formatError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateName(String newName) async {
    if (_currentUser == null) {
      _lastError = 'No active user session';
      notifyListeners();
      return false;
    }
    try {
      final updated = AppUser(
        id: _currentUser!.id,
        email: _currentUser!.email,
        themePref: _currentUser!.themePref,
        name: newName,
      );
      _currentUser = await SupabaseApi.instance.upsertProfile(
        updated,
        includeNameField: true,
      );
      _lastError = null;
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = _formatError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateEmail(String newEmail) async {
    if (_currentUser == null) {
      _lastError = 'No active user session';
      notifyListeners();
      return false;
    }
    _setBusy(true);
    try {
      await SupabaseApi.instance.updateEmail(newEmail);
      final updated = AppUser(
        id: _currentUser!.id,
        email: newEmail,
        themePref: _currentUser!.themePref,
        name: _currentUser!.name,
      );
      _currentUser = await SupabaseApi.instance.upsertProfile(updated);
      _lastError = null;
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = _formatError(e);
      notifyListeners();
      return false;
    } finally {
      _setBusy(false);
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    _setBusy(true);
    try {
      await SupabaseApi.instance.updatePassword(newPassword);
      _lastError = null;
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = _formatError(e);
      notifyListeners();
      return false;
    } finally {
      _setBusy(false);
    }
  }

  String _formatError(Object error) {
    if (error is SupabaseApiException) {
      final String? friendly = _friendlyFromText(error.message);
      if (friendly != null) {
        return friendly;
      }
      return error.message;
    }
    final String text = error.toString();
    final String? friendly = _friendlyFromText(text);
    if (friendly != null) {
      return friendly;
    }
    return text;
  }

  String? _friendlyFromText(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('invalid_credentials') ||
        lower.contains('invalid login credentials')) {
      return 'Email or password is incorrect.';
    }
    if (lower.contains('email_not_confirmed') ||
        lower.contains('email not confirmed')) {
      return 'Please confirm your email, then try again.';
    }
    if (lower.contains('user_already_registered') ||
        lower.contains('email already') ||
        lower.contains('already registered') ||
        lower.contains('already exists')) {
      return 'An account with this email already exists. Try signing in.';
    }
    if (lower.contains('weak_password')) {
      return 'Password is too weak. Try a stronger password.';
    }
    if (lower.contains('email_address_invalid')) {
      return 'Please enter a valid email address.';
    }
    if (lower.contains('validation_failed') ||
        lower.contains('unable to validate email address')) {
      return 'Please enter a valid email address.';
    }
    if (lower.contains('signup_disabled')) {
      return 'Sign up is currently disabled. Please try again later.';
    }
    return null;
  }

  void _setBusy(bool value) {
    _isBusy = value;
    notifyListeners();
  }
}