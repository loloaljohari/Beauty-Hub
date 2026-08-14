import 'package:equatable/equatable.dart';

enum AddProductStatus { initial, loading, success, failure }

class AddProductState extends Equatable {
  const AddProductState({
    this.fields = const {
      'name': '',
      'category': '',
      'bio': '',
      'price': '',
      'currentStock': '',
      'reorderAt': '',
    },
    this.status = AddProductStatus.initial,
    this.errorMessage,
    this.imagePath,
    this.productId,
    this.existingImageUrl,
  });

  final Map<String, String> fields;
  final AddProductStatus status;
  final String? errorMessage;
   final String? imagePath;

  /// Set when editing an existing product; null when creating.
  final String? productId;

  /// Photo already on the server, shown until a new one is picked.
  final String? existingImageUrl;

  bool get isEditing => productId != null;

  String fieldValue(String key) => fields[key] ?? '';

  AddProductState copyWith({
    Map<String, String>? fields,
    AddProductStatus? status,
    String? errorMessage,
    String? imagePath,
    String? productId,
    String? existingImageUrl,
  }) {
    return AddProductState(
      imagePath: imagePath ?? this.imagePath,
      fields: fields ?? this.fields,
      status: status ?? this.status,
      errorMessage: errorMessage,
      productId: productId ?? this.productId,
      existingImageUrl: existingImageUrl ?? this.existingImageUrl,
    );
  }

  @override
  List<Object?> get props =>
      [fields, status, errorMessage, imagePath, productId, existingImageUrl];
}
