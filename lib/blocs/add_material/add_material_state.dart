import 'package:equatable/equatable.dart';

enum AddMaterialStatus { initial, loading, success, failure }

class AddMaterialState extends Equatable {
  const AddMaterialState({
    this.fields = const {
      'name': '',
      'sku': '',
      'description': '',
      'price': '',
      'wholesalePrice': '',
      'stockQuantity': '',
    },
    this.imagePath,
    this.status = AddMaterialStatus.initial,
    this.errorMessage,
  });

  final Map<String, String> fields;
  final String? imagePath;
  final AddMaterialStatus status;
  final String? errorMessage;

  String fieldValue(String key) => fields[key] ?? '';

  AddMaterialState copyWith({
    Map<String, String>? fields,
    String? imagePath,
    AddMaterialStatus? status,
    String? errorMessage,
  }) {
    return AddMaterialState(
      fields: fields ?? this.fields,
      imagePath: imagePath ?? this.imagePath,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [fields, imagePath, status, errorMessage];
}
