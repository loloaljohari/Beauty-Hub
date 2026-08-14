import '../../core/config/app_config.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_response.dart';
import '../models/post_model.dart';
import '../models/review_model.dart';
import '../models/salon_model.dart';
import '../models/training_models.dart';
import '../models/service_model.dart';

/// Browsing and following other providers, plus the social feed that
/// follow produces.
///
/// Backs four screens that previously had no reachable data at all:
/// Salons & Centers, the salon detail page, other people's stories, and
/// the Home feed (which could only ever show the expert's own posts).
///
/// Needs the `follows.follower_type` column from the polymorphic
/// migration - before it, `follows.follower_id` was a foreign key to
/// `users` and an expert could not follow anything.
class DiscoveryRepository {
  const DiscoveryRepository();

  /// The backend's provider type strings.
  static String typeOf(SalonType type) =>
      type == SalonType.salon ? 'salon' : 'beauty_center';

  // ── providers ───────────────────────────────────────────────────

  /// GET /expert/discover/providers?type= -> data.providers
  ///
  /// Only accounts with `account_status = active` come back; a pending
  /// salon is not something anyone should find or follow.
  Future<List<SalonModel>> getProviders({
    required SalonType type,
    String? query,
    String? city,
    String? governorate,
  }) async {
    final response = await ApiClient.get(
      ApiEndpoints.discoverProviders,
      query: {
        'type': typeOf(type),
        if (query != null && query.isNotEmpty) 'q': query,
        if (city != null && city.isNotEmpty) 'city': city,
        if (governorate != null && governorate.isNotEmpty)
          'governorate': governorate,
      },
    );

    return ApiResponse.asMapList(ApiResponse.data(response)['providers'])
        .map((row) => _toSalon(row, type))
        .toList();
  }

  /// GET /expert/discover/providers/{type}/{id} -> data.provider
  ///
  /// One round trip returns the profile, its services, its posts and
  /// its reviews, which is everything the detail screen renders.
  Future<ProviderDetail> getProvider({
    required SalonType type,
    required Object id,
  }) async {
    final response = await ApiClient.get(
      ApiEndpoints.discoverProvider(typeOf(type), id),
    );

    final row = ApiResponse.object(response, 'provider');

    // The detail screen reads `salon.services` (names) and
    // `salon.employees`; the priced list below is a separate field.
    final salon = _toSalon(row, type).copyWith(
      services: (row['service_names'] is List)
          ? (row['service_names'] as List).map((e) => e.toString()).toList()
          : ApiResponse.asMapList(row['services'])
              .map((service) => ApiResponse.asString(service['name']))
              .toList(),
      employees: ApiResponse.asMapList(row['employees'])
          .map((employee) => EmployeeModel(
            image: ApiResponse.asString(employee['profile_photo']),
                id: ApiResponse.asString(employee['id']),
                name: ApiResponse.asString(employee['name']),
                specialty: ApiResponse.asString(employee['specialization']),
              ))
          .toList(),
    );

    return ProviderDetail(
      salon: salon,
      services: ApiResponse.asMapList(row['services'])
          .map((service) => ServiceModel(
                id: ApiResponse.asString(service['id']),
                name: ApiResponse.asString(service['name']),
                description: ApiResponse.asString(service['description']),
                price: ApiResponse.asDouble(service['price']),
                durationMinutes:
                    ApiResponse.asInt(service['duration_minutes']),
              ))
          .toList(),
      posts: ApiResponse.asMapList(row['posts'])
          .map((post) => PostModel(
                id: ApiResponse.asString(post['id']),
                caption: ApiResponse.asString(post['caption']),
                imageUrls: _urls(post['media']),
                likesCount: ApiResponse.asInt(post['likes_count']),
                authorName: ApiResponse.asString(row['name']),
              ))
          .toList(),
      reviews: ApiResponse.asMapList(row['reviews'])
          .map((review) => ReviewModel(
            image:ApiResponse.asString(review['customer_photo']) ,
                id: ApiResponse.asString(review['id']),
                customerName: ApiResponse.asString(review['customer_name']),
                date: ApiResponse.asDate(review['created_at']),
                comment: ApiResponse.asString(review['comment']),
                rating: ApiResponse.asInt(review['rating']),
              ))
          .toList(),
    );
  }

  /// Same toggle, addressed by the raw provider type string. A feed
  /// post carries `provider_type` as text, not as a [SalonType].
  Future<bool> toggleFollowByType({
    required String providerType,
    required Object id,
  }) async {
    final response = await ApiClient.post(
      ApiEndpoints.followProvider(providerType, id),
    );

    return ApiResponse.asBool(ApiResponse.data(response)['followed']);
  }

  /// POST /expert/discover/providers/{type}/{id}/follow
  ///
  /// A toggle: the response says whether the expert now follows the
  /// provider, so the button state comes from the server rather than a
  /// local guess that can drift.
  Future<bool> toggleFollow({
    required SalonType type,
    required Object id,
  }) async {
    final response = await ApiClient.post(
      ApiEndpoints.followProvider(typeOf(type), id),
    );

    return ApiResponse.asBool(ApiResponse.data(response)['followed']);
  }

  // ── feed ────────────────────────────────────────────────────────

  /// GET /expert/discover/feed -> data.posts
  ///
  /// Posts from providers the expert follows. When they follow nobody
  /// the server falls back to recent posts, so a new account does not
  /// open onto a blank Home screen.
  Future<List<FeedPost>> getFeed({int limit = 30}) async {
    final response = await ApiClient.get(
      ApiEndpoints.discoverFeed,
      query: {'limit': limit},
    );

    return ApiResponse.asMapList(ApiResponse.data(response)['posts'])
        .map((row) {
      final author = ApiResponse.asMap(row['author']);

      return FeedPost(
        post: PostModel(
          id: ApiResponse.asString(row['id']),
          caption: ApiResponse.asString(row['caption']),
          // Absolute URLs from the API - this is what makes real post
          // images finally render on Home.
          imageUrls: _urls(row['media']),
          likesCount: ApiResponse.asInt(row['likes_count']),
          authorName: ApiResponse.asString(author['name']),
          salonName: ApiResponse.asString(author['subtitle']),
          authorAvatarUrl: AppConfig.mediaUrl(
            ApiResponse.asStringOrNull(author['profile_photo']),
          ),
          isFollowing: ApiResponse.asBool(row['is_following']),
          providerType: ApiResponse.asString(row['provider_type']),
          providerId: ApiResponse.asString(row['provider_id']),
        ),
        providerType: ApiResponse.asString(row['provider_type']),
        providerId: ApiResponse.asString(row['provider_id']),
      );
    }).toList();
  }

  /// GET /expert/discover/courses -> data.courses
  ///
  /// Courses published by other providers. Browsing only: enrolling is
  /// a customer action and has no expert-side route.
  Future<List<AvailableCourseModel>> getAvailableCourses({
    String? query,
  }) async {
    final response = await ApiClient.get(
      ApiEndpoints.discoverCourses,
      query: {if (query != null && query.isNotEmpty) 'q': query},
    );

    return ApiResponse.asMapList(ApiResponse.data(response)['courses'])
        .map(_toCourse)
        .toList();
  }

  AvailableCourseModel _toCourse(Map<String, dynamic> row) {
    return AvailableCourseModel(
      id: ApiResponse.asString(row['id']),
      title: ApiResponse.asString(row['title']),
      providerName: ApiResponse.asString(row['provider_name']),
      studentsCount: ApiResponse.asInt(row['current_enrollments']),
      // There is no lessons table; duration in hours is the real
      // equivalent the backend holds.
      lessonsCount: ApiResponse.asDouble(row['duration_hours']).round(),
      startDate: ApiResponse.asDate(row['start_date']),
      price: ApiResponse.asDouble(row['price']),
      imageUrl: ApiResponse.asStringOrNull(row['cover_image']),
    );
  }

  /// GET /expert/discover/following -> data.following
  Future<List<FollowedProvider>> getFollowing() async {
    final response = await ApiClient.get(ApiEndpoints.discoverFollowing);

    return ApiResponse.asMapList(ApiResponse.data(response)['following'])
        .map((row) => FollowedProvider(
              id: ApiResponse.asString(row['id']),
              type: ApiResponse.asString(row['type']),
              name: ApiResponse.asString(row['name']),
              photoUrl: AppConfig.mediaUrl(
                ApiResponse.asStringOrNull(row['profile_photo']),
              ),
            ))
        .toList();
  }

  /// Same catalogue, plus which of them the expert is already in.
  Future<CourseCatalogue> getAvailableCoursesWithEnrolment({
    String? query,
  }) async {
    final response = await ApiClient.get(
      ApiEndpoints.discoverCourses,
      query: {if (query != null && query.isNotEmpty) 'q': query},
    );

    final rows = ApiResponse.asMapList(ApiResponse.data(response)['courses']);

    return CourseCatalogue(
      courses: rows.map(_toCourse).toList(),
      enrolledIds: rows
          .where((row) => ApiResponse.asBool(row['is_enrolled']))
          .map((row) => ApiResponse.asString(row['id']))
          .toList(),
    );
  }

  /// POST /expert/discover/courses/{id}/enroll
  Future<void> enrollInCourse(Object courseId) async {
    await ApiClient.post(ApiEndpoints.enrollCourse(courseId));
  }

  /// DELETE /expert/discover/courses/{id}/enroll
  Future<void> unenrollFromCourse(Object courseId) async {
    await ApiClient.delete(ApiEndpoints.enrollCourse(courseId));
  }

  /// How many providers this expert follows, for the profile header.
  Future<int> getFollowingCount() async {
    return (await getFollowing()).length;
  }

  // ── stories ─────────────────────────────────────────────────────

  /// GET /expert/discover/stories -> data.stories
  ///
  /// Live stories from followed providers, already grouped by author.
  /// Expired and inactive rows are filtered server-side: a story lives
  /// 24 hours and showing a dead one is worse than showing none.
  Future<List<StoryGroup>> getStories() async {
    final response = await ApiClient.get(ApiEndpoints.discoverStories);

    return ApiResponse.asMapList(ApiResponse.data(response)['stories'])
        .map((row) => StoryGroup(
              providerType: ApiResponse.asString(row['provider_type']),
              providerId: ApiResponse.asString(row['provider_id']),
              name: ApiResponse.asString(row['name']),
              avatarUrl: AppConfig.mediaUrl(
                ApiResponse.asStringOrNull(row['profile_photo']),
              ),
              items: ApiResponse.asMapList(row['items'])
                  .map((item) => StoryItemData(
                        id: ApiResponse.asString(item['id']),
                        mediaType:
                            ApiResponse.asString(item['media_type'],
                                fallback: 'text'),
                        mediaUrl: AppConfig.mediaUrl(
                          ApiResponse.asStringOrNull(item['media_url']),
                        ),
                        caption: ApiResponse.asString(item['caption']),
                        createdAt: ApiResponse.asString(item['created_at']),
                      ))
                  .toList(),
            ))
        .toList();
  }

  /// POST /expert/discover/stories/{id}/view
  ///
  /// Fire-and-forget from the caller's point of view: a failed view
  /// count is not worth interrupting playback for.
  Future<void> markStoryViewed(Object storyId) async {
    await ApiClient.post(ApiEndpoints.viewDiscoverStory(storyId));
  }

  // ── mapping ─────────────────────────────────────────────────────

  SalonModel _toSalon(Map<String, dynamic> row, SalonType type) {
    final phone = ApiResponse.asStringOrNull(row['phone']);

    return SalonModel(
      id: ApiResponse.asString(row['id']),
      name: ApiResponse.asString(row['name']),
      type: type,
      city: ApiResponse.asString(row['city']),
      // The list card shows this under the name; `gender_served` is the
      // closest real column to the mock's "women salon".
      subtitle: _genderLabel(ApiResponse.asString(row['gender_served'])),
      rating: ApiResponse.asDouble(row['rating_avg']),
      reviewsCount: ApiResponse.asInt(row['followers_count']),
      description: ApiResponse.asString(row['description']),
      phoneNumbers: phone == null ? const [] : [phone],
      address: ApiResponse.asString(row['address_detail']),
      isFollowing: ApiResponse.asBool(row['is_following']),
      imageUrl: AppConfig.mediaUrl(
        ApiResponse.asStringOrNull(row['profile_photo']),
      ),
      coverUrl: AppConfig.mediaUrl(
        ApiResponse.asStringOrNull(row['cover_photo']),
      ),
    );
  }

  String _genderLabel(String raw) {
    switch (raw) {
      case 'female':
        return 'women salon';
      case 'male':
        return 'men salon';
      case 'both':
        return 'women & men';
      default:
        return '';
    }
  }

  List<String> _urls(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .map((e) => AppConfig.mediaUrl(e?.toString()))
        .whereType<String>()
        .toList();
  }
}

/// A provider's full profile plus the three tabs of its detail screen.
class ProviderDetail {
  const ProviderDetail({
    required this.salon,
    this.services = const [],
    this.posts = const [],
    this.reviews = const [],
  });

  final SalonModel salon;
  final List<ServiceModel> services;
  final List<PostModel> posts;
  final List<ReviewModel> reviews;
}

/// A feed post plus who published it, so tapping through can open that
/// provider's page.
class FeedPost {
  const FeedPost({
    required this.post,
    this.providerType = '',
    this.providerId = '',
  });

  final PostModel post;
  final String providerType;
  final String providerId;
}

/// One provider's live stories.
class StoryGroup {
  const StoryGroup({
    required this.providerType,
    required this.providerId,
    required this.name,
    this.avatarUrl,
    this.items = const [],
  });

  final String providerType;
  final String providerId;
  final String name;
  final String? avatarUrl;
  final List<StoryItemData> items;
}

class StoryItemData {
  const StoryItemData({
    required this.id,
    this.mediaType = 'text',
    this.mediaUrl,
    this.caption = '',
    this.createdAt = '',
  });

  final String id;

  /// `image` | `video` | `text`.
  final String mediaType;
  final String? mediaUrl;
  final String caption;
  final String createdAt;
}

/// A provider this expert follows.
class FollowedProvider {
  const FollowedProvider({
    required this.id,
    required this.type,
    required this.name,
    this.photoUrl,
  });

  final String id;
  final String type;
  final String name;
  final String? photoUrl;
}

/// The available-courses list plus the ids the expert is enrolled in.
class CourseCatalogue {
  const CourseCatalogue({
    this.courses = const [],
    this.enrolledIds = const [],
  });

  final List<AvailableCourseModel> courses;
  final List<String> enrolledIds;
}