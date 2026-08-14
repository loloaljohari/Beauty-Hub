import 'package:equatable/equatable.dart';

abstract class ChatsEvent extends Equatable {
  const ChatsEvent([storyController]);

  @override
  List<Object?> get props => [];
}

class ChatsLoaded extends ChatsEvent {
  final StoryController;
  const ChatsLoaded(this.StoryController);
}

class DeleteStory extends ChatsEvent {
  final String id;
  final dynamic storyController;

  const DeleteStory(
    this.id,
    this.storyController,
  );
}

class ChatsSearchChanged extends ChatsEvent {
  const ChatsSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}
