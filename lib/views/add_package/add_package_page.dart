import 'package:flutter/material.dart';
import '../../core/localization/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/add_package/add_package_bloc.dart';
import '../../blocs/add_package/add_package_event.dart';
import '../../blocs/add_package/add_package_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

/// Add Package - full screen. Lets the expert bundle multiple
/// existing products AND services (both built previously) into a
/// single discounted package.
class AddPackagePage extends StatelessWidget {
  const AddPackagePage({super.key, this.packageId});

  /// Null creates a bundle; set edits an existing one.
  final String? packageId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AddPackageBloc()..add(AddPackageStarted(packageId: packageId)),
      child: const _AddPackageView(),
    );
  }
}

class _AddPackageView extends StatelessWidget {
  const _AddPackageView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddPackageBloc, AddPackageState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AddPackageStatus.success) {
          Navigator.of(context).pop(true);
        } else if (state.status == AddPackageStatus.failure &&
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
            context.l10n.addPackage,
            style: AppTextStyles.h3.copyWith(fontSize: 18.sp(context)),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimens.screenPaddingH.w(context),
            vertical: AppDimens.spaceLg.h(context),
          ),
          child: BlocBuilder<AddPackageBloc, AddPackageState>(
            builder: (context, state) {
              final bloc = context.read<AddPackageBloc>();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    label: context.l10n.packageName,
                    icon: Icons.label_outline,
                    onChanged: (v) =>
                        bloc.add(AddPackageNameChanged(v)),
                    name: false,
                  ),
                  SizedBox(height: AppDimens.spaceSm.h(context)),
                  CustomTextField(
                    label: context.l10n.bio,
                    icon: Icons.notes_outlined,
                    onChanged: (v) => bloc.add(AddPackageBioChanged(v)),
                    name: false,
                  ),
                  SizedBox(height: AppDimens.spaceMd.h(context)),
                  Text(
                    context.l10n.addProductOrService,
                    style: AppTextStyles.label.copyWith(fontSize: 14.sp(context)),
                  ),
                  SizedBox(height: AppDimens.spaceXs.h(context)),
                  if (state.availableProducts.isNotEmpty) ...[
                    Text(
                      context.l10n.products,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12.sp(context),
                        color: AppColors.textSecondaryGrey,
                      ),
                    ),
                    for (final product in state.availableProducts)
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        // Keyed by type:id - a service and a product can
                        // share a number, and a bare id would tick both.
                        value: state.selectedItemIds
                            .contains('product:${product.id}'),
                        onChanged: (_) =>
                            bloc.add(
                          AddPackageItemToggled('product:${product.id}'),
                        ),
                        title: Text(product.name),
                        subtitle: Text(product.formattedPrice),
                        activeColor: AppColors.primary,
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                  ],
                  if (state.availableServices.isNotEmpty) ...[
                    SizedBox(height: AppDimens.spaceXs.h(context)),
                    Text(
                      context.l10n.services,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12.sp(context),
                        color: AppColors.textSecondaryGrey,
                      ),
                    ),
                    for (final service in state.availableServices)
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: state.selectedItemIds
                            .contains('service:${service.id}'),
                        onChanged: (_) =>
                            bloc.add(
                          AddPackageItemToggled('service:${service.id}'),
                        ),
                        title: Text(service.name),
                        subtitle: Text(service.formattedPrice),
                        activeColor: AppColors.primary,
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                  ],
                  SizedBox(height: AppDimens.spaceSm.h(context)),
                  CustomTextField(
                    label: context.l10n.totalPrice,
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    onChanged: (v) =>
                        bloc.add(AddPackagePriceChanged(v)),
                    name: false,
                  ),
                  SizedBox(height: AppDimens.spaceSm.h(context)),
                  CustomTextField(
                    label: context.l10n.discountPercentage,
                    icon: Icons.percent,
                    keyboardType: TextInputType.number,
                    onChanged: (v) =>
                        bloc.add(AddPackageDiscountChanged(v)),
                    name: false,
                  ),
                  SizedBox(height: AppDimens.spaceSm.h(context)),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: context.l10n.startDate,
                          icon: Icons.calendar_today_outlined,
                          onChanged: (v) =>
                              bloc.add(AddPackageStartDateChanged(v)),
                          name: false,
                        ),
                      ),
                      SizedBox(width: AppDimens.spaceSm.w(context)),
                      Expanded(
                        child: CustomTextField(
                          label: context.l10n.endDate,
                          icon: Icons.calendar_today_outlined,
                          onChanged: (v) =>
                              bloc.add(AddPackageEndDateChanged(v)),
                          name: false,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppDimens.spaceXl.h(context)),
                  PrimaryButton(
                    label: context.l10n.save,
                    variant: PrimaryButtonVariant.filled,
                    isLoading: state.status == AddPackageStatus.loading,
                    onPressed: () =>
                        bloc.add(const AddPackageSubmitted()),
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
