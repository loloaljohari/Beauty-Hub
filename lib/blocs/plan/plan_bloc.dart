import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/plan_repository.dart';
import 'plan_event.dart';
import 'plan_state.dart';

class PlanBloc extends Bloc<PlanEvent, PlanState> {
  PlanBloc({PlanRepository? repository})
      : _repository = repository ?? const PlanRepository(),
        super(const PlanState()) {
    on<PlanLoaded>(_onLoaded);
    on<PlanSelected>(_onSelected);
  }

  final PlanRepository _repository;

  void _onLoaded(PlanLoaded event, Emitter<PlanState> emit) {
    emit(state.copyWith(status: PlanStatus.loading));
    final plans = _repository.getPlans();
    final current = plans.firstWhere(
      (p) => p.isCurrent,
      orElse: () => plans.first,
    );
    emit(
      state.copyWith(
        plans: plans,
        selectedPlanId: current.id,
        status: PlanStatus.loaded,
      ),
    );
  }

  void _onSelected(PlanSelected event, Emitter<PlanState> emit) {
    emit(state.copyWith(selectedPlanId: event.planId));
  }
}
