import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';

/// Creating the expert's stories.
///
/// Validation, from `CreateStoryRequest`:
///   media   -> ONE file, required_without:caption,
///              jpg/jpeg/png/mp4/mov, max 20 MB
///   caption -> required_without:media, max 500 characters
///
/// Two things this makes explicit that the previous version did not:
///
///  1. `media` is singular. Passing several paths to `fileField: 'media'`
///     produced several parts under the same key, and Laravel's `file`
///     rule then saw an array and rejected it. Only the first file is
///     sent now.
///
///  2. A caption-only story IS valid (`required_without` cuts both
///     ways) and becomes a text story with `media_type = 'text'`. The
///     old signature required an images list, so that whole story type
///     was unreachable from the app.
class AddStoryRepository {
  const AddStoryRepository();

  static const int maxCaptionLength = 500;

  /// POST /expert/createStory
  ///
  /// The backend derives `media_type` from the uploaded file's MIME
  /// type, so the app does not send it - the `media_type` field in the
  /// Postman example is ignored server-side.
  ///
  /// Stories expire after 24 hours (`expires_at = now()->addDay()`).
  Future<void> createStory({
    String caption = '',
    List<String> images = const [],
  }) async {
    final trimmed = caption.trim();

    if (trimmed.isEmpty && images.isEmpty) {
      throw const ApiException(
        message: 'Add a photo, a video, or some text to post a story.',
        statusCode: 0,
      );
    }

    if (trimmed.length > maxCaptionLength) {
      throw const ApiException(
        message: 'Story text is too long (500 characters maximum).',
        statusCode: 0,
      );
    }

    await ApiClient.postMultipart(
      ApiEndpoints.createStory,
      fields: {if (trimmed.isNotEmpty) 'caption': trimmed},
      files: {if (images.isNotEmpty) 'media': images.first},
    );
  }

  /// Kept so existing call sites keep compiling - this used to be
  /// called `createPost` on the story repository.
  Future<void> createPost({
    required String caption,
    required List<String> images,
  }) =>
      createStory(caption: caption, images: images);

  /// DELETE /expert/deleteStory/{id}
  Future<void> deleteStory(Object id) async {
    await ApiClient.delete(ApiEndpoints.deleteStory(id));
  }
}
