import 'package:equatable/equatable.dart';
import '../../data/models/review_model.dart';

enum ReviewsStatus { initial, loading, loaded, failure }

enum ReviewsActionStatus { initial, loading, success, failure }

class ReviewsState extends Equatable {
  const ReviewsState({
    this.reviews = const [],
    this.averageRating = 0,
    this.totalReviewsCount = 0,
    this.unansweredCount = 0,
    this.status = ReviewsStatus.initial,
    this.actionStatus = ReviewsActionStatus.initial,
    this.errorMessage,
  });

  final List<ReviewModel> reviews;
  final double averageRating;
  final int totalReviewsCount;

  /// Reviews with no provider reply yet - drives the "needs a reply"
  /// counter and comes straight from the API's summary block.
  final int unansweredCount;

  final ReviewsStatus status;
  final ReviewsActionStatus actionStatus;
  final String? errorMessage;

  /// True only once loading finished and the API genuinely returned
  /// nothing - so the screen can tell "empty" apart from "still
  /// loading" and show the right state.
  bool get isEmpty =>
      status == ReviewsStatus.loaded && reviews.isEmpty;

  ReviewsState copyWith({
    List<ReviewModel>? reviews,
    double? averageRating,
    int? totalReviewsCount,
    int? unansweredCount,
    ReviewsStatus? status,
    ReviewsActionStatus? actionStatus,
    String? errorMessage,
  }) {
    return ReviewsState(
      reviews: reviews ?? this.reviews,
      averageRating: averageRating ?? this.averageRating,
      totalReviewsCount: totalReviewsCount ?? this.totalReviewsCount,
      unansweredCount: unansweredCount ?? this.unansweredCount,
      status: status ?? this.status,
      actionStatus: actionStatus ?? this.actionStatus,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        reviews,
        averageRating,
        totalReviewsCount,
        unansweredCount,
        status,
        actionStatus,
        errorMessage,
      ];
}
