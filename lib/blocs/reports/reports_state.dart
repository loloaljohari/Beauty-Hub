import 'package:equatable/equatable.dart';
import '../../data/models/report_models.dart';

enum ReportsStatus { initial, loading, loaded, failure }

class ReportsState extends Equatable {
  const ReportsState({
    this.summary,
    this.bookingReport,
    this.revenueReport,
    this.materialsUsage = const [],
    this.materialsUsedCount = 0,
    this.periodIndex = 0,
    this.status = ReportsStatus.initial,
    this.depositsCollected = 0,
    this.followers = 0,
    this.ratingAverage = 0,
    this.hasData = false,
    this.errorMessage,
  });

  final ReportSummaryModel? summary;
  final BookingReportModel? bookingReport;
  final BookingReportModel? revenueReport;
  final List<MaterialUsageModel> materialsUsage;
  final int materialsUsedCount;

  /// 0 = Weekly, 1 = Monthly.
  final int periodIndex;
  final ReportsStatus status;

  /// Extra real figures the API returns that the screen can surface.
  final double depositsCollected;
  final int followers;
  final double ratingAverage;

  /// False when the selected period genuinely had no activity - lets
  /// the screen show an empty state instead of charts full of zeroes.
  final bool hasData;
  final String? errorMessage;

  ReportsState copyWith({
    ReportSummaryModel? summary,
    BookingReportModel? bookingReport,
    BookingReportModel? revenueReport,
    List<MaterialUsageModel>? materialsUsage,
    int? materialsUsedCount,
    int? periodIndex,
    ReportsStatus? status,
    double? depositsCollected,
    int? followers,
    double? ratingAverage,
    bool? hasData,
    String? errorMessage,
  }) {
    return ReportsState(
      summary: summary ?? this.summary,
      bookingReport: bookingReport ?? this.bookingReport,
      revenueReport: revenueReport ?? this.revenueReport,
      materialsUsage: materialsUsage ?? this.materialsUsage,
      materialsUsedCount: materialsUsedCount ?? this.materialsUsedCount,
      periodIndex: periodIndex ?? this.periodIndex,
      status: status ?? this.status,
      depositsCollected: depositsCollected ?? this.depositsCollected,
      followers: followers ?? this.followers,
      ratingAverage: ratingAverage ?? this.ratingAverage,
      hasData: hasData ?? this.hasData,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        summary,
        bookingReport,
        revenueReport,
        materialsUsage,
        materialsUsedCount,
        periodIndex,
        status,
        depositsCollected,
        followers,
        ratingAverage,
        hasData,
        errorMessage,
      ];
}
