import 'package:equatable/equatable.dart';

abstract class CommunityEvent extends Equatable {
  const CommunityEvent();

  @override
  List<Object?> get props => [];
}

class CommunityLoaded extends CommunityEvent {
  const CommunityLoaded();
}

/// 0 = Followers, 1 = Blocked.
class CommunityTabChanged extends CommunityEvent {
  const CommunityTabChanged(this.tabIndex);

  final int tabIndex;

  @override
  List<Object?> get props => [tabIndex];
}

/// Server-side search on the followers list (`?q=`).
class CommunitySearchChanged extends CommunityEvent {
  const CommunitySearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class FollowerRemoved extends CommunityEvent {
  const FollowerRemoved(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}

class UserBlocked extends CommunityEvent {
  const UserBlocked(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}

class UserUnblocked extends CommunityEvent {
  const UserUnblocked(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}
