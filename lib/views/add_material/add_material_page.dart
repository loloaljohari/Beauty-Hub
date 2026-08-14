import 'dart:io';
import '../../core/localization/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../blocs/add_material/add_material_bloc.dart';
import '../../blocs/add_material/add_material_event.dart';
import '../../blocs/add_material/add_material_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../data/repositories/material_inventory_repository.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

/// Add Material form - matches Figma frame "Add Material" (1072:6208).
class AddMaterialPage extends StatelessWidget {
  const AddMaterialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => MaterialInventoryRepository(),
      child: BlocProvider(
        create: (context) => AddMaterialBloc(
          context.read<MaterialInventoryRepository>(),
        ),
        child: _AddMaterialView(),
      ),
    );
  }
}

class _AddMaterialView extends StatelessWidget {
  const _AddMaterialView();

  static const MaterialInventoryRepository _repository =
      MaterialInventoryRepository();

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null && context.mounted) {
      context.read<AddMaterialBloc>().add(AddMaterialImagePicked(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddMaterialBloc, AddMaterialState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AddMaterialStatus.success) {
          Navigator.of(context).pop();
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
            context.l10n.addMaterial,
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
                      child: Container(
                        width: 120.r(context),
                        height: 120.r(context),
                        decoration: BoxDecoration(
                          color: AppColors.imagePlaceholder,
                          borderRadius: BorderRadius.circular(16),
                          image: state.imagePath != null
                              ? DecorationImage(
                                  image: FileImage(File(state.imagePath!)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: state.imagePath == null
                            ? Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 36.r(context),
                                color: AppColors.textHint,
                              )
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(height: AppDimens.spaceLg.h(context)),
                  CustomTextField(
                    label: context.l10n.materialName,
                    icon: Icons.label_outline,
                    onChanged: (v) =>
                        bloc.add(AddMaterialFieldChanged('name', v)),
                    name: false,
                  ),
                  SizedBox(height: AppDimens.spaceSm.h(context)),
                  _CategoryDropdown(
                    value: state.fieldValue('category'),
                    onChanged: (v) =>
                        bloc.add(AddMaterialFieldChanged('category', v)),
                  ),
                  SizedBox(height: AppDimens.spaceSm.h(context)),
                  CustomTextField(
                    name: false,
                    label: context.l10n.description,
                    icon: Icons.notes_outlined,
                    onChanged: (v) =>
                        bloc.add(AddMaterialFieldChanged('description', v)),
                  ),
                  SizedBox(height: AppDimens.spaceSm.h(context)),
                  CustomTextField(
                    name: false,
                    label: context.l10n.price,
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    onChanged: (v) =>
                        bloc.add(AddMaterialFieldChanged('price', v)),
                  ),
                  SizedBox(height: AppDimens.spaceSm.h(context)),
                  CustomTextField(
                    label: context.l10n.peopleNeeding,
                    icon: Icons.people_outline,
                    keyboardType: TextInputType.number,
                    onChanged: (v) =>
                        bloc.add(AddMaterialFieldChanged('peopleNeeding', v)),
                    name: false,
                  ),
                  SizedBox(height: AppDimens.spaceSm.h(context)),
                  CustomTextField(
                    label: context.l10n.sku,
                    icon: Icons.qr_code_outlined,
                    onChanged: (v) =>
                        bloc.add(AddMaterialFieldChanged('sku', v)),
                    name: false,
                  ),
                  SizedBox(height: AppDimens.spaceSm.h(context)),
                  CustomTextField(
                    name: false,
                    label: context.l10n.wholesalePrice,
                    icon: Icons.price_change_outlined,
                    keyboardType: TextInputType.number,
                    onChanged: (v) =>
                        bloc.add(AddMaterialFieldChanged('wholesalePrice', v)),
                  ),
                  SizedBox(height: AppDimens.spaceSm.h(context)),
                  CustomTextField(
                    
                    name: false,
                    label: context.l10n.stockQuantity,
                    icon: Icons.inventory_2_outlined,
                    keyboardType: TextInputType.number,
                    onChanged: (v) =>
                        bloc.add(AddMaterialFieldChanged('stockQuantity', v)),
                  ),
                  SizedBox(height: AppDimens.spaceSm.h(context)),
                  CustomTextField(
                    label: context.l10n.minimumStockThreshold,
                    icon: Icons.inventory_2_outlined,
                    keyboardType: TextInputType.number,
                    onChanged: (v) =>
                        bloc.add(AddMaterialFieldChanged('min_stock', v)),
                    name: false,
                  ),
                  SizedBox(height: AppDimens.spaceXl.h(context)),
                  PrimaryButton(
                    label: context.l10n.save,
                    variant: PrimaryButtonVariant.filled,
                    isLoading: state.status == AddMaterialStatus.loading,
                    onPressed: () => bloc.add(const AddMaterialSubmitted()),
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
  const _CategoryDropdown({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final categories = _AddMaterialView._repository.getCategories();

    // Guard against a selected id that is not in the current list -
    // possible if the categories refresh from the server after the
    // user already picked one from the fallback list.
    final hasValue =
        categories.any((c) => c['id'].toString() == value);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppDimens.spaceLg.w(context)),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(AppDimens.inputRadius),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: (value.isEmpty || !hasValue) ? null : value,
          hint: Text(
            context.l10n.category,
            style: AppTextStyles.label.copyWith(fontSize: 14.sp(context)),
          ),
          items: categories
              .map((c) => DropdownMenuItem<String>(
                    value: c['id'].toString(),
                    child: Text(c['name'].toString()),
                  ))
              .toList(),
          onChanged: (v) => onChanged(v ?? ''),
        ),
      ),
    );
  }
}
