import '../../core/config/app_config.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_response.dart';

/// Followers and blocked users - `GET /expert/followers`,
/// `GET /expert/blocked-users`.
///
/// These endpoints had no repository at all before, so nothing in the
/// app could reach them. The follower count shown on the profile came
/// from the `followers_count` column; this exposes the actual people
/// behind that number, plus the block/unblock actions.
///
/// Worth knowing: blocking is symmetric in the chat layer. Blocking a
/// user also deletes their follow (and decrements `followers_count`),
/// and closes any conversation between the two in either direction.
class CommunityRepository {
  const CommunityRepository();

  /// GET /expert/followers?q= -> data.followers
  Future<List<CommunityUser>> getFollowers({String? query}) async {
    final response = await ApiClient.get(
      ApiEndpoints.followers,
      query: {if (query != null && query.isNotEmpty) 'q': query},
    );

    return ApiResponse.asMapList(ApiResponse.data(response)['followers'])
        .map((row) => CommunityUser(
              id: ApiResponse.asString(row['id']),
              name: ApiResponse.asString(row['full_name']),
              phone: ApiResponse.asString(row['phone']),
              photoUrl: AppConfig.mediaUrl(
                ApiResponse.asStringOrNull(row['profile_photo']),
              ),
              since: ApiResponse.asDate(row['followed_at']),
            ))
        .toList();
  }

  /// DELETE /expert/followers/{userId} - removes the follow.
  Future<void> removeFollower(Object userId) async {
    await ApiClient.delete(ApiEndpoints.removeFollower(userId));
  }

  /// GET /expert/blocked-users -> data.blocked
  Future<List<CommunityUser>> getBlockedUsers() async {
    final response = await ApiClient.get(ApiEndpoints.blockedUsers);

    return ApiResponse.asMapList(ApiResponse.data(response)['blocked'])
        .map((row) => CommunityUser(
              id: ApiResponse.asString(row['id']),
              name: ApiResponse.asString(row['full_name']),
              photoUrl: AppConfig.mediaUrl(
                ApiResponse.asStringOrNull(row['profile_photo']),
              ),
              since: ApiResponse.asDate(row['blocked_at']),
            ))
        .toList();
  }

  /// POST /expert/blocked-users/{userId}
  ///
  /// Returns 422 with `ALREADY_BLOCKED` if the user is already blocked,
  /// which surfaces as a readable [ApiException] message.
  Future<void> blockUser(Object userId) async {
    await ApiClient.post(ApiEndpoints.blockUser(userId));
  }

  /// DELETE /expert/blocked-users/{userId}
  Future<void> unblockUser(Object userId) async {
    await ApiClient.delete(ApiEndpoints.blockUser(userId));
  }
}

/// A customer in the expert's orbit - a follower or a blocked user.
class CommunityUser {
  const CommunityUser({
    required this.id,
    required this.name,
    this.phone = '',
    this.photoUrl,
    this.since = '',
  });

  final String id;
  final String name;
  final String phone;
  final String? photoUrl;

  /// When they followed, or when they were blocked.
  final String since;
}
