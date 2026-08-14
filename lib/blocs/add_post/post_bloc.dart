import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/api_client.dart';
import '../../data/repositories/addPostRepository.dart';
import 'post_event.dart';
import 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final AddPostRepository repository;

  PostBloc(this.repository) : super(const PostState()) {
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
   on<EditPostEvent>((event, emit) async {
      emit(state.copyWith(status: PostStatus.loading));

      try {
        await repository.editPost(
          caption: event.caption,
          images: event.images,
          id: event.id,
        );

        emit(state.copyWith(
          status: PostStatus.success,
        ));
      } on ApiException catch (e) {
        // The raw exception text ("ApiException(422): ...") was being
        // shown to the user; only the server's message should be.
        emit(state.copyWith(
          status: PostStatus.failure,
          errorMessage: e.message,
        ));
      } catch (_) {
        emit(state.copyWith(
          status: PostStatus.failure,
          errorMessage: 'Could not save your post. Please try again.',
        ));
      }
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
    Emitter<PostState> emit,
  ) async {
    emit(state.copyWith(status: PostStatus.loading));

    try {
      await repository.createPost(
        caption: event.caption,
        images: event.images,
      );

      emit(state.copyWith(
        status: PostStatus.success,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: PostStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: PostStatus.failure,
        errorMessage: 'Could not publish your post. Please try again.',
      ));
    }
  }
}
