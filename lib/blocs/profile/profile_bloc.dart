import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import '../../core/network/auth_failure.dart';
import '../../data/repositories/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({ProfileRepository? repository})
      : _repository = repository ?? const ProfileRepository(),
        super(const ProfileState()) {
    on<ProfileLoaded>(_onLoaded);
    on<ProfileTabChanged>(_onTabChanged);
    on<ProfileServiceDeleted>(_onServiceDeleted);
    on<DeletePostEvent>(_onDeletePost);
  }

  final ProfileRepository _repository;

  Future<void> _onLoaded(
      ProfileLoaded event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    emit(
      state.copyWith(
        user: await _repository.getCurrentUser(),
        posts: await _repository.getProfilePosts(),
        services: await _repository.getServices(),
        status: ProfileStatus.loaded,
      ),
    );
  }

  void _onTabChanged(ProfileTabChanged event, Emitter<ProfileState> emit) {
    emit(state.copyWith(tabIndex: event.tabIndex));
  }

  Future<void> _onDeletePost(
    DeletePostEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(
      status: ProfileStatus.loading,
    ));
    try {
      await const ProfileRepository().DeletePost(event.postId);
      print('delete successful');

      final updated = await _repository.getProfilePosts();
      emit(state.copyWith(posts: updated, status: ProfileStatus.loaded,));
      emit(state.copyWith(actionStatus: ProfileActionStatus.success));
    } on ApiException catch (e) {
      emit(state.copyWith(
        actionStatus: ProfileActionStatus.failure,
        errorMessage: AuthFailure.fromStatusCode(e.statusCode, e.message),
      ));
    } catch (e) {
      print(e.toString());
      emit(state.copyWith(
        actionStatus: ProfileActionStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onServiceDeleted(
    ProfileServiceDeleted event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(
      status: ProfileStatus.loading,
    ));
    try {
      await const ProfileRepository().DeleteService(event.serviceId);
      print('delete successful');
      final updated = await _repository.getServices();
      emit(state.copyWith(services: updated, status: ProfileStatus.loaded,));
      emit(state.copyWith(actionStatus: ProfileActionStatus.success));
    } on ApiException catch (e) {
      emit(state.copyWith(
        actionStatus: ProfileActionStatus.failure,
        errorMessage: AuthFailure.fromStatusCode(e.statusCode, e.message),
      ));
    } catch (e) {
      print(e.toString());
      emit(state.copyWith(
        actionStatus: ProfileActionStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
