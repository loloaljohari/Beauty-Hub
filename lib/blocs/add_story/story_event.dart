abstract class StoryEvent {}

class AddImagesEvent extends StoryEvent {
  final List<String> images;

  AddImagesEvent(this.images);
}

class RemoveImageEvent extends StoryEvent  {
  final int index;

  RemoveImageEvent(this.index);
}

class PostSubmitted extends StoryEvent {
  final String caption;
  final List<String> images;

  PostSubmitted({
    required this.caption,
    required this.images,
  });
}

