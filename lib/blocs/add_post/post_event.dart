abstract class PostEvent {}

class AddImagesEvent extends PostEvent {
  final List<String> images;

  AddImagesEvent(this.images);
}

class RemoveImageEvent extends PostEvent {
  final int index;

  RemoveImageEvent(this.index);
}

class PostSubmitted extends PostEvent {
  final String caption;
  final List<String> images;

  PostSubmitted({
    required this.caption,
    required this.images,
  });
}


class EditPostEvent extends PostEvent {
  final String caption;
  final List<String> images;
  final String id;

  EditPostEvent({
    required this.caption,
    required this.images,
    required this.id,
  });
}