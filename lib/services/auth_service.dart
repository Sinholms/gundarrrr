import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/umkm_profile.dart';

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);
}

class AuthState {
  final AppUser? currentUser;

  const AuthState({this.currentUser});

  bool get isLoggedIn => currentUser != null;

  bool get hasCompletedUmkmRegistration {
    return currentUser?.hasCompletedUmkmRegistration ?? false;
  }
}

class AuthService {
  AuthService._();

  static final ValueNotifier<AuthState> authState = ValueNotifier(
    const AuthState(),
  );
  static final List<AppUser> _users = [];
  static final Map<String, String> _passwordByUserId = {};
  static final List<UmkmProfile> _umkmProfiles = [];

  static AppUser? get currentUser => authState.value.currentUser;

  static Future<AppUser> registerManual({
    required String fullName,
    required String username,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    final normalizedUsername = username.trim().toLowerCase();
    final normalizedEmail = email.trim().toLowerCase();

    if (_users.any((user) => user.username == normalizedUsername)) {
      throw const AuthException('Username sudah dipakai.');
    }
    if (_users.any((user) => user.email == normalizedEmail)) {
      throw const AuthException('Email sudah terdaftar.');
    }

    final now = DateTime.now();
    final user = AppUser(
      userId: _newId('USR'),
      fullName: fullName.trim(),
      username: normalizedUsername,
      email: normalizedEmail,
      authProvider: 'manual',
      hasCompletedUmkmRegistration: false,
      createdAt: now,
      updatedAt: now,
    );

    _users.add(user);
    _passwordByUserId[user.userId] = password;
    return user;
  }

  static Future<AppUser> loginManual({
    required String username,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    final normalizedUsername = username.trim().toLowerCase();
    AppUser? user;
    for (final item in _users) {
      if (item.username == normalizedUsername) {
        user = item;
        break;
      }
    }

    if (user == null || _passwordByUserId[user.userId] != password) {
      throw const AuthException('Username atau password salah.');
    }

    _setCurrentUser(user);
    return user;
  }

  static Future<AppUser> signInWithGooglePlaceholder() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    throw const AuthException(
      'Google Sign-In belum terhubung. TODO: sambungkan package Google Sign-In dan backend auth.',
    );
  }

  static Future<UmkmProfile> saveUmkmProfile({
    required String umkmName,
    required String whatsappNumber,
    required String address,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    final user = currentUser;
    if (user == null) {
      throw const AuthException('Sesi login tidak ditemukan.');
    }

    final now = DateTime.now();
    final profile = UmkmProfile(
      umkmId: _newId('UMKM'),
      ownerUserId: user.userId,
      umkmName: umkmName.trim(),
      whatsappNumber: whatsappNumber.trim(),
      address: address.trim(),
      createdAt: now,
      updatedAt: now,
    );

    _umkmProfiles.removeWhere((item) => item.ownerUserId == user.userId);
    _umkmProfiles.add(profile);

    final updatedUser = user.copyWith(
      hasCompletedUmkmRegistration: true,
      updatedAt: now,
    );
    final index = _users.indexWhere((item) => item.userId == user.userId);
    if (index != -1) _users[index] = updatedUser;
    _setCurrentUser(updatedUser);

    return profile;
  }

  static String generateGoogleUsername(String email) {
    final base = email
        .split('@')
        .first
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9._]'), '_');
    var candidate = base.isEmpty ? 'google_user' : base;
    var suffix = 1;
    while (_users.any((user) => user.username == candidate)) {
      candidate = '${base.isEmpty ? 'google_user' : base}$suffix';
      suffix++;
    }
    return candidate;
  }

  static void logout() {
    authState.value = const AuthState();
  }

  static void _setCurrentUser(AppUser user) {
    authState.value = AuthState(currentUser: user);
  }

  static String _newId(String prefix) {
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}';
  }
}
