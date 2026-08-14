import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../storage/storage_service.dart';

/// Thin HTTP layer over the Laravel API.
///
/// Kept as a static class on purpose - every existing repository
/// already calls `ApiClient.get(...)` / `ApiClient.post(...)`, and
/// changing that shape would have meant touching every call site for
/// no functional gain.
///
/// What it guarantees to callers:
///  * `Authorization: Bearer <token>` is attached automatically when a
///    session exists (never hardcoded anywhere in the app),
///  * a non-2xx response always throws [ApiException] - it never
///    returns `null` silently,
///  * Laravel's two envelopes are both understood:
///      success -> {success, data, message, status_code}
///      failure -> {success:false, error_message, status_code}
///    plus the framework's own 422 `{message, errors:{field:[..]}}`,
///  * 401 clears the stored session and notifies [onUnauthorized] so
///    the shell can bounce the user back to login.
class ApiClient {
  ApiClient._();

  /// Base for expert endpoints, e.g. `.../api/expert`.
  static String get baseUrl => AppConfig.apiBase;

  /// Root for cross-role endpoints that are not under the expert
  /// prefix (kept for clarity; this build only uses the expert tree).
  static String get apiRoot => AppConfig.apiRoot;

  static const Duration timeout = Duration(seconds: 30);

  /// In-memory mirror of the persisted token so header building does
  /// not hit the disk on every request.
  static String? _token;

  /// Invoked once when the server rejects the session. The app shell
  /// wires this to "go back to login".
  static void Function()? onUnauthorized;

  // ── session ─────────────────────────────────────────────────────

  static Future<void> setToken(String token) async {
    _token = token;
    await StorageService.saveToken(token);
  }

  static Future<String?> getToken() async {
    if (_token != null && _token!.isNotEmpty) return _token;
    _token = await StorageService.getToken();
    return _token;
  }

  static Future<void> clearToken() async {
    _token = null;
    await StorageService.removeToken();
  }

  static bool get hasToken => _token != null && _token!.isNotEmpty;

  static String? get token => _token;

  /// Called from `main()` after [StorageService.init] so the very first
  /// request already carries the header.
  static Future<void> restoreSession() async {
    _token = await StorageService.getToken();
  }

  // ── headers ─────────────────────────────────────────────────────

  static Future<Map<String, String>> _headers({bool json = true}) async {
    final value = await getToken();
    return {
      'Accept': 'application/json',
      if (json) 'Content-Type': 'application/json',
      if (value != null && value.isNotEmpty) 'Authorization': 'Bearer $value',
    };
  }

  /// Builds the request URI.
  ///
  /// A LEADING SLASH means "relative to /api" instead of "relative to
  /// /api/expert". Notifications are served by one controller for every
  /// account type, so they live at the API root rather than under a role
  /// prefix, and need a way to escape [baseUrl].
  static Uri _uri(String endpoint, [Map<String, dynamic>? query]) {
    final uri = endpoint.startsWith('/')
        ? Uri.parse('${AppConfig.apiRoot}$endpoint')
        : Uri.parse('$baseUrl/$endpoint');

    if (query == null || query.isEmpty) return uri;

    // Drop nulls so callers can pass optional filters inline without
    // building the map conditionally at every call site.
    final params = <String, String>{
      ...uri.queryParameters,
      for (final entry in query.entries)
        if (entry.value != null) entry.key: entry.value.toString(),
    };

    return uri.replace(queryParameters: params.isEmpty ? null : params);
  }

  // ── verbs ───────────────────────────────────────────────────────

  static Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? query,
  }) async {
    return _send(
      () async => http.get(_uri(endpoint, query), headers: await _headers()),
    );
  }

  static Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
  }) async {
    return _send(
      () async => http.post(
        _uri(endpoint, query),
        headers: await _headers(),
        body: body != null ? jsonEncode(body) : null,
      ),
    );
  }

  static Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
  }) async {
    return _send(
      () async => http.put(
        _uri(endpoint, query),
        headers: await _headers(),
        body: body != null ? jsonEncode(body) : null,
      ),
    );
  }

  static Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
  }) async {
    return _send(
      () async => http.patch(
        _uri(endpoint, query),
        headers: await _headers(),
        body: body != null ? jsonEncode(body) : null,
      ),
    );
  }

  static Future<dynamic> delete(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
  }) async {
    return _send(
      () async => http.delete(
        _uri(endpoint, query),
        headers: await _headers(),
        body: body != null ? jsonEncode(body) : null,
      ),
    );
  }

  // ── multipart ───────────────────────────────────────────────────

  /// Multipart POST.
  ///
  /// [fileField] is the form key the backend expects. For repeated
  /// files Laravel wants the `[]` suffix (`media[]`); for a single file
  /// it wants the bare name (`media`, `main_image`, `profile_photo`).
  /// Pass exactly what the endpoint documents - this method does not
  /// guess.
  ///
  /// [files] lets one request carry several *different* single-file
  /// fields at once (e.g. `profile_photo` + `cover_photo`).
  static Future<dynamic> postMultipart(
    String endpoint, {
    required Map<String, String> fields,
    String? fileField,
    List<String>? filePaths,
    Map<String, String>? files,
    String? methodOverride,
  }) async {
    return _send(() async {
      final request = http.MultipartRequest('POST', _uri(endpoint))
        ..headers.addAll(await _headers(json: false))
        ..fields.addAll(fields);

      // Laravel reads `_method` to route a POST body to a PUT/PATCH
      // handler - needed because multipart bodies do not survive a
      // real PUT on every client.
      if (methodOverride != null) {
        request.fields['_method'] = methodOverride;
      }

      if (fileField != null && filePaths != null && filePaths.isNotEmpty) {
        for (final path in filePaths) {
          if (path.isEmpty) continue;
          if (!await File(path).exists()) continue;
          request.files.add(await http.MultipartFile.fromPath(fileField, path));
        }
      }

      if (files != null) {
        for (final entry in files.entries) {
          if (entry.value.isEmpty) continue;
          if (!await File(entry.value).exists()) continue;
          request.files
              .add(await http.MultipartFile.fromPath(entry.key, entry.value));
        }
      }

      final streamed = await request.send().timeout(timeout);
      return http.Response.fromStream(streamed);
    });
  }

  /// Multipart "PUT" - sent as POST with `_method=PUT`, which is what
  /// the backend's `Route::match(['put','post'], ...)` pairs expect.
  static Future<dynamic> putMultipart(
    String endpoint, {
    required Map<String, String> fields,
    String? fileField,
    List<String>? filePaths,
    Map<String, String>? files,
  }) {
    return postMultipart(
      endpoint,
      fields: fields,
      fileField: fileField,
      filePaths: filePaths,
      files: files,
      methodOverride: 'PUT',
    );
  }

  // ── plumbing ────────────────────────────────────────────────────

  static Future<dynamic> _send(
    Future<http.Response> Function() request,
  ) async {
    http.Response response;

    try {
      response = await request().timeout(timeout);
    } on SocketException {
      throw const ApiException(
        message: 'Cannot reach the server. Check your connection.',
        statusCode: 0,
      );
    } on TimeoutException {
      throw const ApiException(
        message: 'The server took too long to respond. Please try again.',
        statusCode: 0,
      );
    } on http.ClientException catch (e) {
      throw ApiException(message: e.message, statusCode: 0);
    }

    return _handleResponse(response);
  }

  static dynamic _handleResponse(http.Response response) {
    final raw = utf8.decode(response.bodyBytes, allowMalformed: true);

    dynamic decoded;
    try {
      decoded = raw.isEmpty ? <String, dynamic>{} : jsonDecode(raw);
    } catch (_) {
      // A non-JSON body at this point is almost always an HTML error
      // page from PHP. Surfacing raw HTML helps nobody.
      decoded = <String, dynamic>{
        'message': response.statusCode >= 500
            ? 'Server error, please try again later'
            : 'Unexpected response from the server',
      };
    }

    if (kDebugMode) {
      debugPrint('[API] ${response.statusCode} ${response.request?.url}');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    if (response.statusCode == 401) {
      // Session is gone server-side; drop it locally too so the app
      // does not keep sending a dead token.
      unawaited(clearToken());
      onUnauthorized?.call();
    }

    throw ApiException(
      message: _extractMessage(decoded),
      statusCode: response.statusCode,
      errors: _extractErrors(decoded),
    );
  }

  /// Handles, in order: Laravel validation (`errors`), this API's own
  /// failure envelope (`error_message`), and the framework default
  /// (`message`).
  static String _extractMessage(dynamic decoded) {
    if (decoded is Map) {
      final errors = decoded['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
        if (first != null) return first.toString();
      }

      final candidates = [
        decoded['error_message'],
        decoded['message'],
        decoded['error'],
      ];

      for (final candidate in candidates) {
        if (candidate is String && candidate.isNotEmpty) return candidate;
      }
    }

    return 'Something went wrong. Please try again.';
  }

  /// Field-level validation errors, flattened to `{field: firstMessage}`
  /// so a form can attach each one to the right input.
  static Map<String, String> _extractErrors(dynamic decoded) {
    if (decoded is! Map) return const {};

    final errors = decoded['errors'];
    if (errors is! Map) return const {};

    final result = <String, String>{};
    errors.forEach((key, value) {
      if (value is List && value.isNotEmpty) {
        result[key.toString()] = value.first.toString();
      } else if (value != null) {
        result[key.toString()] = value.toString();
      }
    });

    return result;
  }
}

/// Every failed request surfaces as one of these, so BLoCs have a
/// single type to catch and a user-safe [message] to show.
class ApiException implements Exception {
  const ApiException({
    required this.message,
    required this.statusCode,
    this.errors = const {},
  });

  final String message;
  final int statusCode;

  /// `{field: message}` from a 422. Empty for every other status.
  final Map<String, String> errors;

  bool get isValidation => statusCode == 422 && errors.isNotEmpty;
  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isNetwork => statusCode == 0;

  /// The message for a specific form field, if the server flagged it.
  String? errorFor(String field) => errors[field];

  @override
  String toString() => 'ApiException($statusCode): $message';
}
