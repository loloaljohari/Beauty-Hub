import 'package:equatable/equatable.dart';

enum AddWorkTimeStatus { initial, loading, success, failure }

class AddWorkTimeState extends Equatable {
  const AddWorkTimeState({
    this.day = '',
    this.startTime = '',
    this.endTime = '',
    this.status = AddWorkTimeStatus.initial,
    this.errorMessage,
    this.slot = '',
    this.active = true,
  });

  final String day;
  final String startTime;
  final String endTime;
  final String slot;
  final bool active;

  final AddWorkTimeStatus status;
  final String? errorMessage;

  AddWorkTimeState copyWith(
      {String? day,
      String? startTime,
      String? endTime,
      AddWorkTimeStatus? status,
      String? errorMessage,
      String? slot,
      bool? active}) {
    return AddWorkTimeState(
        day: day ?? this.day,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        status: status ?? this.status,
        errorMessage: errorMessage,
        slot: slot ?? this.slot,
        active: active ?? this.active);
  }

  @override
  List<Object?> get props =>
      [day, startTime, endTime, status, errorMessage, slot, active];
}
