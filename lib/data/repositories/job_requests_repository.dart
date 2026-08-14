import '../../core/config/app_config.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_response.dart';
import '../models/job_request_model.dart';

/// Employment requests salons and beauty centers have sent to this
/// expert - `GET /expert/employment-requests`.
///
/// Row shape (from `employment_requests` + the joined requester):
///   {id, requester_type, requester_id, employment_type, start_date,
///    end_date, compensation, message, status, responded_at,
///    requester: {id, name, city, governorate, rating_avg, profile_photo}}
///
/// Two fields the old mock invented have no column behind them and are
/// therefore left empty rather than faked: `matchScore` (there is no
/// matching algorithm on the server) and `requirements`/`benefits`
/// (the request carries one free-text `message`, not structured lists).
class JobRequestsRepository {
  const JobRequestsRepository();

  /// [status] optionally narrows to `pending` / `accepted` / `rejected`,
  /// which the backend accepts as a query parameter.
  Future<List<JobRequestModel>> getJobRequests({String? status}) async {
    final response = await ApiClient.get(
      ApiEndpoints.employmentRequests,
      query: {if (status != null) 'status': status},
    );

    return ApiResponse.asMapList(ApiResponse.data(response)['requests'])
        .map(_toModel)
        .toList();
  }

  /// POST /expert/employment-requests/{id}/accept
  ///
  /// On success the backend also adds the expert to that provider's
  /// employee roster, so the caller should refresh the list afterwards.
  Future<void> acceptRequest(Object id) async {
    await ApiClient.post(ApiEndpoints.acceptEmployment(id));
  }

  /// POST /expert/employment-requests/{id}/reject
  Future<void> rejectRequest(Object id) async {
    await ApiClient.post(ApiEndpoints.rejectEmployment(id));
  }

  JobRequestModel _toModel(Map<String, dynamic> row) {
    final requester = ApiResponse.asMap(row['requester']);

    final city = ApiResponse.asString(requester['city']);
    final governorate = ApiResponse.asString(requester['governorate']);
    final location = [city, governorate]
        .where((part) => part.isNotEmpty)
        .toSet()
        .join(', ');

    final employmentType = ApiResponse.asString(row['employment_type']);
    final startDate = ApiResponse.asDate(row['start_date']);
    final endDate = ApiResponse.asDate(row['end_date']);

    return JobRequestModel(
      id: ApiResponse.asString(row['id']),
      centerName: ApiResponse.asString(
        requester['name'],
        fallback: ApiResponse.asString(row['requester_type']),
      ),
      location: location,
      postedDate: ApiResponse.asDate(row['created_at']),
      // `compensation` is free text on the server (e.g. "200$/month"),
      // so it is shown as-is rather than parsed into a number.
      salary: ApiResponse.asString(row['compensation']),
      // The role being offered ("Nail Tech"), falling back to the
      // employment type when the poster left it blank.
      position: ApiResponse.asString(
        row['position_title'],
        fallback: employmentType.isEmpty
            ? ''
            : '${employmentType[0].toUpperCase()}${employmentType.substring(1)}',
      ),
      experience: _experienceLabel(row, startDate, endDate),
      status: _toStatus(ApiResponse.asString(row['status'])),
      // A real column now, not the message text reused as a stand-in.
      workingHours: ApiResponse.asString(row['working_hours']),
      description: ApiResponse.asString(row['message']),
      requirements: _labels(row['requirements']),
      benefits: _labels(row['benefits']),
      // Computed server-side from specialization, years and city.
      matchScore: ApiResponse.asInt(row['match_percent']),
      logoUrl: AppConfig.mediaUrl(
        ApiResponse.asStringOrNull(requester['profile_photo']),
      ),
      rating: ApiResponse.asDouble(requester['rating_avg']),
    );
  }

  /// "+2 years" when the poster set a minimum, otherwise the contract
  /// window, which is the only other time-related fact on the request.
  String _experienceLabel(
    Map<String, dynamic> row,
    String startDate,
    String endDate,
  ) {
    final years = ApiResponse.asInt(row['required_experience_years']);

    if (years > 0) {
      return '+$years years';
    }

    if (startDate.isEmpty) return '';

    return endDate.isEmpty ? startDate : '$startDate  -  $endDate';
  }

  List<String> _labels(dynamic raw) {
    if (raw is! List) return const [];

    return raw
        .map((e) => e?.toString() ?? '')
        .where((e) => e.isNotEmpty)
        .toList();
  }

  JobRequestStatus _toStatus(String raw) {
    switch (raw) {
      case 'accepted':
        return JobRequestStatus.accepted;
      case 'rejected':
        return JobRequestStatus.rejected;
      default:
        return JobRequestStatus.newRequest;
    }
  }
}
