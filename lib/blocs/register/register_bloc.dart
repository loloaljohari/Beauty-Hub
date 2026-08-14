import 'package:beautyhup/data/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import '../../core/network/auth_failure.dart';
import '../../core/utils/validators.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc() : super(const RegisterState()) {
    on<RegisterFieldChanged>(_onFieldChanged);
    on<RegisterPasswordVisibilityToggled>(_onVisibilityToggled);
    on<RegisterSubmitted>(_onSubmitted);
    on<RegisterImagePicked>(_onImagePicked);
  }

  void _onFieldChanged(
    RegisterFieldChanged event,
    Emitter<RegisterState> emit,
  ) {
    print('Field changed: ${event.key} = ${event.value}');
    print('Current state fields: ${state.fields}');
    final updated = Map<String, String>.from(state.fields);
    updated[event.key] = event.value;
    emit(state.copyWith(fields: updated, status: RegisterStatus.initial));
  }

  void _onImagePicked(
    RegisterImagePicked event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(imagePath: event.imagePath));
  }

  void _onVisibilityToggled(
    RegisterPasswordVisibilityToggled event,
    Emitter<RegisterState> emit,
  ) {
    if (event.key == 'password') {
      emit(state.copyWith(isPasswordObscured: !state.isPasswordObscured));
    } else {
      emit(
        state.copyWith(
          isConfirmPasswordObscured: !state.isConfirmPasswordObscured,
        ),
      );
    }
  }

 Future<void> _onSubmitted(
  RegisterSubmitted event,
  Emitter<RegisterState> emit,
) async {
  final f = state.fields;
print('Submitting registration with fields: $f');
  final errors = <String?>[
    Validators.required(f['firstName']),
    Validators.required(f['lastName']),
    Validators.required(f['phoneNumber']),
    Validators.required(f['address']),
    Validators.email(f['email']),
    Validators.password(f['password']),
    Validators.confirmPassword(f['password'], f['confirmPassword']),
  ];

  final firstError = errors.firstWhere((e) => e != null, orElse: () => null);
  if (firstError != null) {
    emit(state.copyWith(
      status: RegisterStatus.failure,
      errorMessage: firstError,
    ));
    return;
  }

  emit(state.copyWith(status: RegisterStatus.loading));

  try {
    await const AuthRepository().register(
      firstName: f['firstName']!,
      lastName: f['lastName']!,
      phone: f['phoneNumber']!,
      address: f['address']!,
      email: f['email']!,
      password: f['password']!,
      confirmPassword: f['confirmPassword']!,

    );
    emit(state.copyWith(status: RegisterStatus.success));
  } on ApiException catch (e) {
    emit(state.copyWith(
      status: RegisterStatus.failure,
      errorMessage: AuthFailure.fromStatusCode(e.statusCode, e.message),
    ));
  } catch (e) { 
       print(e.toString());
    emit(state.copyWith(
      status: RegisterStatus.failure,
      errorMessage: e.toString(),
  
    ));
  }
}
 }
