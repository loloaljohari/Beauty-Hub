enum PostStatus {
  initial,
  loading,
  success,
  failure,
}

class PostState {
  final List<String> images;
  final PostStatus status;
  final String? errorMessage;

  const PostState({
    this.images = const [],
    this.status = PostStatus.initial,
    this.errorMessage,
  });

  PostState copyWith({
    List<String>? images,
    PostStatus? status,
    String? errorMessage,
  }) {
    return PostState(
      images: images ?? this.images,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}