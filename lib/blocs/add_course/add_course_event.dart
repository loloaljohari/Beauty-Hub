import 'package:equatable/equatable.dart';

abstract class AddCourseEvent extends Equatable {
  const AddCourseEvent();

  @override
  List<Object?> get props => [];
}

/// Loads an existing course into the form. Omit [courseId] to create.
class AddCourseStarted extends AddCourseEvent {
  const AddCourseStarted({this.courseId});

  final String? courseId;

  @override
  List<Object?> get props => [courseId];
}

class AddCourseFieldChanged extends AddCourseEvent {
  const AddCourseFieldChanged(this.key, this.value);

  final String key;
  final String value;

  @override
  List<Object?> get props => [key, value];
}

class AddCourseOnlineToggled extends AddCourseEvent {
  const AddCourseOnlineToggled(this.isOnline);

  final bool isOnline;

  @override
  List<Object?> get props => [isOnline];
}

class AddCourseCoverPicked extends AddCourseEvent {
  const AddCourseCoverPicked(this.imagePath);

  final String imagePath;

  @override
  List<Object?> get props => [imagePath];
}

class AddCourseSubmitted extends AddCourseEvent {
  const AddCourseSubmitted();
}
