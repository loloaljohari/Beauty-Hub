
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/validators.dart';
import '../../core/network/api_client.dart';
import '../../data/repositories/add_service_repository.dart';
import 'add_service_event.dart';
import 'add_service_state.dart';

class AddServiceBloc extends Bloc<AddServiceEvent, AddServiceState> {
  AddServiceBloc({AddServiceRepository? repository})
      : _repository = repository ?? const AddServiceRepository(),
        super(const AddServiceState()) {
    on<AddServiceStarted>(_onStarted);
    on<AddServiceFieldChanged>(_onFieldChanged);
    on<AddServiceInstructionAdded>(_onInstructionAdded);
    on<AddServiceInstructionRemoved>(_onInstructionRemoved);
    on<AddServiceHomeAvailabilityToggled>(_onHomeAvailabilityToggled);
    on<AddServiceCityToggled>(_onCityToggled);
    on<AddServiceMinimumPeopleChanged>(_onMinimumPeopleChanged);
    on<AddServiceQuestionAnswerChanged>(_onQuestionAnswerChanged);
    on<AddServiceNextStepRequested>(_onNextStepRequested);
    on<AddServicePreviousStepRequested>(_onPreviousStep);
    on<AddServiceSubmitted>(_onSubmitted);
    on<ToggleQuestionEvent>(_toggleQuestion);
    on<UpdateServiceBloc>(_onUpdate);
  }

  final AddServiceRepository _repository;

  void _onStarted(AddServiceStarted event, Emitter<AddServiceState> emit) {
    emit(
      state.copyWith(
        instructions: _repository.getDefaultInstructions(),
        allCities: _repository.getAvailableCities(),
        questionSections: _repository.getRequiredQuestionSections(),
      ),
    );
  }

  void _onFieldChanged(
    AddServiceFieldChanged event,
    Emitter<AddServiceState> emit,
  ) {
    final updated = Map<String, String>.from(state.fields);
    updated[event.key] = event.value;
    emit(state.copyWith(fields: updated, status: AddServiceStatus.initial));
  }

  void _onInstructionAdded(
    AddServiceInstructionAdded event,
    Emitter<AddServiceState> emit,
  ) {
    if (event.text.trim().isEmpty) return;
    final updated = List<String>.from(state.instructions)
      ..add(event.text.trim());
    emit(state.copyWith(instructions: updated));
  }

  void _onInstructionRemoved(
    AddServiceInstructionRemoved event,
    Emitter<AddServiceState> emit,
  ) {
    final updated = List<String>.from(state.instructions);
    if (event.index >= 0 && event.index < updated.length) {
      updated.removeAt(event.index);
    }
    emit(state.copyWith(instructions: updated));
  }

  void _onHomeAvailabilityToggled(
    AddServiceHomeAvailabilityToggled event,
    Emitter<AddServiceState> emit,
  ) {
    emit(state.copyWith(availableAtHome: !state.availableAtHome));
  }

  void _onCityToggled(
    AddServiceCityToggled event,
    Emitter<AddServiceState> emit,
  ) {
    final updated = List<String>.from(state.selectedCities);
    if (updated.contains(event.city)) {
      updated.remove(event.city);
    } else {
      updated.add(event.city);
    }
    emit(state.copyWith(selectedCities: updated));
  }

  void _onMinimumPeopleChanged(
    AddServiceMinimumPeopleChanged event,
    Emitter<AddServiceState> emit,
  ) {
    final next = (state.minimumPeople + event.delta).clamp(1, 50);
    emit(state.copyWith(minimumPeople: next));
  }

  void _onQuestionAnswerChanged(
    AddServiceQuestionAnswerChanged event,
    Emitter<AddServiceState> emit,
  ) {
    final updated = Map<String, String>.from(state.answers);
    updated[event.questionId] = event.answer;
    emit(state.copyWith(answers: updated));
  }

  void _toggleQuestion(
      ToggleQuestionEvent event, Emitter<AddServiceState> emit) {
    final selected = Map<String, bool>.from(state.question);

    selected[event.questionId] = !(selected[event.questionId] ?? false);
    emit(
      state.copyWith(
        question: selected,
      ),
    );
  }

  void _onPreviousStep(
    AddServicePreviousStepRequested event,
    Emitter<AddServiceState> emit,
  ) {
    if (!state.isFirstStep) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  Future<void> _onNextStepRequested(
    AddServiceNextStepRequested event,
    Emitter<AddServiceState> emit,
  ) async {
    emit(state.copyWith(status: AddServiceStatus.loading));

    try {
      switch (state.currentStep) {
        case 0:
          // 1. طلب الخطوة الأولى وجلب الـ serviceId
          final newServiceId = await _repository.saveBasicInfo(
            name: state.fieldValue('name'),
            id: int.parse(state.fieldValue('id')),
            bio: state.fieldValue('bio'),
            price: state.fieldValue('price'),
            duration: state.fieldValue('duration'),
          );
          emit(state.copyWith(
            serviceid: newServiceId,
            currentStep: state.currentStep + 1,
            status: AddServiceStatus.initial,
          ));
          return;

        case 1:
          if (state.instructions.isEmpty) {
            throw Exception('Please add at least one instruction');
          }
          await _repository.saveInstructions(
            serviceId: state.serviceid!,
            instructions: state.instructions,
          );
          break;

        case 2:
          if (state.availableAtHome) {
            await _repository.saveHomeServiceSettings(
              serviceId: state.serviceid!,
              availableAtHome: state.availableAtHome,
              selectedCities: state.selectedCities,
              minimumPeople: state.minimumPeople,
            );
          }
          break;

        default:
          break;
      }

      emit(state.copyWith(
        currentStep: state.currentStep + 1,
        status: AddServiceStatus.initial,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: AddServiceStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AddServiceStatus.failure,
        errorMessage: e is Exception
            ? e.toString().replaceFirst('Exception: ', '')
            : 'Something went wrong. Please try again.',
      ));
    }
  }

  Future<void> _onSubmitted(
    AddServiceSubmitted event,
    Emitter<AddServiceState> emit,
  ) async {
    emit(state.copyWith(status: AddServiceStatus.loading));

    try {
      final List<Map<String, dynamic>> selectedQuestions = [];

      for (final section in state.questionSections) {
        for (final question in section.questions) {
          final isChecked = state.question[question.id] ?? false;

          if (isChecked) {
            selectedQuestions.add({
              'question_text': question.text,
              // The backend accepts yes_no | multiple_choice | free_text.
              // These are all yes/no prompts from the medical checklist.
              'answer_type': 'yes_no',
              'is_required': true,
            });
          }
        }
      }

      // The endpoint validates `questions` as `array|min:1`, so posting
      // an empty selection returns a 422 that reads like a server fault.
      // Finishing the wizard with no questions is legitimate - just skip
      // the call.
      if (selectedQuestions.isNotEmpty) {
        await _repository.saveQuestions(
          serviceId: state.serviceid!,
          questions: selectedQuestions,
        );
      }

      emit(state.copyWith(status: AddServiceStatus.success));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: AddServiceStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AddServiceStatus.failure,
        errorMessage: e is Exception
            ? e.toString().replaceFirst('Exception: ', '')
            : 'Something went wrong. Please try again.',
      ));
    }
  }

  Future<void> _onUpdate(
    UpdateServiceBloc event,
    Emitter<AddServiceState> emit,
  ) async {
    emit(state.copyWith(status: AddServiceStatus.loading));

    try {
      await _repository.updateService(
        serviceId: int.parse(event.id!),
        // Every line, not just the first - `instructions` is one TEXT
        // column, so the list is joined the same way it is on create.
        instructions: state.instructions.join('\n'),
        name: state.fieldValue('name'),
        id: int.tryParse(state.fieldValue('id')),
        bio: state.fieldValue('bio'),
        price: state.fieldValue('price'),
        duration: state.fieldValue('duration'),
      );

      emit(state.copyWith(status: AddServiceStatus.success));
      
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: AddServiceStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AddServiceStatus.failure,
        errorMessage: e is Exception
            ? e.toString().replaceFirst('Exception: ', '')
            : 'Something went wrong. Please try again.',
      ));
    }
  }
}
