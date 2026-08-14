import '../../core/config/app_config.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_response.dart';
import '../models/booking_detail_model.dart';
import '../models/booking_model.dart';

/// Bookings customers made with this expert.
///
/// `GET /expert/bookings` returns a paginated envelope:
///   data.bookings        -> rows, each eager-loading
///                           user / employee / bookingServices.service / payment
///   data.nextPageUrl     -> null on the last page
///   data.previousPageUrl
class ReservationsRepository {
  const ReservationsRepository();

  Future<List<BookingModel>> getBookings() async {
    final response = await ApiClient.get(ApiEndpoints.bookings);

    return ApiResponse.asMapList(ApiResponse.data(response)['bookings'])
        .map(_toModel)
        .toList();
  }

  /// GET /expert/bookings/{id} -> data.booking
  ///
  /// This used to live inline in the BLoC with a pasted Bearer token
  /// and a hand-built http.Request. It now goes through [ApiClient]
  /// like everything else, so the session header is real.
  Future<BookingDetailModel> getBookingDetails(Object id) async {
    final response = await ApiClient.get(ApiEndpoints.booking(id));

    return BookingDetailModel.fromJson(
      ApiResponse.object(response, 'booking'),
    );
  }

  /// DELETE /expert/bookings/{id}
  ///
  /// `cancellation_reason` is required by `CancelBookingRequest`; the
  /// backend also refunds a paid deposit in the same transaction.
  /// POST /expert/bookings/{id}/confirm
  ///
  /// Moves a pending booking to confirmed and notifies the customer.
  /// The server rejects anything that is not pending.
  Future<void> confirmBooking(Object id) async {
    await ApiClient.post(ApiEndpoints.confirmBooking(id));
  }

  /// POST /expert/bookings/{id}/complete
  ///
  /// Only valid on a confirmed booking - completing a pending one would
  /// skip the confirmation the customer is waiting for.
  Future<void> completeBooking(Object id) async {
    await ApiClient.post(ApiEndpoints.completeBooking(id));
  }

  Future<void> deleteBooking(Object id, String reason) async {
    await ApiClient.delete(
      ApiEndpoints.booking(id),
      body: {'cancellation_reason': reason},
    );
  }

  BookingModel _toModel(Map<String, dynamic> row) {
    final user = ApiResponse.asMap(row['user']);

    return BookingModel(
      id: ApiResponse.asString(row['id']),
      status: ApiResponse.asString(row['status']),
      customerName: ApiResponse.asString(user['full_name']),
      date: ApiResponse.asDate(row['booking_date']),
      time: ApiResponse.asTime(row['start_time']),
      address: ApiResponse.asString(user['city']),
      // Stored as a relative path; without the storage prefix the
      // avatar silently fails to load.
      image: AppConfig.mediaUrl(
            ApiResponse.asStringOrNull(user['profile_photo']),
          ) ??
          '',
    );
  }
}