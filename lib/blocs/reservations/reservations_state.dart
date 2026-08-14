import 'package:equatable/equatable.dart';
import '../../data/models/booking_detail_model.dart';
import '../../data/models/booking_model.dart';

enum ReservationsStatus { initial, loading, loaded, failure }

enum ReservationActionStatus { initial, loading, success, failure }

class ReservationsState extends Equatable {
  const ReservationsState({
    this.selectedBooking,
    this.bookings = const [],
    this.tabIndex = 0,
    this.status = ReservationsStatus.initial,
    this.actionStatus = ReservationActionStatus.initial,
    this.detailStatus = ReservationsStatus.initial,
    this.errorMessage,
  });

  final List<BookingModel> bookings;
  final int tabIndex;
  final ReservationsStatus status;
  final ReservationActionStatus actionStatus;

  /// Tracked separately so opening a booking's details never blanks
  /// out the list behind the sheet.
  final ReservationsStatus detailStatus;
  final String? errorMessage;
  final BookingDetailModel? selectedBooking;

  bool get isEmpty =>
      status == ReservationsStatus.loaded && bookings.isEmpty;
  ReservationsState copyWith(
      {List<BookingModel>? bookings,
      int? tabIndex,
      ReservationsStatus? status,
      ReservationActionStatus? actionStatus,
      ReservationsStatus? detailStatus,
      String? errorMessage,
      BookingDetailModel? selectedBooking}) {
    return ReservationsState(
        bookings: bookings ?? this.bookings,
        tabIndex: tabIndex ?? this.tabIndex,
        status: status ?? this.status,
        actionStatus: actionStatus ?? this.actionStatus,
        detailStatus: detailStatus ?? this.detailStatus,
        errorMessage: errorMessage,
        selectedBooking: selectedBooking ?? this.selectedBooking);
        
  }

  @override
  List<Object?> get props =>
      [bookings, tabIndex, status, actionStatus, detailStatus,
       errorMessage, selectedBooking];
}
