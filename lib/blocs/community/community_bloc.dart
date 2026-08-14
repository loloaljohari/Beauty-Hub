import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import '../../data/repositories/community_repository.dart';
import 'community_event.dart';
import 'community_state.dart';

class CommunityBloc extends Bloc<CommunityEvent, CommunityState> {
  CommunityBloc({CommunityRepository? repository})
      : _repository = repository ?? const CommunityRepository(),
        super(const CommunityState()) {
    on<CommunityLoaded>(_onLoaded);
    on<CommunityTabChanged>(_onTabChanged);
    on<CommunitySearchChanged>(_onSearchChanged);
    on<FollowerRemoved>(_onFollowerRemoved);
    on<UserBlocked>(_onUserBlocked);
    on<UserUnblocked>(_onUserUnblocked);
  }

  final CommunityRepository _repository;
  Timer? _debounce;

  Future<void> _onLoaded(
    CommunityLoaded event,
    Emitter<CommunityState> emit,
  ) async {
    emit(state.copyWith(
      status: CommunityStatus.loading,
      errorMessage: null,
    ));

    try {
      final followers =
          await _repository.getFollowers(query: state.searchQuery);
      final blocked = await _repository.getBlockedUsers();

      emit(state.copyWith(
        followers: followers,
        blocked: blocked,
        status: CommunityStatus.loaded,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: CommunityStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: CommunityStatus.failure,
        errorMessage: 'Could not load your audience.',
      ));
    }
  }

  void _onTabChanged(
    CommunityTabChanged event,
    Emitter<CommunityState> emit,
  ) {
    emit(state.copyWith(tabIndex: event.tabIndex));
  }

  /// The search runs server-side, so it is debounced rather than fired
  /// on every keystroke.
  void _onSearchChanged(
    CommunitySearchChanged event,
    Emitter<CommunityState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));

    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => add(const CommunityLoaded()),
    );
  }

  Future<void> _onFollowerRemoved(
    FollowerRemoved event,
    Emitter<CommunityState> emit,
  ) async {
    await _act(
      emit,
      () => _repository.removeFollower(event.userId),
      fallback: 'Could not remove this follower.',
    );
  }

  /// Blocking also drops the follow server-side and closes any chat
  /// between the two, so both lists are refetched afterwards.
  Future<void> _onUserBlocked(
    UserBlocked event,
    Emitter<CommunityState> emit,
  ) async {
    await _act(
      emit,
      () => _repository.blockUser(event.userId),
      fallback: 'Could not block this user.',
    );
  }

  Future<void> _onUserUnblocked(
    UserUnblocked event,
    Emitter<CommunityState> emit,
  ) async {
    await _act(
      emit,
      () => _repository.unblockUser(event.userId),
      fallback: 'Could not unblock this user.',
    );
  }

  /// Every action here changes both lists at once (blocking removes a
  /// follower, unblocking may restore nothing), so they all refetch
  /// instead of patching state locally and drifting from the server.
  Future<void> _act(
    Emitter<CommunityState> emit,
    Future<void> Function() action, {
    required String fallback,
  }) async {
    emit(state.copyWith(actionStatus: CommunityActionStatus.loading));

    try {
      await action();

      emit(state.copyWith(
        followers: await _repository.getFollowers(query: state.searchQuery),
        blocked: await _repository.getBlockedUsers(),
        actionStatus: CommunityActionStatus.success,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        actionStatus: CommunityActionStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        actionStatus: CommunityActionStatus.failure,
        errorMessage: fallback,
      ));
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
