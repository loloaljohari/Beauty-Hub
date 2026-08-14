import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Single, reusable entry point for everything the app persists with
/// `shared_preferences`.
///
/// Nothing outside this file should call `SharedPreferences.getInstance()`
/// directly - that is what made token handling inconsistent before
/// (some places read the cached static field, others re-read the disk,
/// and one BLoC had a token pasted into the source).
///
/// What belongs here: small, flat, non-sensitive values that must
/// survive an app restart. What does NOT belong here: lists of
/// bookings/services/orders (they come from the API and go stale),
/// anything relational, and anything genuinely secret beyond the
/// session token.
class StorageService {
  StorageService._();

  // ── keys ────────────────────────────────────────────────────────
  static const String _kToken = 'token';
  static const String _kUserId = 'user_id';
  static const String _kUserName = 'user_name';
  static const String _kUserEmail = 'user_email';
  static const String _kUserPhoto = 'user_photo';
  static const String _kSpecialization = 'user_specialization';
  static const String _kRememberMe = 'remember_me';
  static const String _kRememberedEmail = 'remembered_email';
  static const String _kPendingOtpEmail = 'pending_otp_email';
  static const String _kLocale = 'locale';
  static const String _kOnboardingSeen = 'onboarding_seen';
  static const String _kDeviceTokenSynced = 'device_token_synced';
  static const String _kLastReservationsTab = 'last_reservations_tab';
  static const String _kLastOffersTab = 'last_offers_tab';
  static const String _kUnreadChats = 'unread_chats';

  static SharedPreferences? _prefs;

  /// Call once from `main()` before `runApp` so later reads are
  /// synchronous and never race.
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static Future<SharedPreferences> get _instance async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  // ── auth token ──────────────────────────────────────────────────

  static Future<void> saveToken(String token) async {
    final prefs = await _instance;
    await prefs.setString(_kToken, token);
  }

  static Future<String?> getToken() async {
    final prefs = await _instance;
    final token = prefs.getString(_kToken);
    return (token == null || token.isEmpty) ? null : token;
  }

  /// Synchronous read - only valid after [init].
  static String? get tokenSync {
    final token = _prefs?.getString(_kToken);
    return (token == null || token.isEmpty) ? null : token;
  }

  static Future<void> removeToken() async {
    final prefs = await _instance;
    await prefs.remove(_kToken);
  }

  static Future<bool> isLoggedIn() async => (await getToken()) != null;

  // ── identity of the signed-in expert ────────────────────────────

  static Future<void> saveUserId(int id) async {
    final prefs = await _instance;
    await prefs.setInt(_kUserId, id);
  }

  static Future<int?> getUserId() async {
    final prefs = await _instance;
    return prefs.getInt(_kUserId);
  }

  /// Caches the handful of profile fields the shell (drawer header,
  /// app bar avatar) needs on first frame, so those do not flash empty
  /// while `GET /auth/profile` is still in flight.
  static Future<void> saveUserSummary({
    int? id,
    String? name,
    String? email,
    String? photo,
    String? specialization,
  }) async {
    final prefs = await _instance;
    if (id != null) await prefs.setInt(_kUserId, id);
    if (name != null) await prefs.setString(_kUserName, name);
    if (email != null) await prefs.setString(_kUserEmail, email);
    if (photo != null) await prefs.setString(_kUserPhoto, photo);
    if (specialization != null) {
      await prefs.setString(_kSpecialization, specialization);
    }
  }

  static Future<Map<String, String?>> getUserSummary() async {
    final prefs = await _instance;
    return {
      'name': prefs.getString(_kUserName),
      'email': prefs.getString(_kUserEmail),
      'photo': prefs.getString(_kUserPhoto),
      'specialization': prefs.getString(_kSpecialization),
    };
  }

  static String? get cachedUserName => _prefs?.getString(_kUserName);
  static String? get cachedUserPhoto => _prefs?.getString(_kUserPhoto);

  // ── "remember me" on the login form ─────────────────────────────

  static Future<void> saveRememberMe(bool remember, {String? email}) async {
    final prefs = await _instance;
    await prefs.setBool(_kRememberMe, remember);
    if (remember && email != null && email.isNotEmpty) {
      await prefs.setString(_kRememberedEmail, email);
    } else {
      await prefs.remove(_kRememberedEmail);
    }
  }

  static Future<bool> getRememberMe() async {
    final prefs = await _instance;
    return prefs.getBool(_kRememberMe) ?? false;
  }

  static Future<String?> getRememberedEmail() async {
    final prefs = await _instance;
    return prefs.getString(_kRememberedEmail);
  }

  // ── OTP flow ────────────────────────────────────────────────────
  // Register -> OTP -> verify can be interrupted (app killed, user
  // switches to the mail app). Persisting the pending email means the
  // verification screen still knows who it is verifying on return.

  static Future<void> savePendingOtpEmail(String email) async {
    final prefs = await _instance;
    await prefs.setString(_kPendingOtpEmail, email);
  }

  static Future<String?> getPendingOtpEmail() async {
    final prefs = await _instance;
    return prefs.getString(_kPendingOtpEmail);
  }

  static Future<void> clearPendingOtpEmail() async {
    final prefs = await _instance;
    await prefs.remove(_kPendingOtpEmail);
  }

  // ── app preferences ─────────────────────────────────────────────

  static Future<void> saveLocale(String languageCode) async {
    final prefs = await _instance;
    await prefs.setString(_kLocale, languageCode);
  }

  static Future<String?> getLocale() async {
    
    final prefs = await _instance;
    print(prefs.getString(_kLocale));
    return prefs.getString(_kLocale);
  }

  static String? get localeSync => _prefs?.getString(_kLocale);

  static Future<void> setOnboardingSeen(bool seen) async {
    final prefs = await _instance;
    await prefs.setBool(_kOnboardingSeen, seen);
  }

  static Future<bool> getOnboardingSeen() async {
    final prefs = await _instance;
    return prefs.getBool(_kOnboardingSeen) ?? false;
  }

  // ── last-used UI selections ─────────────────────────────────────
  // Small, genuinely useful bits of continuity: the tab the user was
  // last looking at. Cheap to store, and wrong-but-harmless if stale.

  static Future<void> saveLastReservationsTab(int index) async {
    final prefs = await _instance;
    await prefs.setInt(_kLastReservationsTab, index);
  }

  static Future<int> getLastReservationsTab() async {
    final prefs = await _instance;
    return prefs.getInt(_kLastReservationsTab) ?? 0;
  }

  static Future<void> saveLastOffersTab(int index) async {
    final prefs = await _instance;
    await prefs.setInt(_kLastOffersTab, index);
  }

  static Future<int> getLastOffersTab() async {
    final prefs = await _instance;
    return prefs.getInt(_kLastOffersTab) ?? 0;
  }

  // ── FCM device token ────────────────────────────────────────────
  // POST /expert/device-token is idempotent but pointless to repeat on
  // every cold start; remember the last value we successfully synced.

  static Future<void> saveSyncedDeviceToken(String token) async {
    final prefs = await _instance;
    await prefs.setString(_kDeviceTokenSynced, token);
  }

  static Future<String?> getSyncedDeviceToken() async {
    final prefs = await _instance;
    return prefs.getString(_kDeviceTokenSynced);
  }

  // ── chat badge ──────────────────────────────────────────────────

  static Future<void> saveUnreadChats(int count) async {
    final prefs = await _instance;
    await prefs.setInt(_kUnreadChats, count);
  }

  static int get cachedUnreadChats => _prefs?.getInt(_kUnreadChats) ?? 0;

  // ── generic JSON cache ──────────────────────────────────────────
  // Used sparingly, for last-known-good snapshots of small screens so
  // they can render instantly and then refresh in the background.

  static Future<void> saveJson(String key, Object value) async {
    final prefs = await _instance;
    await prefs.setString('cache_$key', jsonEncode(value));
  }

  static Future<dynamic> readJson(String key) async {
    final prefs = await _instance;
    final raw = prefs.getString('cache_$key');
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  // ── sign-out ────────────────────────────────────────────────────

  /// Clears everything tied to the session but deliberately keeps
  /// device-independent preferences (language, onboarding) so the app
  /// does not feel reset after a logout.
  static Future<void> clearUserData() async {
    final prefs = await _instance;
    await prefs.remove(_kToken);
    await prefs.remove(_kUserId);
    await prefs.remove(_kUserName);
    await prefs.remove(_kUserEmail);
    await prefs.remove(_kUserPhoto);
    await prefs.remove(_kSpecialization);
    await prefs.remove(_kPendingOtpEmail);
    await prefs.remove(_kDeviceTokenSynced);
    await prefs.remove(_kUnreadChats);
    await prefs.remove(_kLastReservationsTab);
    await prefs.remove(_kLastOffersTab);

    for (final key in prefs.getKeys().where((k) => k.startsWith('cache_'))) {
      await prefs.remove(key);
    }
  }
}
