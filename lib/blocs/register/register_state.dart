import 'package:equatable/equatable.dart';

enum RegisterStatus { initial, loading, success, failure }

class RegisterState extends Equatable {
  const RegisterState({
    this.fields = const {
      'firstName': '',
      'lastName': '',
      'phoneNumber': '',
      'address': '',
      'email': '',
      'password': '',
      'confirmPassword': '',
    },
    this.isPasswordObscured = true,
    this.isConfirmPasswordObscured = true,
    this.status = RegisterStatus.initial,
    this.errorMessage,
    this.imagePath,
  });

  /// All form field values keyed by field id.
  final Map<String, String> fields;
  final bool isPasswordObscured;
  final bool isConfirmPasswordObscured;
  final RegisterStatus status;
  final String? errorMessage;
   final String? imagePath;

  String fieldValue(String key) => fields[key] ?? '';

  RegisterState copyWith({

    Map<String, String>? fields,
    bool? isPasswordObscured,
    bool? isConfirmPasswordObscured,
    RegisterStatus? status,
    String? errorMessage,
    String? imagePath,
  }) {
    return RegisterState(
      imagePath: imagePath ?? this.imagePath, 
      fields: fields ?? this.fields,
      isPasswordObscured: isPasswordObscured ?? this.isPasswordObscured,
      isConfirmPasswordObscured:
          isConfirmPasswordObscured ?? this.isConfirmPasswordObscured,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [

        fields,
        isPasswordObscured,
        isConfirmPasswordObscured,
        status,
        errorMessage,
        imagePath,
      ];
}
