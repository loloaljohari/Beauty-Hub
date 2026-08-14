import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeLoaded extends HomeEvent {
  const HomeLoaded();
}

/// Fired when the user taps "Follow" on a post card.
class HomePostFollowToggled extends HomeEvent {
  const HomePostFollowToggled(this.postId);

  final String postId;

  @override
  List<Object?> get props => [postId];
}

/// Fired when the user taps the like icon on a post card.
class HomePostLikeToggled extends HomeEvent {
  const HomePostLikeToggled(this.postId);

  final String postId;

  @override
  List<Object?> get props => [postId];
}

/// Fired when the user dismisses a notification banner
/// (Cancel or accept/register/approve).
class HomeNotificationDismissed extends HomeEvent {
  const HomeNotificationDismissed(this.notificationId);

  final String notificationId;

  @override
  List<Object?> get props => [notificationId];
}
