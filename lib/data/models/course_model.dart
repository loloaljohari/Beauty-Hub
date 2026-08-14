import 'package:equatable/equatable.dart';

/// A course the expert is enrolled in, shown on "My Courses".
class CourseModel extends Equatable {
  const CourseModel({
    required this.id,
    required this.title,
    required this.provider,
    required this.year,
  });

  final String id;
  final String title;
  final String provider;
  final String year;

  @override
  List<Object?> get props => [id, title, provider, year];
}
