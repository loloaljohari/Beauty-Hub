import 'package:beautyhup/data/models/settings_models.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/post_model.dart';
import '../../data/models/service_model.dart';
import '../../data/models/user_model.dart';

enum ProfileStatus { initial, loading, loaded }
enum ProfileActionStatus { initial, loading, success, failure }

class ProfileState extends Equatable {
  const ProfileState({
    this.user,
    this.posts = const [],
    this.services = const [],
    this.tabIndex = 0,
    this.status = ProfileStatus.initial,
    this.actionStatus = ProfileActionStatus.initial,
    this.errorMessage,

  });

  final SettingsProfileModel? user;
  final List<PostModel> posts;
  final List<ServiceModel> services;
  final int tabIndex;
  final ProfileStatus status;
  final ProfileActionStatus actionStatus;
  final String? errorMessage;
  ProfileState copyWith({
    SettingsProfileModel? user,
    List<PostModel>? posts,
    List<ServiceModel>? services,
    int? tabIndex,
    ProfileStatus? status,
    ProfileActionStatus? actionStatus,
    String? errorMessage,
  }) {
    return ProfileState(
      user: user ?? this.user,
      posts: posts ?? this.posts,
      services: services ?? this.services,
      tabIndex: tabIndex ?? this.tabIndex,
      status: status ?? this.status,
      actionStatus: actionStatus ?? this.actionStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [user, posts, services, tabIndex, status, actionStatus, errorMessage];
}
