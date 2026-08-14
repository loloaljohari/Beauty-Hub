import 'package:equatable/equatable.dart';

/// A customer booking/reservation shown on the Reservations screen
/// ("Booking" tab).
class BookingModel extends Equatable {
  const BookingModel( {
    required this.status,
    required this.image,
    required this.id,
    required this.customerName,
    required this.date,
    required this.time,
    required this.address,

    
  });

  final String id;
  final String customerName;
  final String date;
  final String time;
  final String address;
  final String image;
  final String status;

  @override
  List<Object?> get props => [id, customerName, date, time, address];
}
