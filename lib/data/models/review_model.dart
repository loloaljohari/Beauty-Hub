import 'package:equatable/equatable.dart';

/// A customer review shown on the "Reviews" management screen (and
/// reused inside the salon detail "Reviews" tab).
class ReviewModel extends Equatable {
  const ReviewModel({
    required this.id,
    required this.customerName,
    required this.date,
    required this.comment,
    required this.rating,
    this.isViewed = true,
    required this.image
  });

  final String id;
  final String customerName;
  final String date;
  final String comment;
  final int rating;
  final image;

  /// Whether the expert has opened/viewed this review yet (toggles
  /// the "view" / "unviewed" label and Delete action).
  final bool isViewed;

  ReviewModel copyWith({bool? isViewed}) {
    return ReviewModel(
      image: image,
      id: id,
      customerName: customerName,
      date: date,
      comment: comment,
      rating: rating,
      isViewed: isViewed ?? this.isViewed,
    );
  }

  @override
  List<Object?> get props =>
      [id, customerName, date, comment, rating, isViewed,image];
}
