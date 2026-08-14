/// Helpers for reading the backend's response envelope without a
/// cast-crash on every field.
///
/// Two things make defensive parsing worth the small amount of code
/// here:
///
///  1. `ApiResponseTrait::sendResponse` **removes** the `data` key
///     when the payload is empty. `POST /auth/update_profile` and
///     `POST /auth/logout` both return `{success, message, status_code}`
///     with no `data` at all, so `response['data']['x']` throws.
///  2. MySQL returns `DECIMAL` columns as strings through PDO, so
///     `price`, `rating_avg`, `stock_quantity` arrive as `"45.00"` on
///     one endpoint and `45` on another. `double.parse(json['price'])`
///     works until the day it does not.
class ApiResponse {
  ApiResponse._();

  /// The `data` object of a success envelope, or an empty map when the
  /// backend omitted it.
  static Map<String, dynamic> data(dynamic response) {
    if (response is! Map) return const {};
    final payload = response['data'];
    if (payload is Map) return Map<String, dynamic>.from(payload);
    return const {};
  }

  /// A nested object inside `data`, e.g. `data.booking`.
  static Map<String, dynamic> object(dynamic response, String key) {
    return asMap(data(response)[key]);
  }

  /// A list inside `data`, e.g. `data.bookings`.
  ///
  /// Also copes with the endpoints that return a paginator in `data`
  /// (`getMyPosts`), where the rows live one level deeper in
  /// `data.data`.
  static List<dynamic> list(dynamic response, String key) {
    final payload = data(response);

    final direct = payload[key];
    if (direct is List) return direct;

    // Paginator shape: {data: {current_page, data: [...]}}
    final nested = payload['data'];
    if (nested is List) return nested;

    // Some endpoints put the list straight in `data`.
    if (response is Map && response['data'] is List) {
      return response['data'] as List;
    }

    return const [];
  }

  /// Rows out of a Laravel paginator, wherever it happens to sit.
  static List<dynamic> paginated(dynamic response) {
    final payload = data(response);
    final rows = payload['data'];
    if (rows is List) return rows;
    if (response is Map && response['data'] is List) {
      return response['data'] as List;
    }
    return const [];
  }

  /// Paginator metadata, so a list screen can know whether to keep
  /// loading. Missing keys default to a single-page result.
  static PageInfo pageInfo(dynamic response) {
    final payload = data(response);
    return PageInfo(
      currentPage: asInt(payload['current_page'], fallback: 1),
      lastPage: asInt(payload['last_page'], fallback: 1),
      total: asInt(payload['total']),
      nextPageUrl: payload['next_page_url']?.toString() ??
          payload['nextPageUrl']?.toString(),
    );
  }

  static String message(dynamic response, [String fallback = '']) {
    if (response is Map) {
      final value = response['message'] ?? response['error_message'];
      if (value is String && value.isNotEmpty) return value;
    }
    return fallback;
  }

  // ── loose-type coercion ─────────────────────────────────────────

  static Map<String, dynamic> asMap(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return const {};
  }

  static List<Map<String, dynamic>> asMapList(dynamic value) {
    if (value is! List) return const [];
    return value.whereType<Map>().map(asMap).toList();
  }

  static String asString(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    final text = value.toString();
    return text == 'null' ? fallback : text;
  }

  /// Empty strings collapse to null so the UI can show a placeholder
  /// rather than a blank line.
  static String? asStringOrNull(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return (text.isEmpty || text == 'null') ? null : text;
  }

  static int asInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static double asDouble(dynamic value, {double fallback = 0}) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  static bool asBool(dynamic value, {bool fallback = false}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final text = value.toLowerCase();
      if (text == 'true' || text == '1') return true;
      if (text == 'false' || text == '0') return false;
    }
    return fallback;
  }

  /// `2026-09-14T00:00:00.000000Z` and `2026-09-14` both arrive from
  /// this API depending on the cast; this returns the date part only.
  static String asDate(dynamic value, {String fallback = ''}) {
    final text = asStringOrNull(value);
    if (text == null) return fallback;
    return text.contains('T') ? text.split('T').first : text;
  }

  /// `10:00:00` -> `10:00`. Leaves anything shorter untouched.
  static String asTime(dynamic value, {String fallback = ''}) {
    final text = asStringOrNull(value);
    if (text == null) return fallback;
    return text.length >= 5 ? text.substring(0, 5) : text;
  }
}

class PageInfo {
  const PageInfo({
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
    this.nextPageUrl,
  });

  final int currentPage;
  final int lastPage;
  final int total;
  final String? nextPageUrl;

  bool get hasMore => nextPageUrl != null || currentPage < lastPage;
}
