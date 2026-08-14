import 'package:equatable/equatable.dart';

abstract class AddWorkTimeEvent extends Equatable {
  const AddWorkTimeEvent();

  @override
  List<Object?> get props => [];
}

class AddWorkTimeDayChanged extends AddWorkTimeEvent {
  const AddWorkTimeDayChanged(this.day);

  final String day;

  @override
  List<Object?> get props => [day];
}

class AddWorkTimeStartChanged extends AddWorkTimeEvent {
  const AddWorkTimeStartChanged(this.time);

  final String time;

  @override
  List<Object?> get props => [time];
}

class AddWorkTimeEndChanged extends AddWorkTimeEvent {
  const AddWorkTimeEndChanged(this.time);

  final String time;

  @override
  List<Object?> get props => [time];
}

class AddWorkTimeSubmitted extends AddWorkTimeEvent {
  const AddWorkTimeSubmitted();
}
