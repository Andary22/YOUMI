// AppProvider: auth session, current user, and global app state.
import 'package:flutter/foundation.dart';
import 'package:youmi_dev/core/supabase_api.dart';
import 'package:youmi_dev/models/user.dart';

class AppProvider extends ChangeNotifier {
  AppUser? _currentUser;
  bool _isAuthenticated = false;
  bool _isBusy = false;
  String? _lastError;

  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isBusy => _isBusy;
  String? get lastError => _lastError;

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
      _lastError = e.toString();
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
      _lastError = e.toString();
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
      _lastError = e.toString();
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
      themePref: 'gruvbox',
    );
    return SupabaseApi.instance.upsertProfile(fresh);
  }

  void _setBusy(bool value) {
    _isBusy = value;
    notifyListeners();
  }
}
