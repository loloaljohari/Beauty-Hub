import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/validators.dart';
import 'add_work_time_event.dart';
import 'add_work_time_state.dart';

class AddWorkTimeBloc extends Bloc<AddWorkTimeEvent, AddWorkTimeState> {
  AddWorkTimeBloc() : super(const AddWorkTimeState()) {
    on<AddWorkTimeDayChanged>(
      (event, emit) => emit(state.copyWith(day: event.day)),
    );
    on<AddWorkTimeStartChanged>(
      (event, emit) => emit(state.copyWith(startTime: event.time)),
    );
    on<AddWorkTimeEndChanged>(
      (event, emit) => emit(state.copyWith(endTime: event.time)),
    );
    on<AddWorkTimeSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    AddWorkTimeSubmitted event,
    Emitter<AddWorkTimeState> emit,
  ) async {
    final dayError = Validators.required(state.day);
    final startError = Validators.required(state.startTime);
    final endError = Validators.required(state.endTime);
    final error = dayError ?? startError ?? endError;

    if (error != null) {
      emit(
        state.copyWith(status: AddWorkTimeStatus.failure, errorMessage: error),
      );
      return;
    }

    emit(state.copyWith(status: AddWorkTimeStatus.success));
  }
}
