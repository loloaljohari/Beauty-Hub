import 'package:equatable/equatable.dart';

enum OtpStatus { initial, loading, success, failure }

class OtpState extends Equatable {
  const OtpState({
    this.digits = const ['', '', '', '', '',''],
    this.remainingSeconds = 154, // 02:34
    this.canResend = false,
    this.status = OtpStatus.initial,
    this.errorMessage,
  });

  /// One entry per OTP box.
  final List<String> digits;

  /// Seconds remaining before resend is allowed.
  final int remainingSeconds;

  /// Whether the "Order" (resend) action is currently enabled.
  final bool canResend;

  final OtpStatus status;
  final String? errorMessage;

  /// Combined code, e.g. "9236".
  String get code => digits.join();

  /// Whether all boxes are filled.
  bool get isComplete => digits.every((d) => d.isNotEmpty);

  /// Formatted mm:ss countdown string.
  String get formattedTime {
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  OtpState copyWith({
    List<String>? digits,
    int? remainingSeconds,
    bool? canResend,
    OtpStatus? status,
    String? errorMessage,
  }) {
    return OtpState(
      digits: digits ?? this.digits,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      canResend: canResend ?? this.canResend,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        digits,
        remainingSeconds,
        canResend,
        status,
        errorMessage,
      ];
}
