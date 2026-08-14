import 'package:equatable/equatable.dart';

enum ForgotPasswordStatus { initial, loading, success, failure }

class ForgotPasswordState extends Equatable {
  const ForgotPasswordState({
    this.email = '',
    this.status = ForgotPasswordStatus.initial,
    this.errorMessage,
  });

  final String email;
  final ForgotPasswordStatus status;
  final String? errorMessage;

  ForgotPasswordState copyWith({
    String? email,
    ForgotPasswordStatus? status,
    String? errorMessage,
  }) {
    return ForgotPasswordState(
      email: email ?? this.email,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [email, status, errorMessage];
}
