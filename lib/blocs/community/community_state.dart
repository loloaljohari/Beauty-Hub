import 'package:equatable/equatable.dart';
import '../../data/repositories/community_repository.dart';

enum CommunityStatus { initial, loading, loaded, failure }

enum CommunityActionStatus { idle, loading, success, failure }

class CommunityState extends Equatable {
  const CommunityState({
    this.followers = const [],
    this.blocked = const [],
    this.tabIndex = 0,
    this.searchQuery = '',
    this.status = CommunityStatus.initial,
    this.actionStatus = CommunityActionStatus.idle,
    this.errorMessage,
  });

  final List<CommunityUser> followers;
  final List<CommunityUser> blocked;

  /// 0 = Followers, 1 = Blocked.
  final int tabIndex;
  final String searchQuery;
  final CommunityStatus status;
  final CommunityActionStatus actionStatus;
  final String? errorMessage;

  bool get isFollowersEmpty =>
      status == CommunityStatus.loaded && followers.isEmpty;

  bool get isBlockedEmpty =>
      status == CommunityStatus.loaded && blocked.isEmpty;

  CommunityState copyWith({
    List<CommunityUser>? followers,
    List<CommunityUser>? blocked,
    int? tabIndex,
    String? searchQuery,
    CommunityStatus? status,
    CommunityActionStatus? actionStatus,
    String? errorMessage,
  }) {
    return CommunityState(
      followers: followers ?? this.followers,
      blocked: blocked ?? this.blocked,
      tabIndex: tabIndex ?? this.tabIndex,
      searchQuery: searchQuery ?? this.searchQuery,
      status: status ?? this.status,
      actionStatus: actionStatus ?? this.actionStatus,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        followers,
        blocked,
        tabIndex,
        searchQuery,
        status,
        actionStatus,
        errorMessage,
      ];
}
