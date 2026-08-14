import 'package:equatable/equatable.dart';
import '../../data/models/plan_model.dart';

enum PlanStatus { initial, loading, loaded }

class PlanState extends Equatable {
  const PlanState({
    this.plans = const [],
    this.selectedPlanId,
    this.status = PlanStatus.initial,
  });

  final List<PlanModel> plans;
  final String? selectedPlanId;
  final PlanStatus status;

  PlanState copyWith({
    List<PlanModel>? plans,
    String? selectedPlanId,
    PlanStatus? status,
  }) {
    return PlanState(
      plans: plans ?? this.plans,
      selectedPlanId: selectedPlanId ?? this.selectedPlanId,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [plans, selectedPlanId, status];
}
