import 'package:equatable/equatable.dart';

abstract class ReservationsEvent extends Equatable {
  const ReservationsEvent();

  @override
  List<Object?> get props => [];
}

class ReservationsLoaded extends ReservationsEvent {
  const ReservationsLoaded();
}

/// Switches between the "Booking" and "Products" top tabs.
class ReservationsTabChanged extends ReservationsEvent {
  const ReservationsTabChanged(this.tabIndex);

  /// 0 = Booking, 1 = Products.
  final int tabIndex;

  @override
  List<Object?> get props => [tabIndex];
}

class ReservationCancelled extends ReservationsEvent {
   
  const ReservationCancelled(this.bookingId, this.reason);

  final String bookingId;
  final String reason;

  @override
  List<Object?> get props => [bookingId];
}


class GetBookingDetails extends ReservationsEvent {
  final int bookingId;
  GetBookingDetails(this.bookingId);
}

/// Approves a pending booking (`POST /expert/bookings/{id}/confirm`).
class ReservationConfirmed extends ReservationsEvent {
  const ReservationConfirmed(this.bookingId);

  final String bookingId;

  @override
  List<Object?> get props => [bookingId];
}

/// Marks a confirmed booking as completed.
class ReservationCompleted extends ReservationsEvent {
  const ReservationCompleted(this.bookingId);

  final String bookingId;

  @override
  List<Object?> get props => [bookingId];
}