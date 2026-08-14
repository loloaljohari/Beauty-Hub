import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/validators.dart';
import '../../data/repositories/shop_repository.dart';
import 'add_product_event.dart';
import 'add_product_state.dart';

/// Creating and editing a product in the expert's own storefront.
///
/// `POST /expert/store/products` and `POST /expert/store/products/{id}`.
/// Before these existed the submit handler was a `Future.delayed` that
/// reported success without saving anything.
class AddProductBloc extends Bloc<AddProductEvent, AddProductState> {
  AddProductBloc({ShopRepository? repository})
      : _repository = repository ?? const ShopRepository(),
        super(const AddProductState()) {
    on<AddProductStarted>(_onStarted);
    on<AddProductFieldChanged>(_onFieldChanged);
    on<AddProductSubmitted>(_onSubmitted);
    on<AddProductImagePicked>(_onImagePicked);
  }

  final ShopRepository _repository;

  /// Loads an existing product into the form when editing.
  ///
  /// There is no single-product GET on the store side, so the row comes
  /// out of the list the expert already owns.
  Future<void> _onStarted(
    AddProductStarted event,
    Emitter<AddProductState> emit,
  ) async {
    if (event.productId == null) return;

    emit(state.copyWith(
      productId: event.productId,
      status: AddProductStatus.loading,
    ));

    try {
      final products = await _repository.getStoreProducts();
      final match = products.where((p) => p.id == event.productId);

      if (match.isEmpty) {
        emit(state.copyWith(
          status: AddProductStatus.failure,
          errorMessage: 'That product no longer exists.',
        ));
        return;
      }

      final product = match.first;

      emit(state.copyWith(
        fields: {
          'name': product.name,
          'bio': product.description,
          'price': product.price.toString(),
          'currentStock': (product.stock ?? 0).toString(),
          'category': product.category,
        },
        existingImageUrl: product.imageUrl,
        status: AddProductStatus.initial,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: AddProductStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: AddProductStatus.failure,
        errorMessage: 'Could not open this product.',
      ));
    }
  }

  void _onImagePicked(
    AddProductImagePicked event,
    Emitter<AddProductState> emit,
  ) {
    emit(state.copyWith(imagePath: event.imagePath));
  }

  void _onFieldChanged(
    AddProductFieldChanged event,
    Emitter<AddProductState> emit,
  ) {
    final updated = Map<String, String>.from(state.fields);
    updated[event.key] = event.value;
    emit(state.copyWith(fields: updated, status: AddProductStatus.initial));
  }

  Future<void> _onSubmitted(
    AddProductSubmitted event,
    Emitter<AddProductState> emit,
  ) async {
    final f = state.fields;

    final firstError = <String?>[
      Validators.required(f['name']),
      Validators.required(f['price']),
    ].firstWhere((e) => e != null, orElse: () => null);

    if (firstError != null) {
      emit(state.copyWith(
        status: AddProductStatus.failure,
        errorMessage: firstError,
      ));
      return;
    }

    final price = double.tryParse(state.fieldValue('price').trim());
    if (price == null || price < 0) {
      emit(state.copyWith(
        status: AddProductStatus.failure,
        errorMessage: 'Enter a valid price.',
      ));
      return;
    }

    emit(state.copyWith(status: AddProductStatus.loading));

    try {
      if (state.isEditing) {
        await _repository.updateStoreProduct(
          productId: state.productId!,
          fields: {
            'name': state.fieldValue('name'),
            'price': price.toString(),
            if (state.fieldValue('bio').isNotEmpty)
              'description': state.fieldValue('bio'),
            if (state.fieldValue('currentStock').isNotEmpty)
              'stock_quantity': state.fieldValue('currentStock'),
            if (state.fieldValue('reorderAt').isNotEmpty)
              'min_stock_threshold': state.fieldValue('reorderAt'),
          },
          imagePath: state.imagePath,
        );
      } else {
        await _repository.createStoreProduct(
          name: state.fieldValue('name'),
          // SKU is required and unique per provider. The form does not
          // collect one, so a stable code is derived from the name plus
          // a timestamp rather than failing validation.
          sku: _generateSku(state.fieldValue('name')),
          price: price,
          description: state.fieldValue('bio'),
          stockQuantity:
              double.tryParse(state.fieldValue('currentStock')) ?? 0,
          minStockThreshold: double.tryParse(state.fieldValue('reorderAt')),
          imagePath: state.imagePath,
        );
      }

      emit(state.copyWith(status: AddProductStatus.success));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: AddProductStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: AddProductStatus.failure,
        errorMessage: 'Could not save the product. Please try again.',
      ));
    }
  }

  /// e.g. "Rose Serum" -> "ROSSER-4821". Uniqueness only has to hold
  /// within this expert's own products, which the suffix guarantees.
  String _generateSku(String name) {
    final letters = name
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z]'), '')
        .padRight(3, 'X');

    final prefix = letters.substring(0, letters.length >= 6 ? 6 : letters.length);
    final suffix = DateTime.now().millisecondsSinceEpoch % 10000;

    return '$prefix-$suffix';
  }
}
