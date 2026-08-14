import 'package:equatable/equatable.dart';

/// Top-level KPI summary shown at the top of the Reports screen
/// (Booking / Profit / Material counts).
class ReportSummaryModel extends Equatable {
  const ReportSummaryModel({
    required this.totalBookings,
    required this.profit,
    required this.materialsUsed,
  });

  final int totalBookings;
  final double profit;
  final int materialsUsed;

  @override
  List<Object?> get props => [totalBookings, profit, materialsUsed];
}

/// A single labeled bar in the "Booking Report" chart
/// (e.g. one weekday with a booking count).
class ChartPointModel extends Equatable {
  const ChartPointModel({required this.label, required this.value});

  final String label;
  final double value;

  @override
  List<Object?> get props => [label, value];
}

/// A single slice of the "Materials Usage" breakdown
/// (e.g. "Facial Cream: 40%").
class MaterialUsageModel extends Equatable {
  const MaterialUsageModel({required this.label, required this.percent});

  final String label;
  final double percent;

  @override
  List<Object?> get props => [label, percent];
}

/// Booking-report totals shown alongside the bar chart
/// (total / completed / canceled).
class BookingReportModel extends Equatable {
  const BookingReportModel({
    required this.total,
    required this.completed,
    required this.canceled,
    required this.weeklyPoints,
  });

  final int total;
  final int completed;
  final int canceled;
  final List<ChartPointModel> weeklyPoints;

  @override
  List<Object?> get props => [total, completed, canceled, weeklyPoints];
}
