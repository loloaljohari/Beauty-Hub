import 'package:equatable/equatable.dart';

import '../../data/models/user_model.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoaded extends ProfileEvent {
  const ProfileLoaded();
}
class GetServicesEvent extends ProfileEvent {
  const GetServicesEvent();
}

/// Switches between the "Posts" and "Services" tabs.
class ProfileTabChanged extends ProfileEvent {
  const ProfileTabChanged(this.tabIndex);

  /// 0 = Posts, 1 = Services.
  final int tabIndex;

  @override
  List<Object?> get props => [tabIndex];
}
class DeletePostEvent extends ProfileEvent {
  final String postId;
   DeletePostEvent({required this. postId});
}

class ProfileServiceDeleted extends ProfileEvent {
 
  const ProfileServiceDeleted(this.serviceId);

  final String serviceId;

  @override
  List<Object?> get props => [serviceId];
}

class ProfileUserUpdated extends ProfileEvent {
  final UserModel user;

  const ProfileUserUpdated(this.user);

  @override
  List<Object?> get props => [user];
}
