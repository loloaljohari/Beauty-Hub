import 'package:equatable/equatable.dart';

/// A single feed post shown on the Home screen
/// (profile pic, salon name, image carousel, like state).
class PostModel extends Equatable {
  const PostModel({
    required this.id,
     this.authorName,
     this.salonName,
    this.authorAvatarUrl,
    this.imageUrls = const [],
    this.isFollowing = false,
    this.providerType = '',
    this.providerId = '',
    this.isLiked = false,
    this.likesCount = 0,
    this.caption = '',
  });

  final String id;
  final String? authorName;
  final String? salonName;
  final String? authorAvatarUrl;

  /// Image carousel for the post (placeholders for now).
  final List<String> imageUrls;
  final bool isFollowing;

  /// Who published this post. Needed by the follow button: the endpoint
  /// is `/discover/providers/{type}/{id}/follow`, and a post id alone
  /// cannot address it.
  final String providerType;
  final String providerId;
  final bool isLiked;
  final int likesCount;
  
  final String caption;

  PostModel copyWith({
    bool? isFollowing,
    String? providerType,
    String? providerId,
    bool? isLiked,
    int? likesCount,
  }) {
    return PostModel(
      id: id,
      authorName: authorName,
      salonName: salonName,
      authorAvatarUrl: authorAvatarUrl,
      imageUrls: imageUrls,
      isFollowing: isFollowing ?? this.isFollowing,
      providerType: providerType ?? this.providerType,
      providerId: providerId ?? this.providerId,
      isLiked: isLiked ?? this.isLiked,
      likesCount: likesCount ?? this.likesCount,
      caption: caption
    );
  }

  @override
  List<Object?> get props => [
        id,
        authorName,
        salonName,
        authorAvatarUrl,
        imageUrls,
        isFollowing,
        providerType,
        providerId,
        isLiked,
        likesCount,
        caption
      ];
}