import '../../core/config/app_config.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_response.dart';
import '../../core/storage/storage_service.dart';
import '../models/post_model.dart';
import '../models/service_model.dart';
import '../models/settings_models.dart';

/// The expert's own profile screen: identity, their posts, and the
/// services they offer.
class ProfileRepository {
  const ProfileRepository();

  /// GET /expert/auth/profile -> data.expert
  Future<SettingsProfileModel> getCurrentUser() async {
    final response = await ApiClient.get(ApiEndpoints.profile);
    final expert = ApiResponse.object(response, 'expert');

    await StorageService.saveUserSummary(
      id: ApiResponse.asInt(expert['id']),
      name: ApiResponse.asStringOrNull(expert['full_name']),
      email: ApiResponse.asStringOrNull(expert['email']),
      photo: ApiResponse.asStringOrNull(expert['profile_photo']),
      specialization: ApiResponse.asStringOrNull(expert['specialization']),
    );

    final specialization = ApiResponse.asString(expert['specialization']);

    return SettingsProfileModel(
      name: ApiResponse.asString(expert['full_name']),
      phone: ApiResponse.asString(expert['phone']),
      email: ApiResponse.asString(expert['email']),
      // The column is `birth_date`; the old code read `birthdate`, so
      // this field was always empty.
      birthdate: ApiResponse.asDate(expert['birth_date']),
      bio: ApiResponse.asString(expert['bio']),
      location: ApiResponse.asString(expert['city']),
      instagramHandle: '',
      facebookHandle: '',
      typeOfWork:
          specialization.isEmpty ? 'Expert' : 'Expert  $specialization',
      experienceYears: ApiResponse.asInt(expert['experience_years']),
      followersCount: ApiResponse.asInt(expert['followers_count']),
      // `experts` has no following_count column - the API counts the
      // polymorphic follows rows and returns it alongside the profile.
      followingCount: ApiResponse.asInt(expert['following_count']),
      avatarUrl: AppConfig.mediaUrl(
        ApiResponse.asStringOrNull(expert['profile_photo']),
      ),
    );
  }

  /// GET /expert/getMyPosts - a paginator, so the rows sit in
  /// `data.data` rather than `data`.
  Future<List<PostModel>> getProfilePosts() async {
    final response = await ApiClient.get(ApiEndpoints.myPosts);
    final summary = await StorageService.getUserSummary();

    return ApiResponse.paginated(response).map((raw) {
      final post = ApiResponse.asMap(raw);

      return PostModel(
        id: ApiResponse.asString(post['id']),
        caption: ApiResponse.asString(post['caption']),
        authorName: summary['name'] ?? '',
        salonName: summary['specialization'] ?? '',
        authorAvatarUrl: AppConfig.mediaUrl(summary['photo']),
        // Relative paths in `media_json` resolved against the public
        // storage disk, so the grid actually renders.
        imageUrls: AppConfig.mediaUrls(post['media_json']),
        likesCount: ApiResponse.asInt(post['likes_count']),
      );
    }).toList();
  }

  /// GET /expert/services -> data.services
  Future<List<ServiceModel>> getServices() async {
    final response = await ApiClient.get(ApiEndpoints.services);

    return ApiResponse.asMapList(ApiResponse.data(response)['services'])
        .map((row) => ServiceModel(
              id: ApiResponse.asString(row['id']),
              name: ApiResponse.asString(row['name']),
              description: ApiResponse.asString(row['description']),
              durationMinutes: ApiResponse.asInt(row['duration_minutes']),
              // MySQL hands DECIMAL columns back as strings, so
              // `double.parse` here crashed whenever the driver
              // returned a number instead.
              price: ApiResponse.asDouble(row['price']),
            ))
        .toList();
  }

  /// DELETE /expert/services/{id}
  Future<void> deleteService(Object id) async {
    await ApiClient.delete(ApiEndpoints.service(id));
  }

  /// DELETE /expert/deletePost/{id}
  Future<void> deletePost(Object id) async {
    await ApiClient.delete(ApiEndpoints.deletePost(id));
  }

  // Kept so the existing call sites keep compiling.
  Future<void> DeleteService(Object id) => deleteService(id);

  Future<void> DeletePost(Object id) => deletePost(id);
}
