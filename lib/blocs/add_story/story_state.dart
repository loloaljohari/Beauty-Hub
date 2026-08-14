enum StoryStatus {
  initial,
  loading,
  success,
  failure,
}

class StoryState {
  final List<String> images;
  final StoryStatus status;
  final String? errorMessage;

  const StoryState({
    this.images = const [],
    this.status = StoryStatus.initial,
    this.errorMessage,
  });

  StoryState copyWith({
    List<String>? images,
    StoryStatus? status,
    String? errorMessage,
  }) {
    return StoryState(
      images: images ?? this.images,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}