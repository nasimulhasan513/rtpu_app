import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    _initialize();
  }

  final AuthService _authService = AuthService();
  Map<String, dynamic>? _user;
  AuthStatus _status = AuthStatus.unknown;
  bool _busy = false;
  String? _error;

  Map<String, dynamic>? get user => _user;
  AuthStatus get status => _status;
  bool get busy => _busy;
  String? get error => _error;

  Future<void> _initialize() async {
    try {
      final me = await _authService.currentUser();
      if (me != null) {
        _user = me;
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> signIn({required String cred, required String password, required String type}) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      final ok = await _authService.signIn(cred: cred, password: password, type: type);
      if (ok) {
        _user = await _authService.currentUser();
        _status = _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      }
      return ok;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle() async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: const ['email', 'profile']);
      // Ensure clean session if needed
      try {
        await googleSignIn.signOut();
      } catch (_) {}
      // Try silent first for smoother UX
      GoogleSignInAccount? account = await googleSignIn.signInSilently();
      account ??= await googleSignIn.signIn();
      if (account == null) {
        _error = 'Google sign-in cancelled';
        return false;
      }
      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;
      final String? accessToken = auth.accessToken;
      if (idToken == null && accessToken == null) {
        _error = 'Failed to get Google credentials';
        return false;
      }
      final ok = await _authService.googleLogin(idToken: idToken, accessToken: accessToken);
      if (ok) {
        _user = await _authService.currentUser();
        _status = _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      }
      return ok;
    } catch (e) {
      _error = e.toString();
      log('error: $e');
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _busy = true;
    notifyListeners();
    try {
      await _authService.logout();
    } finally {
      _user = null;
      _status = AuthStatus.unauthenticated;
      _busy = false;
      notifyListeners();
    }
  }

  Future<bool> saveProfile(Map<String, dynamic> payload) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.updateProfile(payload);
      _user = await _authService.currentUser();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}

