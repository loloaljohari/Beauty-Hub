import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/api_client.dart';
import '../../data/repositories/AddStoryRepository.dart';
import 'story_event.dart';
import 'story_state.dart';

class StoryBloc extends Bloc<StoryEvent, StoryState> {
  final AddStoryRepository repository;

  StoryBloc(this.repository) : super(const StoryState()) {
    on<PostSubmitted>(_onPostSubmitted);
    on<AddImagesEvent>((event, emit) {
      emit(
        state.copyWith(
          images: [
            ...state.images,
            ...event.images,
          ],
        ),
      );
    });
  
    on<RemoveImageEvent>((event, emit) {
      final updatedImages = List<String>.from(state.images);

      updatedImages.removeAt(event.index);

      emit(
        state.copyWith(
          images: updatedImages,
        ),
      );
    });
  }

  Future<void> _onPostSubmitted(
    PostSubmitted event,
    Emitter<StoryState> emit,
  ) async {
    emit(state.copyWith(status: StoryStatus.loading));

    try {
      await repository.createStory(
        caption: event.caption,
        images: event.images,
      );

      emit(state.copyWith(
        status: StoryStatus.success,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: StoryStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: StoryStatus.failure,
        errorMessage: 'Could not publish your story. Please try again.',
      ));
    }
  }
}
