import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import '../../data/repositories/reports_repository.dart';
import 'reports_event.dart';
import 'reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  ReportsBloc({ReportsRepository? repository})
      : _repository = repository ?? const ReportsRepository(),
        super(const ReportsState()) {
    on<ReportsLoaded>(_onLoaded);
    on<ReportsPeriodChanged>(_onPeriodChanged);
  }

  final ReportsRepository _repository;

  Future<void> _onLoaded(
    ReportsLoaded event,
    Emitter<ReportsState> emit,
  ) async {
    emit(state.copyWith(status: ReportsStatus.loading, errorMessage: null));

    try {
      final range = _rangeFor(event.periodIndex ?? state.periodIndex);

      final report = await _repository.getReport(
        from: range.from,
        to: range.to,
      );

      emit(
        state.copyWith(
          summary: report.summary,
          bookingReport: report.bookingReport,
          revenueReport: report.revenueReport,
          materialsUsage: report.materialsUsage,
          materialsUsedCount: report.materialsUsedCount,
          depositsCollected: report.depositsCollected,
          followers: report.followers,
          ratingAverage: report.ratingAverage,
          periodIndex: event.periodIndex ?? state.periodIndex,
          hasData: !report.isEmpty,
          status: ReportsStatus.loaded,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: ReportsStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: ReportsStatus.failure,
        errorMessage: 'Could not load your report.',
      ));
    }
  }

  /// The Weekly/Monthly toggle now changes the date range sent to the
  /// server instead of swapping between two hardcoded datasets.
  void _onPeriodChanged(
    ReportsPeriodChanged event,
    Emitter<ReportsState> emit,
  ) {
    emit(state.copyWith(periodIndex: event.periodIndex));
    add(ReportsLoaded(periodIndex: event.periodIndex));
  }

  _DateRange _rangeFor(int periodIndex) {
    final now = DateTime.now();
    final from = periodIndex == 0
        ? now.subtract(const Duration(days: 7))
        : DateTime(now.year, now.month - 1, now.day);

    return _DateRange(from: _format(from), to: _format(now));
  }

  String _format(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

class _DateRange {
  const _DateRange({required this.from, required this.to});

  final String from;
  final String to;
}
