import 'package:equatable/equatable.dart';

abstract class ReportsEvent extends Equatable {
  const ReportsEvent();

  @override
  List<Object?> get props => [];
}

class ReportsLoaded extends ReportsEvent {
  const ReportsLoaded({this.periodIndex});

  /// When null the BLoC keeps whatever period is already selected.
  final int? periodIndex;

  @override
  List<Object?> get props => [periodIndex];
}

/// Switches between Weekly and Monthly views.
class ReportsPeriodChanged extends ReportsEvent {
  const ReportsPeriodChanged(this.periodIndex);

  /// 0 = Weekly, 1 = Monthly.
  final int periodIndex;

  @override
  List<Object?> get props => [periodIndex];
}
