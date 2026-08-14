import 'package:equatable/equatable.dart';

abstract class ReviewsEvent extends Equatable {
  const ReviewsEvent();

  @override
  List<Object?> get props => [];
}

/// Both filters map to query parameters the backend already supports.
class ReviewsLoaded extends ReviewsEvent {
  const ReviewsLoaded({this.rating, this.unansweredOnly = false});

  final int? rating;
  final bool unansweredOnly;

  @override
  List<Object?> get props => [rating, unansweredOnly];
}

class ReviewMarkedViewed extends ReviewsEvent {
  const ReviewMarkedViewed(this.reviewId);

  final String reviewId;

  @override
  List<Object?> get props => [reviewId];
}

/// Hides the review on the provider's profile (the backend has no
/// hard-delete for reviews).
class ReviewDeleted extends ReviewsEvent {
  const ReviewDeleted(this.reviewId);

  final String reviewId;

  @override
  List<Object?> get props => [reviewId];
}

class ReviewReplied extends ReviewsEvent {
  const ReviewReplied({required this.reviewId, required this.reply});

  final String reviewId;
  final String reply;

  @override
  List<Object?> get props => [reviewId, reply];
}
