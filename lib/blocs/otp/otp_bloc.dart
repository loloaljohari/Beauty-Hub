import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import '../../core/network/auth_failure.dart';
import '../../core/storage/storage_service.dart';
import '../../data/repositories/auth_repository.dart';
import 'otp_event.dart';
import 'otp_state.dart';

class OtpBloc extends Bloc<OtpEvent, OtpState> {
  OtpBloc({AuthRepository? repository})
      : _repository = repository ?? const AuthRepository(),
        super(_initialState(repository ?? const AuthRepository())) {
    on<OtpCountdownStarted>(_onCountdownStarted);
    on<OtpCountdownTicked>(_onCountdownTicked);
    on<OtpDigitChanged>(_onDigitChanged);
    on<OtpResendRequested>(_onResendRequested);
    on<OtpSubmitted>(_onSubmitted);
  }

  final AuthRepository _repository;
  Timer? _timer;

  static OtpState _initialState(AuthRepository repository) {
    return OtpState(
      digits: List.filled(repository.getOtpLength(), ''),
      remainingSeconds: repository.getResendCountdownSeconds(),
    );
  }

  void _onCountdownStarted(
    OtpCountdownStarted event,
    Emitter<OtpState> emit,
  ) {
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = state.remainingSeconds - 1;
      if (remaining <= 0) {
        timer.cancel();
        add(const OtpCountdownTicked(0));
      } else {
        add(OtpCountdownTicked(remaining));
      }
    });
  }

  void _onCountdownTicked(
    OtpCountdownTicked event,
    Emitter<OtpState> emit,
  ) {
    emit(
      state.copyWith(
        remainingSeconds: event.remainingSeconds,
        canResend: event.remainingSeconds <= 0,
      ),
    );
  }

  void _onDigitChanged(OtpDigitChanged event, Emitter<OtpState> emit) {
    final updated = List<String>.from(state.digits);
    if (event.index >= 0 && event.index < updated.length) {
      updated[event.index] = event.value;
    }
    emit(state.copyWith(digits: updated, status: OtpStatus.initial));
  }

  Future<void> _onResendRequested(
    OtpResendRequested event,
    Emitter<OtpState> emit,
  ) async {
    if (!state.canResend) return;

    // POST /expert/auth/resend_otp. The email comes from the event when
    // the screen has it, otherwise from the address stashed during
    // register / forgot-password.
    final email = event.email?.trim().isNotEmpty == true
        ? event.email!.trim()
        : await StorageService.getPendingOtpEmail();

    if (email == null || email.isEmpty) {
      emit(state.copyWith(
        status: OtpStatus.failure,
        errorMessage: 'We could not tell which account to resend to.',
      ));
      return;
    }

    try {
      await _repository.resendOtp(email: email);
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: OtpStatus.failure,
        errorMessage: AuthFailure.fromStatusCode(e.statusCode, e.message),
      ));
      return;
    } catch (_) {
      emit(state.copyWith(
        status: OtpStatus.failure,
        errorMessage: 'Could not resend the code. Please try again.',
      ));
      return;
    }

    emit(
      state.copyWith(
        digits: List.filled(_repository.getOtpLength(), ''),
        remainingSeconds: _repository.getResendCountdownSeconds(),
        canResend: false,
        status: OtpStatus.initial,
      ),
    );
    _startTimer();
  }

  Future<void> _onSubmitted(OtpSubmitted event, Emitter<OtpState> emit) async {
    if (!state.isComplete) {
      emit(
        state.copyWith(
          status: OtpStatus.failure,
          errorMessage: 'Please enter the full verification code',
        ),
      );
      return;
    }
  
    emit(state.copyWith(status: OtpStatus.loading));
    
   try {
    print('Submitting OTP for email: ${event.email}, code: ${state.code}');
    await const AuthRepository().verifyOtp(
      email: event.email,
      otp: state.code,

    );
    emit(state.copyWith(status: OtpStatus.success));
  } on ApiException catch (e) {
    emit(state.copyWith(
      status: OtpStatus.failure,
      errorMessage: AuthFailure.fromStatusCode(e.statusCode, e.message),
    ));
  } catch (e) { 
       print(e.toString());
    emit(state.copyWith(
      status: OtpStatus.failure,
      errorMessage: e.toString(),
  
    ));
  }
    
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
