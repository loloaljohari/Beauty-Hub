import 'package:equatable/equatable.dart';

abstract class AddServiceEvent extends Equatable {
  const AddServiceEvent();

  @override
  List<Object?> get props => [];
}

class AddServiceStarted extends AddServiceEvent {
  const AddServiceStarted();
}

/// Step 1: basic info field change (name, category, bio, price, duration).
class AddServiceFieldChanged extends AddServiceEvent {
  const AddServiceFieldChanged(this.key, this.value);

  final String key;
  final String value;

  @override
  List<Object?> get props => [key, value];
}

/// Step 2: add a new pre-booking instruction.
class AddServiceInstructionAdded extends AddServiceEvent {
  const AddServiceInstructionAdded(this.text);

  final String text;

  @override
  List<Object?> get props => [text];
}

/// Step 2: remove an instruction by index.
class AddServiceInstructionRemoved extends AddServiceEvent {
  const AddServiceInstructionRemoved(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

/// Step 3: toggles whether this service can be performed at the
/// customer's home.
class AddServiceHomeAvailabilityToggled extends AddServiceEvent {
  const AddServiceHomeAvailabilityToggled();
}

/// Step 3: toggles a city in/out of the available-cities selection.
class AddServiceCityToggled extends AddServiceEvent {
  const AddServiceCityToggled(this.city);

  final String city;

  @override
  List<Object?> get props => [city];
}

/// Step 3: increments/decrements the minimum-people stepper.
class AddServiceMinimumPeopleChanged extends AddServiceEvent {
  const AddServiceMinimumPeopleChanged(this.delta);

  final int delta;

  @override
  List<Object?> get props => [delta];
}

/// Step 4: updates the free-text answer for a single required question.
class AddServiceQuestionAnswerChanged extends AddServiceEvent {
  const AddServiceQuestionAnswerChanged(this.questionId, this.answer);

  final String questionId;
  final String answer;

  @override
  List<Object?> get props => [questionId, answer];
}

/// Navigates to the next step in the wizard.
class AddServiceNextStepRequested extends AddServiceEvent {
  const AddServiceNextStepRequested();
}

/// Navigates to the previous step in the wizard.
class AddServicePreviousStepRequested extends AddServiceEvent {
  const AddServicePreviousStepRequested();
}

/// Final submission on the last step.
class AddServiceSubmitted extends AddServiceEvent {
  const AddServiceSubmitted();
}
/// Final submission on the last step.
class UpdateServiceBloc extends AddServiceEvent {
  final id;
  const UpdateServiceBloc(this.id);
}

class ToggleQuestionEvent extends AddServiceEvent {
  final String questionId;

  const ToggleQuestionEvent(this.questionId);

  @override
  List<Object?> get props => [questionId];
}