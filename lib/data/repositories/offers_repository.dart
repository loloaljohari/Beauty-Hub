import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_response.dart';
import '../models/offer_models.dart';

/// Service discounts the expert is running - `GET /expert/offers`.
///
/// Row shape (`offers` joined to `services`):
///   {id, service_id, service_name, title, discount_percent,
///    original_price, discounted_price, start_at, end_at, is_active}
///
/// IMPORTANT - what this screen's four tabs can and cannot show:
///   * "Service Discounts" -> real, backed by `offers` (below).
///   * "Products Offers"   -> no endpoint. `offers.service_id` is a
///     foreign key to `services`; the backend has no product-offer
///     concept for an expert.
///   * "Packages"          -> no endpoint and no table.
///   * "Rewards"           -> the closest real data is
///     `GET /expert/loyalty/birthdays`, which is birthday followers,
///     not a points leaderboard. Exposed here as [getBirthdayFollowers]
///     so the tab shows something true rather than invented ranks.
class OffersRepository {
  const OffersRepository();

  /// [activeOnly] maps to the backend's `?active=1`, which also filters
  /// out offers whose `end_at` has passed.
  Future<List<DiscountModel>> getDiscounts({bool? activeOnly}) async {
    final response = await ApiClient.get(
      ApiEndpoints.offers,
      query: {if (activeOnly != null) 'active': activeOnly ? 1 : 0},
    );

    return ApiResponse.asMapList(ApiResponse.data(response)['offers'])
        .map(_toDiscount)
        .toList();
  }

  /// POST /expert/offers
  ///
  /// The server computes `discounted_price` itself from the service's
  /// current price, so only the percentage is sent. It also rejects a
  /// second active offer on the same service (`OFFER_ALREADY_ACTIVE`),
  /// which surfaces as a 422 with a readable message.
  Future<void> createDiscount({
    required int serviceId,
    required String title,
    required double discountPercent,
    required String startAt,
    required String endAt,
  }) async {
    await ApiClient.post(
      ApiEndpoints.offers,
      body: {
        'service_id': serviceId,
        'title': title,
        'discount_percent': discountPercent,
        'start_at': startAt,
        'end_at': endAt,
      },
    );
  }

  /// POST /expert/offers/{id}/end - the only way to stop an offer;
  /// there is no DELETE for offers.
  Future<void> endOffer(Object offerId) async {
    await ApiClient.post(ApiEndpoints.endOffer(offerId));
  }

  /// GET /expert/loyalty/birthdays - followers whose birthday is today.
  Future<List<BirthdayFollower>> getBirthdayFollowers() async {
    final response = await ApiClient.get(ApiEndpoints.birthdayFollowers);

    return ApiResponse.asMapList(ApiResponse.data(response)['followers'])
        .map((row) => BirthdayFollower(
              id: ApiResponse.asString(row['id']),
              name: ApiResponse.asString(row['full_name']),
              loyaltyPoints: ApiResponse.asInt(row['loyalty_points']),
              alreadyGifted:
                  ApiResponse.asBool(row['already_gifted_this_year']),
            ))
        .toList();
  }

  /// POST /expert/loyalty/{user}/birthday-gift - grants 20 points.
  Future<void> grantBirthdayGift(Object userId) async {
    await ApiClient.post(ApiEndpoints.birthdayGift(userId));
  }

  DiscountModel _toDiscount(Map<String, dynamic> row) {
    return DiscountModel(
      id: ApiResponse.asString(row['id']),
      serviceName: ApiResponse.asString(
        row['service_name'],
        fallback: ApiResponse.asString(row['title']),
      ),
      basicPrice: ApiResponse.asDouble(row['original_price']),
      discountPercentage: ApiResponse.asDouble(row['discount_percent']),
      startDate: ApiResponse.asDate(row['start_at']),
      endDate: ApiResponse.asDate(row['end_at']),
      isActive: ApiResponse.asBool(row['is_active'], fallback: true),
    );
  }
}

/// A follower celebrating a birthday today, from the loyalty endpoint.
class BirthdayFollower {
  const BirthdayFollower({
    required this.id,
    required this.name,
    this.loyaltyPoints = 0,
    this.alreadyGifted = false,
  });

  final String id;
  final String name;
  final int loyaltyPoints;
  final bool alreadyGifted;
}
