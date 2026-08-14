import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import '../../data/repositories/chats_repository.dart';
import 'chats_event.dart';
import 'chats_state.dart';

class ChatsBloc extends Bloc<ChatsEvent, ChatsState> {
  ChatsBloc({ChatsRepository? repository})
      : _repository = repository ?? const ChatsRepository(),
        super(const ChatsState()) {
    on<ChatsLoaded>(_onLoaded);
    on<ChatsSearchChanged>(_onSearchChanged);
    on<DeleteStory>(_ondeleteStory);
  }

  final ChatsRepository _repository;

  Future<void> _onLoaded(ChatsLoaded event, Emitter<ChatsState> emit) async {
    emit(state.copyWith(status: ChatsStatus.loading, errorMessage: ''));

    try {
      // Conversations are the point of the screen; stories are a strip
      // at the top. A failure in the stories call should not take the
      // whole screen down, so they are fetched independently.
      final chats = await _repository.getChats();
      final stories = await _repository.getStories();

      dynamic myStory;
      try {
        myStory = await _repository.getmystory(event.StoryController);
      } catch (_) {
        myStory = null;
      }

      emit(
        state.copyWith(
          chats: chats,
          stories: stories,
          mystory: myStory,
          status: ChatsStatus.loaded,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: ChatsStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: ChatsStatus.failure,
        errorMessage: 'Could not load your conversations.',
      ));
    }
  }

  void _onSearchChanged(ChatsSearchChanged event, Emitter<ChatsState> emit) {
    emit(state.copyWith(searchQuery: event.query));
  }

  Future<void> _ondeleteStory(
    DeleteStory event,
    Emitter<ChatsState> emit,
  ) async {
    emit(state.copyWith(actionStatus: ChatsActionStatus.loading));

    try {
      await _repository.deleteStory(event.id);

      emit(
        state.copyWith(
          status: ChatsStatus.loaded,
          stories: await _repository.getStories(),
          chats: await _repository.getChats(),
          mystory: await _repository.getmystory(event.storyController),
          actionStatus: ChatsActionStatus.success,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(
        actionStatus: ChatsActionStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        actionStatus: ChatsActionStatus.failure,
        errorMessage: 'Could not delete this story.',
      ));
    }
  }
}
