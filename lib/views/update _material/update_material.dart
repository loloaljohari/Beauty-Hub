import 'dart:io';
import '../../core/localization/l10n/app_localizations.dart';
import '../../core/utils/image_helpers.dart';

import 'package:beautyhup/blocs/add_material/add_material_event.dart';
import 'package:beautyhup/blocs/add_material/add_material_state.dart';
import 'package:beautyhup/core/utils/responsive.dart';
import 'package:beautyhup/data/models/material_item_model.dart';
import 'package:beautyhup/data/repositories/material_inventory_repository.dart';
import 'package:beautyhup/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../blocs/add_material/add_material_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/primary_button.dart';

class UpdateMaterial extends StatelessWidget {
  const UpdateMaterial({Key? key, required this.materialItem})
      : super(key: key);
  final MaterialItemModel materialItem;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => MaterialInventoryRepository(),
      child: BlocProvider(
        create: (context) => AddMaterialBloc(
          context.read<MaterialInventoryRepository>(),
        ),
        child: UpdateMaterialPage(materialItem: materialItem),
      ),
    );
  }
}

class UpdateMaterialPage extends StatelessWidget {
  const UpdateMaterialPage({Key? key, required this.materialItem})
      : super(key: key);
  static const MaterialInventoryRepository _repository =
      MaterialInventoryRepository();
  final MaterialItemModel materialItem;

  _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );
    if (picked != null && context.mounted) {
      context.read<AddMaterialBloc>().add(AddMaterialImagePicked(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    print('UpdateMaterialPage build called with materialItem: $materialItem');
    return BlocListener<AddMaterialBloc, AddMaterialState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AddMaterialStatus.success) {
          Navigator.pop(context, true);
        } else if (state.status == AddMaterialStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          title: Text(
            context.l10n.updateMaterial,
            style: AppTextStyles.h3.copyWith(fontSize: 18.sp(context)),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimens.screenPaddingH.w(context),
            vertical: AppDimens.spaceLg.h(context),
          ),
          child: BlocBuilder<AddMaterialBloc, AddMaterialState>(
            builder: (context, state) {
              final bloc = context.read<AddMaterialBloc>();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: () => _pickImage(context),
                      child: Builder(
                        builder: (context) {
                          ImageProvider? imageProvider;

                          if (state.imagePath != null &&
                              state.imagePath!.isNotEmpty) {
                            imageProvider = FileImage(File(state.imagePath!));
                          } else if (materialItem.imageUrl != null &&
                              materialItem.imageUrl!.isNotEmpty) {
                            imageProvider =
                                remoteImageProvider(materialItem.imageUrl);
                          }

                          return Container(
                            width: 120.r(context),
                            height: 120.r(context),
                            decoration: BoxDecoration(
                              color: AppColors.imagePlaceholder,
                              borderRadius: BorderRadius.circular(16),
                              image: imageProvider != null
                                  ? DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: imageProvider == null
                                ? Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 36.r(context),
                                    color: AppColors.textHint,
                                  )
                                : null,
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: AppDimens.spaceLg.h(context)),
                  CustomTextField(
                    initialValue: materialItem.name,
                    label: context.l10n.materialName,
                    icon: Icons.label_outline,
                    onChanged: (v) =>
                        bloc.add(AddMaterialFieldChanged('name', v)),
                    name: false,
                  ),
                  SizedBox(height: AppDimens.spaceSm.h(context)),
                  _CategoryDropdown(
                    // Was passing `materialItem.category` (the NAME,
                    // e.g. "Hair Care Products") into a dropdown whose
                    // item values are numeric ids, so nothing matched
                    // and DropdownButton asserted.
                    value: state.fieldValue('category').isNotEmpty
                        ? state.fieldValue('category')
                        : materialItem.categoryId,
                    currentLabel: materialItem.category,
                    onChanged: (v) =>
                        bloc.add(AddMaterialFieldChanged('category', v)),
                  ),
                  SizedBox(height: AppDimens.spaceSm.h(context)),
                  CustomTextField(
                    initialValue: materialItem.description,
                    name: false,
                    label: context.l10n.description,
                    icon: Icons.notes_outlined,
                    onChanged: (v) =>
                        bloc.add(AddMaterialFieldChanged('description', v)),
                  ),
                  SizedBox(height: AppDimens.spaceSm.h(context)),
                  CustomTextField(
                    initialValue: materialItem.price.toString(),
                    name: false,
                    label: context.l10n.price,
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    onChanged: (v) =>
                        bloc.add(AddMaterialFieldChanged('price', v)),
                  ),
                  SizedBox(height: AppDimens.spaceSm.h(context)),
                  CustomTextField(
                    initialValue: materialItem.peopleNeedingCount.toString(),
                    label: context.l10n.peopleNeeding,
                    icon: Icons.people_outline,
                    keyboardType: TextInputType.number,
                    onChanged: (v) =>
                        bloc.add(AddMaterialFieldChanged('peopleNeeding', v)),
                    name: false,
                  ),
                  SizedBox(height: AppDimens.spaceSm.h(context)),
                  CustomTextField(
                    initialValue: materialItem.sku,
                    label: context.l10n.sku,
                    icon: Icons.qr_code_outlined,
                    onChanged: (v) =>
                        bloc.add(AddMaterialFieldChanged('sku', v)),
                    name: false,
                  ),
                  SizedBox(height: AppDimens.spaceSm.h(context)),
                  CustomTextField(
                    initialValue: materialItem.wholesalePrice.toString(),
                    name: false,
                    label: context.l10n.wholesalePrice,
                    icon: Icons.price_change_outlined,
                    keyboardType: TextInputType.number,
                    onChanged: (v) =>
                        bloc.add(AddMaterialFieldChanged('wholesalePrice', v)),
                  ),
                  SizedBox(height: AppDimens.spaceSm.h(context)),
                  CustomTextField(
                    initialValue: materialItem.quantity.toString(),
                    name: false,
                    label: context.l10n.stockQuantity,
                    icon: Icons.inventory_2_outlined,
                    keyboardType: TextInputType.number,
                    onChanged: (v) =>
                        bloc.add(AddMaterialFieldChanged('stockQuantity', v)),
                  ),
                  SizedBox(height: AppDimens.spaceSm.h(context)),
                  CustomTextField(
                    initialValue: materialItem.min_stock.toString(),
                    label: context.l10n.minimumStockThreshold,
                    icon: Icons.inventory_2_outlined,
                    keyboardType: TextInputType.number,
                    onChanged: (v) =>
                        bloc.add(AddMaterialFieldChanged('min_stock', v)),
                    name: false,
                  ),
                  SizedBox(height: AppDimens.spaceXl.h(context)),
                  PrimaryButton(
                    label: context.l10n.updateMaterial,
                    variant: PrimaryButtonVariant.filled,
                    isLoading: state.status == AddMaterialStatus.loading,
                    onPressed: () {
                      bloc.add( UpdateMaterialSubmitted( id: materialItem.id, materialItem: materialItem));
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  const _CategoryDropdown({
    required this.value,
    required this.onChanged,
    this.currentLabel = '',
  });

  /// The selected category ID.
  final String value;
  final ValueChanged<String> onChanged;

  /// Name of the item's current category as the server reported it.
  /// Needed because the local category list is a fixed guess and does
  /// not necessarily contain every category the backend uses.
  final String currentLabel;

  @override
  Widget build(BuildContext context) {
    final categories = UpdateMaterialPage._repository.getCategories();

    final items = categories
        .map((c) => DropdownMenuItem<String>(
              value: c['id'].toString(),
              child: Text(c['name'].toString()),
            ))
        .toList();

    // The backend's categories come from `service_categories` and are
    // not guaranteed to match this local list. If the item's category
    // is not in it, add it rather than dropping the selection - a
    // DropdownButton whose value has no matching item throws.
    final hasCurrent = items.any((item) => item.value == value);

    if (value.isNotEmpty && !hasCurrent) {
      items.insert(
        0,
        DropdownMenuItem<String>(
          value: value,
          child: Text(currentLabel.isEmpty ? 'Current category' : currentLabel),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppDimens.spaceLg.w(context)),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(AppDimens.inputRadius),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value.isEmpty ? null : value,
          hint: Text(
            context.l10n.category,
            style: AppTextStyles.label.copyWith(fontSize: 14.sp(context)),
          ),
          items: items,
          onChanged: (v) => onChanged(v ?? ''),
        ),
      ),
    );
  }
}
