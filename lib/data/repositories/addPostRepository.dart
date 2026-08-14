import '../../core/config/app_config.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_response.dart';
import '../models/post_model.dart';

/// Creating and editing the expert's own posts.
///
/// Validation, from `CreatePostRequest` / `UpdatePostRequest`:
///   caption -> nullable, max 2200 characters
///   media   -> nullable array, MAX 10 files
///   media.* -> jpg, jpeg, png, mp4, mov, max 10 MB each
///
/// The `media[]` field name (with brackets) is correct and deliberate:
/// Laravel only reads repeated multipart parts as an array when the key
/// carries them.
class AddPostRepository {
  const AddPostRepository();

  /// Matches `media.*` in the FormRequest.
  static const List<String> allowedExtensions = [
    'jpg',
    'jpeg',
    'png',
    'mp4',
    'mov',
  ];

  static const int maxMediaCount = 10;
  static const int maxCaptionLength = 2200;

  /// POST /expert/createPost
  Future<void> createPost({
    required String caption,
    required List<String> images,
  }) async {
    _validate(caption: caption, images: images);

    await ApiClient.postMultipart(
      ApiEndpoints.createPost,
      fields: {'caption': caption},
      fileField: 'media[]',
      filePaths: images,
    );
  }

  /// POST /expert/updatePost/{id}
  ///
  /// Media replacement is all-or-nothing server-side: sending any files
  /// deletes the existing ones and stores the new set; sending none
  /// keeps what is already there. There is no way to remove a single
  /// image, so the edit screen must send the complete final set.
  Future<void> editPost({
    required String caption,
    required List<String> images,
    required String id,
  }) async {
    _validate(caption: caption, images: images);

    await ApiClient.postMultipart(
      ApiEndpoints.updatePost(id),
      fields: {'caption': caption},
      fileField: 'media[]',
      filePaths: images,
    );
  }

  /// GET /expert/getPostDetails/{id}
  ///
  /// Was never called from anywhere - the edit screen re-used whatever
  /// the list had in memory, so it could show stale media.
  Future<PostModel> getPostDetails(Object id) async {
    final response = await ApiClient.get(ApiEndpoints.postDetails(id));
    final data = ApiResponse.data(response);

    // `getPostDetails` returns the model straight in `data`, not nested.
    final post = data['post'] is Map ? ApiResponse.asMap(data['post']) : data;

    return PostModel(
      id: ApiResponse.asString(post['id']),
      caption: ApiResponse.asString(post['caption']),
      imageUrls: AppConfig.mediaUrls(post['media_json']),
      likesCount: ApiResponse.asInt(post['likes_count']),
    );
  }

  /// DELETE /expert/deletePost/{id}
  Future<void> deletePost(Object id) async {
    await ApiClient.delete(ApiEndpoints.deletePost(id));
  }

  /// Fails fast on the two limits the server enforces, so the user gets
  /// a clear message instead of a 422 after a long upload.
  void _validate({required String caption, required List<String> images}) {
    if (images.length > maxMediaCount) {
      throw const ApiException(
        message: 'A post can include up to 10 photos or videos.',
        statusCode: 0,
      );
    }

    if (caption.length > maxCaptionLength) {
      throw const ApiException(
        message: 'The caption is too long (2200 characters maximum).',
        statusCode: 0,
      );
    }

    if (caption.trim().isEmpty && images.isEmpty) {
      throw const ApiException(
        message: 'Add a caption or at least one photo.',
        statusCode: 0,
      );
    }
  }
}
