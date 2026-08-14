import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_response.dart';
import '../models/review_model.dart';

/// Reviews the expert has received, from `GET /expert/reviews`.
///
/// The endpoint returns both a summary block and the rows:
///   data.summary  -> {average, count, unanswered}
///   data.reviews  -> [{id, rating, comment, created_at, provider_reply,
///                      is_visible, customer:{id, full_name, profile_photo}}]
///
/// The screen previously showed a hardcoded 4.8 / 250; those now come
/// from `summary`, which is why [getReviews] returns the whole bundle
/// instead of just a list.
class ReviewsRepository {
  const ReviewsRepository();

  /// [rating] filters to a single star value, [unansweredOnly] to the
  /// ones with no `provider_reply` yet - both are supported by the
  /// backend as query parameters.
  Future<ReviewsBundle> getReviews({int? rating, bool unansweredOnly = false}) async {
    final response = await ApiClient.get(
      ApiEndpoints.reviews,
      query: {
        if (rating != null) 'rating': rating,
        if (unansweredOnly) 'unanswered': 1,
      },
    );

    final payload = ApiResponse.data(response);
    final summary = ApiResponse.asMap(payload['summary']);
    final rows = ApiResponse.asMapList(payload['reviews']);

    return ReviewsBundle(
      reviews: rows.map(_toModel).toList(),
      averageRating: ApiResponse.asDouble(summary['average']),
      totalCount: ApiResponse.asInt(summary['count']),
      unansweredCount: ApiResponse.asInt(summary['unanswered']),
    );
  }

  /// POST /expert/reviews/{id}/reply
  Future<void> replyToReview({
    required Object reviewId,
    required String reply,
  }) async {
    await ApiClient.post(
      ApiEndpoints.replyToReview(reviewId),
      body: {'reply': reply},
    );
  }

  /// POST /expert/reviews/{id}/visibility
  ///
  /// The backend has no "delete review" endpoint - an expert can only
  /// hide one. The screen's Delete action maps to `hidden: true`.
  Future<void> setReviewHidden({
    required Object reviewId,
    required bool hidden,
  }) async {
    await ApiClient.post(
      ApiEndpoints.reviewVisibility(reviewId),
      body: {'hidden': hidden},
    );
  }

  ReviewModel _toModel(Map<String, dynamic> row) {
    final customer = ApiResponse.asMap(row['customer']);

    return ReviewModel(
      image:ApiResponse.asString(
      "http://127.0.0.1:8000/storage/${customer['profile_photo']}",
        // fallback: null,
      ) ,
      id: ApiResponse.asString(row['id']),
      customerName: ApiResponse.asString(
        customer['full_name'],
        fallback: 'Customer',
      ),
      date: ApiResponse.asDate(row['created_at']),
      comment: ApiResponse.asString(row['comment']),
      rating: ApiResponse.asInt(row['rating']),
      // The API has no per-review "seen" flag. The nearest real signal
      // is whether the expert has already replied, which is what the
      // screen's viewed/unviewed badge now reflects.
      isViewed: ApiResponse.asStringOrNull(row['provider_reply']) != null,
    );
  }
}

/// Rows plus the summary counters the header row displays.
class ReviewsBundle {
  const ReviewsBundle({
    this.reviews = const [],
    this.averageRating = 0,
    this.totalCount = 0,
    this.unansweredCount = 0,
  });

  final List<ReviewModel> reviews;
  final double averageRating;
  final int totalCount;
  final int unansweredCount;
}
