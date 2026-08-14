import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_response.dart';
import '../models/report_models.dart';

/// The expert's business report - `GET /expert/reports?from=&to=`.
///
/// Response shape:
///   period              -> {from, to}
///   bookings            -> {total, completed, cancelled}
///   revenue             -> {gross, deposits_collected}
///   materials_consumed  -> [{name, total_quantity}]
///   top_services        -> [{name, bookings, revenue}]
///   audience            -> {followers, rating_avg}
///
/// The screen used to show a fabricated weekday bar chart. The API has
/// no per-day breakdown, so that chart is now driven by `top_services`
/// (bookings per service) and the revenue chart by the same rows'
/// revenue - real numbers with honest labels, instead of invented days.
class ReportsRepository {
  const ReportsRepository();

  /// [from] and [to] are `YYYY-MM-DD`. Omitting them makes the backend
  /// default to the last 30 days.
  Future<ExpertReport> getReport({String? from, String? to}) async {
    final response = await ApiClient.get(
      ApiEndpoints.reports,
      query: {
        if (from != null) 'from': from,
        if (to != null) 'to': to,
      },
    );

    final payload = ApiResponse.data(response);

    final bookings = ApiResponse.asMap(payload['bookings']);
    final revenue = ApiResponse.asMap(payload['revenue']);
    final audience = ApiResponse.asMap(payload['audience']);
    final period = ApiResponse.asMap(payload['period']);

    final materials = ApiResponse.asMapList(payload['materials_consumed']);
    final topServices = ApiResponse.asMapList(payload['top_services']);

    final totalBookings = ApiResponse.asInt(bookings['total']);
    final completed = ApiResponse.asInt(bookings['completed']);
    // Backend spells it "cancelled"; the Flutter model uses "canceled".
    final cancelled = ApiResponse.asInt(bookings['cancelled']);
    final gross = ApiResponse.asDouble(revenue['gross']);

    return ExpertReport(
      from: ApiResponse.asDate(period['from']),
      to: ApiResponse.asDate(period['to']),
      summary: ReportSummaryModel(
        totalBookings: totalBookings,
        profit: gross,
        materialsUsed: materials.length,
      ),
      bookingReport: BookingReportModel(
        total: totalBookings,
        completed: completed,
        canceled: cancelled,
        weeklyPoints: topServices
            .map((row) => ChartPointModel(
                  label: ApiResponse.asString(row['name']),
                  value: ApiResponse.asDouble(row['bookings']),
                ))
            .toList(),
      ),
      revenueReport: BookingReportModel(
        total: totalBookings,
        completed: completed,
        canceled: cancelled,
        weeklyPoints: topServices
            .map((row) => ChartPointModel(
                  label: ApiResponse.asString(row['name']),
                  value: ApiResponse.asDouble(row['revenue']),
                ))
            .toList(),
      ),
      materialsUsage: _toUsage(materials),
      depositsCollected: ApiResponse.asDouble(revenue['deposits_collected']),
      followers: ApiResponse.asInt(audience['followers']),
      ratingAverage: ApiResponse.asDouble(audience['rating_avg']),
    );
  }

  /// The API returns absolute quantities; the pie chart wants shares,
  /// so the percentages are computed here rather than guessed.
  List<MaterialUsageModel> _toUsage(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return const [];

    final total = rows.fold<double>(
      0,
      (sum, row) => sum + ApiResponse.asDouble(row['total_quantity']),
    );

    if (total <= 0) return const [];

    return rows
        .map((row) => MaterialUsageModel(
              label: ApiResponse.asString(row['name']),
              percent:
                  ApiResponse.asDouble(row['total_quantity']) / total * 100,
            ))
        .toList();
  }
}

/// Everything the Reports screen needs, in one round trip.
class ExpertReport {
  const ExpertReport({
    required this.summary,
    required this.bookingReport,
    required this.revenueReport,
    this.materialsUsage = const [],
    this.from = '',
    this.to = '',
    this.depositsCollected = 0,
    this.followers = 0,
    this.ratingAverage = 0,
  });

  final ReportSummaryModel summary;
  final BookingReportModel bookingReport;
  final BookingReportModel revenueReport;
  final List<MaterialUsageModel> materialsUsage;
  final String from;
  final String to;
  final double depositsCollected;
  final int followers;
  final double ratingAverage;

  int get materialsUsedCount => materialsUsage.length;

  /// True when the period genuinely contains no activity, so the screen
  /// can show an empty state instead of a chart full of zeroes.
  bool get isEmpty =>
      summary.totalBookings == 0 &&
      summary.profit == 0 &&
      materialsUsage.isEmpty;
}
