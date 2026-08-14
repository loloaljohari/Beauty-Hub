import '../../core/config/app_config.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_response.dart';
import '../../core/storage/storage_service.dart';
import '../models/highlight_card_model.dart';
import 'discovery_repository.dart';
import '../models/post_model.dart';

/// The Home feed.
///
/// Now backed by `GET /expert/discover/feed`: posts from the providers
/// this expert follows, with real media URLs and a real author avatar.
/// Before that endpoint existed the screen could only show the expert's
/// own posts, because no expert-side feed route was registered.
///
/// `getMyPosts` is kept as a fallback for older backends that do not
/// have the discovery routes yet - without it the whole screen would go
/// empty against an un-migrated server.
class HomeRepository {
  const HomeRepository();

  /// GET /expert/discover/feed, falling back to the expert's own posts.
  Future<List<PostModel>> getFeedPosts() async {
    try {
      final feed = await const DiscoveryRepository().getFeed();
      if (feed.isNotEmpty) {
        return feed.map((entry) => entry.post).toList();
      }
    } on ApiException catch (e) {
      // 404 means the discovery routes are not deployed yet; anything
      // else is a real failure and should surface to the caller.
      if (!e.isNotFound) rethrow;
    }

    return getMyPosts();
  }

  /// GET /expert/getMyPosts - paginated, rows under `data.data`.
  Future<List<PostModel>> getMyPosts() async {
    final response = await ApiClient.get(ApiEndpoints.myPosts);
    final summary = await StorageService.getUserSummary();

    return ApiResponse.paginated(response)
        .map((raw) => _toPost(ApiResponse.asMap(raw), summary))
        .toList();
  }

  /// The three cards across the top of Home.
  ///
  /// Their counts are derived from endpoints that genuinely exist:
  /// upcoming bookings, pending employment requests, and the expert's
  /// active courses. Each is fetched defensively so one failing call
  /// cannot blank out the whole header.
  Future<List<HighlightCardModel>> getHighlightCards() async {
    var courses = 0;
    var bookings = 0;
    var jobRequests = 0;

    try {
      final response = await ApiClient.get(ApiEndpoints.courses);
      courses =
          ApiResponse.asMapList(ApiResponse.data(response)['courses']).length;
    } catch (_) {}

    try {
      final response = await ApiClient.get(ApiEndpoints.bookings);
      bookings =
          ApiResponse.asMapList(ApiResponse.data(response)['bookings']).length;
    } catch (_) {}

    try {
      final response = await ApiClient.get(
        ApiEndpoints.employmentRequests,
        query: {'status': 'pending'},
      );
      jobRequests =
          ApiResponse.asMapList(ApiResponse.data(response)['requests']).length;
    } catch (_) {}

    return [
      HighlightCardModel(
        id: 'h1',
        type: HighlightCardType.newCourse,
        title: 'My Courses',
        count: courses,
      ),
      HighlightCardModel(
        id: 'h2',
        type: HighlightCardType.nearestAppointment,
        title: 'Upcoming Bookings',
        count: bookings,
      ),
      HighlightCardModel(
        id: 'h3',
        type: HighlightCardType.jobApplication,
        title: 'Job Requests',
        count: jobRequests,
      ),
    ];
  }

  /// The dismissible cards under the header.
  ///
  /// There is no `GET /expert/notifications` endpoint - the backend
  /// writes rows to a `notifications` table but only exposes them to
  /// customers. The nearest real, actionable equivalent for an expert
  /// is their pending employment requests, so those drive this list
  /// instead of three hardcoded cards.
  Future<List<HomeNotificationModel>> getNotifications() async {
    try {
      final response = await ApiClient.get(
        ApiEndpoints.employmentRequests,
        query: {'status': 'pending'},
      );

      return ApiResponse.asMapList(ApiResponse.data(response)['requests'])
          .map((row) {
        final requester = ApiResponse.asMap(row['requester']);

        return HomeNotificationModel(
          id: ApiResponse.asString(row['id']),
          nameUser: ApiResponse.asString(requester['name']),
          message: ApiResponse.asString(
            row['message'],
            fallback: 'You have a new employment offer.',
          ),
          timestamp: ApiResponse.asDate(row['created_at']),
          acceptLabel: 'approve',
          title: 'Application for Employment',
          image: AppConfig.mediaUrl(
                ApiResponse.asStringOrNull(requester['profile_photo']),
              ) ??
              'assets/images/imagesalon.png',
        );
      }).toList();
    } catch (_) {
      return const [];
    }
  }

  /// DELETE /expert/deletePost/{id}
  Future<void> deletePost(Object id) async {
    await ApiClient.delete(ApiEndpoints.deletePost(id));
  }

  PostModel _toPost(
    Map<String, dynamic> row,
    Map<String, String?> author,
  ) {
    return PostModel(
      id: ApiResponse.asString(row['id']),
      caption: ApiResponse.asString(row['caption']),
      // The rows carry no author block (they are all this expert's),
      // so the signed-in profile fills those fields.
      authorName: author['name'] ?? '',
      salonName: author['specialization'] ?? '',
      authorAvatarUrl: AppConfig.mediaUrl(author['photo']),
      imageUrls: AppConfig.mediaUrls(row['media_json']),
      likesCount: ApiResponse.asInt(row['likes_count']),
    );
  }
}