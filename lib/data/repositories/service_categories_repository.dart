import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_response.dart';
import '../../core/storage/storage_service.dart';

/// The `service_categories` table, fetched once and cached.
///
/// Why a cache rather than a normal async repository call: four screens
/// read the category list synchronously inside `build()`
/// (add material, update material, add product, add service). Making
/// the getter async would have meant rewriting all four into
/// FutureBuilders for data that changes about once a year.
///
/// Why it matters at all: the list used to be hardcoded as
/// `1 Nail care, 2 Hair care, ...`, but those ids are invented. The real
/// table is managed by the Super Admin, and a live server returned
/// "Hair Care Products" - a name absent from the local list. Saving a
/// material with a guessed id therefore filed it under whatever
/// category happens to hold that id on that server.
///
/// The list survives a restart via [StorageService], so the very first
/// frame after a cold open still shows real categories rather than the
/// fallback.
class ServiceCategoriesRepository {
  ServiceCategoriesRepository._();

  static const String _cacheKey = 'service_categories';

  /// Used only until the real list arrives, and if the endpoint is
  /// missing entirely. Deliberately kept as the previous hardcoded
  /// values so behaviour never gets worse than it was.
  static const List<Map<String, dynamic>> _fallback = [
    {'id': 1, 'name': 'Nail care'},
    {'id': 2, 'name': 'Hair care'},
    {'id': 3, 'name': 'Skin care'},
    {'id': 4, 'name': 'Makeup'},
    {'id': 5, 'name': 'Tools'},
  ];

  static List<Map<String, dynamic>>? _cache;

  /// Synchronous accessor for `build()` methods.
  static List<Map<String, dynamic>> get all => _cache ?? _fallback;

  /// True once real categories are loaded, so a screen can tell the
  /// difference between "server list" and "guess".
  static bool get isLoaded => _cache != null;

  /// Restores the last known list from local storage. Called from
  /// `main()` so the first build already has real data.
  static Future<void> restore() async {
    if (_cache != null) return;

    final raw = await StorageService.readJson(_cacheKey);
    if (raw is List && raw.isNotEmpty) {
      _cache = raw.whereType<Map>().map(ApiResponse.asMap).toList();
    }
  }

  /// GET /expert/service-categories -> data.categories
  ///
  /// Fire-and-forget: a failure leaves whatever is cached (or the
  /// fallback) in place. This endpoint may not exist on older backend
  /// builds, and a 404 here must not break the material screens.
  static Future<void> refresh() async {
    try {
      final response = await ApiClient.get(ApiEndpoints.serviceCategories);

      final rows = ApiResponse.asMapList(
        ApiResponse.data(response)['categories'],
      );

      if (rows.isEmpty) return;

      final mapped = rows
          .map((row) => <String, dynamic>{
                'id': ApiResponse.asInt(row['id']),
                // The table carries both languages; prefer English and
                // fall back to Arabic so a category never renders blank.
                'name': ApiResponse.asString(
                  row['name_en'],
                  fallback: ApiResponse.asString(
                    row['name_ar'],
                    fallback: 'Category',
                  ),
                ),
              })
          .toList();

      _cache = mapped;
      await StorageService.saveJson(_cacheKey, mapped);
    } catch (_) {
      // Keep the previous list.
    }
  }

  /// Display name for an id, for screens that only stored the id.
  static String nameFor(Object? id) {
    final key = id?.toString();
    if (key == null || key.isEmpty) return '';

    for (final category in all) {
      if (category['id'].toString() == key) {
        return category['name'].toString();
      }
    }

    return '';
  }
}
