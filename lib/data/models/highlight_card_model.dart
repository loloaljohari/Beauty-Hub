import 'package:equatable/equatable.dart';

/// Type of horizontal highlight card shown on the Home screen
/// (New Course / Nearest Appointment / Job Application).
enum HighlightCardType { newCourse, nearestAppointment, jobApplication }

class HighlightCardModel extends Equatable {
  const HighlightCardModel({
    required this.id,
    required this.type,
    required this.title,
    this.count = 0,
  });

  final String id;
  final HighlightCardType type;
  final String title;

  /// Real figure behind the card (courses, upcoming bookings, pending
  /// job requests) rather than a decorative label.
  final int count;

  @override
  List<Object?> get props => [id, type, title, count];
}

/// Type of dismissible toast/notification banner shown on Home
/// (e.g. "Do you want to register?", "we would join to us?").
class HomeNotificationModel extends Equatable {
  const HomeNotificationModel({
    required this.nameUser,
    required this.image,
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.acceptLabel = 'accept',
    this.declineLabel = 'Cancel',
  });

  final String id;
  final String title;
  final String nameUser;
  final String image;
  final String message;
  final String timestamp;
  final String acceptLabel;
  final String declineLabel;

  @override
  List<Object?> get props => [
        id,
        title,
        nameUser,
        image,
        message,
        timestamp,
        acceptLabel,
        declineLabel,
      ];
}
