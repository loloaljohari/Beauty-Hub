import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/validators.dart';
import '../../data/repositories/material_inventory_repository.dart';
import 'add_material_event.dart';
import 'add_material_state.dart';

class AddMaterialBloc extends Bloc<AddMaterialEvent, AddMaterialState> {
  final MaterialInventoryRepository _repository;
  AddMaterialBloc(this._repository) : super(const AddMaterialState()) {
    on<AddMaterialFieldChanged>(_onFieldChanged);
    on<AddMaterialImagePicked>(_onImagePicked);
    on<UpdateMaterialSubmitted>(_onUpdateSubmitted);
    on<AddMaterialSubmitted>(_onSubmitted);
    
  }

  void _onFieldChanged(
    AddMaterialFieldChanged event,
    Emitter<AddMaterialState> emit,
  ) {
    final updated = Map<String, String>.from(state.fields);
    updated[event.key] = event.value;
    emit(state.copyWith(fields: updated, status: AddMaterialStatus.initial));
  }

  void _onImagePicked(
    AddMaterialImagePicked event,
    Emitter<AddMaterialState> emit,
  ) {
    emit(state.copyWith(imagePath: event.imagePath));
  }

  Future<void> _onSubmitted(
    AddMaterialSubmitted event,
    Emitter<AddMaterialState> emit,
  ) async {
    final f = state.fields;
    final errors = <String?>[
      Validators.required(f['name']),
      Validators.required(f['stockQuantity']),
    ];
    final firstError = errors.firstWhere((e) => e != null, orElse: () => null);

    if (firstError != null) {
      emit(state.copyWith(
        status: AddMaterialStatus.failure,
        errorMessage: firstError,
      ));
      return;
    }

    emit(state.copyWith(status: AddMaterialStatus.loading));

    try {
      await _repository.addMaterial(
        category_id: int.tryParse(f['category'] ?? '1') ?? 1,
        name: f['name']!,
        sku: f['sku'] ?? '',
        description: f['description'] ?? '',
        price: f['price'] ?? '0',
        wholesalePrice: f['wholesalePrice'] ?? '',
        min_stock: double.tryParse(f['min_stock'] ?? '0') ?? 0.0,
        stockQuantity: f['stockQuantity']!,
        imagePath: state.imagePath,
      );
       final updated = await _repository.getMaterials();
      
      emit(state.copyWith(status: AddMaterialStatus.success));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: AddMaterialStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AddMaterialStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

 Future<void> _onUpdateSubmitted(
  UpdateMaterialSubmitted event,
  Emitter<AddMaterialState> emit,
) async {
  final f = state.fields;

  // دالة مساعدة للحصول على القيمة المحدثة، أو العودة للقيمة الأصلية إذا كانت فارغة أو null
  String getValue(String key, String defaultValue) {
    final val = f[key];
    if (val == null || val.trim().isEmpty) {
      return defaultValue;
    }
    return val;
  }

  // استخراج القيم مع التراجع إلى قيمة المادة الحالية (materialItem) عند العدم
  final name = getValue('name', event.materialItem.name);
  final sku = getValue('sku', event.materialItem.sku);
  final description = getValue('description', event.materialItem.description);
  final price = getValue('price', event.materialItem.price.toString());
  final wholesalePrice = getValue('wholesalePrice', event.materialItem.wholesalePrice.toString());
  final stockQuantity = getValue('stockQuantity', event.materialItem.quantity.toString());
  final minStock = double.tryParse(getValue('min_stock', event.materialItem.min_stock.toString())) ?? 0.0;

  // التحقق من الحقول الإلزامية
  final errors = <String?>[
    Validators.required(name),
    Validators.required(stockQuantity),
    Validators.required(sku), // التأكد من وجود SKU وعدم إرساله فارغاً
  ];

  final firstError = errors.firstWhere((e) => e != null, orElse: () => null);

  if (firstError != null) {
    emit(state.copyWith(
      status: AddMaterialStatus.failure,
      errorMessage: firstError,
    ));
    return;
  }

  emit(state.copyWith(status: AddMaterialStatus.loading));

  try {
    await _repository.updateMaterial(
      id: event.id,
      // The fallback used to be `event.materialItem.category`, which is
      // the category NAME - `int.tryParse` returns null on it, so every
      // edit that did not touch the dropdown silently reassigned the
      // item to category 1.
      category_id: int.tryParse(
            f['category']?.isNotEmpty == true
                ? f['category']!
                : event.materialItem.categoryId,
          ) ??
          1,
      name: name,
      sku: sku,
      description: description,
      price: price,
      wholesalePrice: wholesalePrice,
      min_stock: minStock,
      stockQuantity: stockQuantity,
      imagePath: state.imagePath,
    );
    
    emit(state.copyWith(status: AddMaterialStatus.success));
  } on ApiException catch (e) {
    print('ApiException: ${e.message}');
    emit(state.copyWith(
      status: AddMaterialStatus.failure,
      errorMessage: e.message,
    ));
  } catch (e) {
    emit(state.copyWith(
      status: AddMaterialStatus.failure,
      errorMessage: e.toString(),
    ));
  }
}
}
