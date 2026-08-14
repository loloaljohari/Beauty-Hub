import 'package:equatable/equatable.dart';
import '../../data/models/post_model.dart';
import '../../data/models/review_model.dart';
import '../../data/models/salon_model.dart';
import '../../data/models/service_model.dart';

enum SalonDetailStatus { initial, loading, loaded, failure }

class SalonDetailState extends Equatable {
  const SalonDetailState({
    this.salon,
    this.services = const [],
    this.posts = const [],
    this.reviews = const [],
    this.tabIndex = 0,
    this.status = SalonDetailStatus.initial,
    this.errorMessage,
  });

  final SalonModel? salon;

  /// The provider's own services, posts and reviews - all three arrive
  /// with the profile in a single request.
  final List<ServiceModel> services;
  final List<PostModel> posts;
  final List<ReviewModel> reviews;

  /// 0 = Info, 1 = Reviews, 2 = Posts.
  final int tabIndex;
  final SalonDetailStatus status;
  final String? errorMessage;

  SalonDetailState copyWith({
    SalonModel? salon,
    List<ServiceModel>? services,
    List<PostModel>? posts,
    List<ReviewModel>? reviews,
    int? tabIndex,
    SalonDetailStatus? status,
    String? errorMessage,
  }) {
    return SalonDetailState(
      salon: salon ?? this.salon,
      services: services ?? this.services,
      posts: posts ?? this.posts,
      reviews: reviews ?? this.reviews,
      tabIndex: tabIndex ?? this.tabIndex,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [salon, services, posts, reviews, tabIndex, status, errorMessage];
}
