import 'dart:io';
import '../../core/localization/l10n/app_localizations.dart';

import 'package:beautyhup/widgets/feild_ser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../blocs/add_product/add_product_bloc.dart';
import '../../blocs/add_product/add_product_event.dart';
import '../../blocs/add_product/add_product_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../data/repositories/add_product_repository.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

/// Add product form - matches Figma frame "Add product" (948:2660).
class AddProductPage extends StatelessWidget {
  const AddProductPage({super.key, this.productId});

  /// Null creates a new product; set edits an existing one.
  final String? productId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AddProductBloc()..add(AddProductStarted(productId: productId)),
      child: const _AddProductView(),
    );
  }
}

class _AddProductView extends StatelessWidget {
  const _AddProductView();

  static const AddProductRepository _repository = AddProductRepository();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddProductBloc, AddProductState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AddProductStatus.success) {
          Navigator.of(context).pop();
        } else if (state.status == AddProductStatus.failure &&
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
            context.l10n.addProduct,
            style: AppTextStyles.h3.copyWith(fontSize: 18.sp(context)),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimens.screenPaddingH.w(context),
            vertical: AppDimens.spaceLg.h(context),
          ),
          child: BlocBuilder<AddProductBloc, AddProductState>(
            builder: (context, state) {
              final bloc = context.read<AddProductBloc>();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ImagePickerPlaceholder(),
                  SizedBox(height: AppDimens.spaceLg.h(context)),
                  FeildSer(
                    label: context.l10n.productName,
                    icon: Icons.label_outline,
                    onChanged: (v) =>
                        bloc.add(AddProductFieldChanged('name', v)),
                  ),
                  SizedBox(height: AppDimens.spaceSm.h(context)),
                  _CategoryDropdown(
                    value: state.fieldValue('category'),
                    onChanged: (v) =>
                        bloc.add(AddProductFieldChanged('category', v)),
                  ),
                  SizedBox(height: AppDimens.spaceSm.h(context)),
                  FeildSer(
                    label: context.l10n.description,
                    icon: Icons.notes_outlined,
                    onChanged: (v) =>
                        bloc.add(AddProductFieldChanged('bio', v)),
                  ),
                  SizedBox(height: AppDimens.spaceSm.h(context)),
                  FeildSer(
                    label: context.l10n.price,
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    onChanged: (v) =>
                        bloc.add(AddProductFieldChanged('price', v)),
                  ),
                  SizedBox(height: AppDimens.spaceSm.h(context)),
                  FeildSer(
                    label: context.l10n.currentStock,
                    icon: Icons.inventory_2_outlined,
                    keyboardType: TextInputType.number,
                    onChanged: (v) => bloc
                        .add(AddProductFieldChanged('currentStock', v)),
                  ),
                  SizedBox(height: AppDimens.spaceSm.h(context)),
                  FeildSer(
                    label: context.l10n.reorderAt,
                    icon: Icons.warning_amber_outlined,
                    keyboardType: TextInputType.number,
                    onChanged: (v) =>
                        bloc.add(AddProductFieldChanged('reorderAt', v)),
                  ),
                  SizedBox(height: AppDimens.spaceXl.h(context)),
                  PrimaryButton(
                    label: context.l10n.save,
                    variant: PrimaryButtonVariant.filled,
                    isLoading: state.status == AddProductStatus.loading,
                    onPressed: () =>
                        bloc.add(const AddProductSubmitted()),
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

class _ImagePickerPlaceholder extends StatelessWidget {
  const _ImagePickerPlaceholder();

  Future<void> _pickAvatar(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null && context.mounted) {
      context.read<AddProductBloc>().add(AddProductImagePicked(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _pickAvatar(context),
      child: Center(
        child: Container(
          width: 120.r(context),
          height: 120.r(context),
          decoration: BoxDecoration(
            color: AppColors.imagePlaceholder,
            borderRadius: BorderRadius.circular(16),
            image: context.read<AddProductBloc>().state.imagePath != null
                ? DecorationImage(
                    image: FileImage(
                      File(context.read<AddProductBloc>().state.imagePath!),
                    ),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          alignment: Alignment.center,
          child: context.read<AddProductBloc>().state.imagePath != null? SizedBox(): Icon(
            Icons.add_photo_alternate_outlined,
            size: 36.r(context),
            color: AppColors.textHint,
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
    final categories = _AddProductView._repository.getCategories();
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
          items: categories
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (v) => onChanged(v ?? ''),
        ),
      ),
    );
  }
}
