import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import '../../data/repositories/reviews_repository.dart';
import 'reviews_event.dart';
import 'reviews_state.dart';

class ReviewsBloc extends Bloc<ReviewsEvent, ReviewsState> {
  ReviewsBloc({ReviewsRepository? repository})
      : _repository = repository ?? const ReviewsRepository(),
        super(const ReviewsState()) {
    on<ReviewsLoaded>(_onLoaded);
    on<ReviewMarkedViewed>(_onMarkedViewed);
    on<ReviewDeleted>(_onDeleted);
    on<ReviewReplied>(_onReplied);
  }

  final ReviewsRepository _repository;

  Future<void> _onLoaded(
    ReviewsLoaded event,
    Emitter<ReviewsState> emit,
  ) async {
    emit(state.copyWith(status: ReviewsStatus.loading, errorMessage: null));

    try {
      final bundle = await _repository.getReviews(
        rating: event.rating,
        unansweredOnly: event.unansweredOnly,
      );

      emit(
        state.copyWith(
          reviews: bundle.reviews,
          averageRating: bundle.averageRating,
          totalReviewsCount: bundle.totalCount,
          unansweredCount: bundle.unansweredCount,
          status: ReviewsStatus.loaded,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: ReviewsStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: ReviewsStatus.failure,
        errorMessage: 'Could not load your reviews.',
      ));
    }
  }

  /// The API has no "mark as seen" call, so this stays local to the
  /// session - it only drives the badge on the card.
  void _onMarkedViewed(ReviewMarkedViewed event, Emitter<ReviewsState> emit) {
    final updated = state.reviews.map((r) {
      if (r.id == event.reviewId) return r.copyWith(isViewed: true);
      return r;
    }).toList();
    emit(state.copyWith(reviews: updated));
  }

  /// Maps to `POST /expert/reviews/{id}/visibility` with `hidden: true`
  /// - the backend deliberately does not let a provider delete a
  /// customer's review outright, only hide it from their profile.
  Future<void> _onDeleted(
    ReviewDeleted event,
    Emitter<ReviewsState> emit,
  ) async {
    final previous = state.reviews;

    // Optimistic removal so the list does not freeze while the request
    // is in flight; restored below if the server refuses.
    emit(state.copyWith(
      reviews: previous.where((r) => r.id != event.reviewId).toList(),
      actionStatus: ReviewsActionStatus.loading,
    ));

    try {
      await _repository.setReviewHidden(
        reviewId: event.reviewId,
        hidden: true,
      );
      emit(state.copyWith(actionStatus: ReviewsActionStatus.success));
    } on ApiException catch (e) {
      emit(state.copyWith(
        reviews: previous,
        actionStatus: ReviewsActionStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        reviews: previous,
        actionStatus: ReviewsActionStatus.failure,
        errorMessage: 'Could not hide this review.',
      ));
    }
  }

  Future<void> _onReplied(
    ReviewReplied event,
    Emitter<ReviewsState> emit,
  ) async {
    emit(state.copyWith(actionStatus: ReviewsActionStatus.loading));

    try {
      await _repository.replyToReview(
        reviewId: event.reviewId,
        reply: event.reply,
      );

      final bundle = await _repository.getReviews();
      emit(state.copyWith(
        reviews: bundle.reviews,
        averageRating: bundle.averageRating,
        totalReviewsCount: bundle.totalCount,
        unansweredCount: bundle.unansweredCount,
        status: ReviewsStatus.loaded,
        actionStatus: ReviewsActionStatus.success,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        actionStatus: ReviewsActionStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        actionStatus: ReviewsActionStatus.failure,
        errorMessage: 'Could not send your reply.',
      ));
    }
  }
}
