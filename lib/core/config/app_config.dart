/// Single source of truth for every backend URL the app talks to.
///
/// Only this file needs to change when moving from the local Laravel
/// server to staging/production. Nothing else in the app should build
/// a raw URL by hand.
///
/// Values mirror the Postman environment "Beauty Hub Local":
///   base_url = http://127.0.0.1:8000
class AppConfig {
  AppConfig._();

  /// Host of the Laravel server, no trailing slash.
  ///
  /// Can be overridden at build time without touching the code:
  ///   flutter run --dart-define=BASE_URL=http://192.168.1.20:8000
  ///
  /// Note for Android emulators: 127.0.0.1 points at the emulator
  /// itself, not at the developer machine. Use 10.0.2.2 there.
  static const String host = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  /// Root of the JSON API (`routes/api.php` is served under `/api`).
  static const String apiRoot = '$host/api';

  /// The role prefix this app authenticates as. The backend registers
  /// the same shapes under `customer|expert|salon|center|warehouse`;
  /// this build is the Expert app.
  static const String rolePrefix = 'expert';

  /// Base for all expert endpoints, e.g. `$apiBase/auth/login`.
  static const String apiBase = '$apiRoot/$rolePrefix';

  /// Public disk root. The backend stores relative paths in
  /// `media_json`, `media_url`, `profile_photo`, ... and exposes them
  /// through `Storage::disk('public')` at `/storage/<path>`.
  static const String storageRoot = '$host/storage';

  /// Turns whatever the backend returned into something
  /// [Image.network] / [CachedNetworkImage] can actually load.
  ///
  /// Handles the three shapes the API mixes:
  ///  * already absolute  -> returned untouched
  ///  * `storage/foo.jpg` -> host + path
  ///  * `post_media/x.jpg`-> host + /storage/ + path
  ///
  /// Returns `null` for null/empty input so callers can fall back to a
  /// placeholder instead of firing a request at a broken URL.
  static String? mediaUrl(String? path) {
    if (path == null) return null;

    final trimmed = path.trim();
    if (trimmed.isEmpty) return null;

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    final clean = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;

    if (clean.startsWith('storage/')) {
      return '$host/$clean';
    }

    return '$storageRoot/$clean';
  }

  /// Same as [mediaUrl] but for a list of paths (`media_json`).
  static List<String> mediaUrls(dynamic raw) {
    if (raw is! List) return const [];

    return raw
        .map((e) => mediaUrl(e?.toString()))
        .whereType<String>()
        .toList(growable: false);
  }
}
