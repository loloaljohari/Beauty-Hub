import 'package:flutter/material.dart';
import '../../core/localization/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/add_discount/add_discount_bloc.dart';
import '../../blocs/add_discount/add_discount_event.dart';
import '../../blocs/add_discount/add_discount_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

/// Add discount - a full screen (per your correction, NOT a bottom
/// sheet). Lets the expert pick one of their existing services
/// (built in the Basic module / Profile "Services" tab) and apply a
/// percentage discount over a date range.
class AddDiscountPage extends StatelessWidget {
  const AddDiscountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddDiscountBloc()..add(const AddDiscountStarted()),
      child: const _AddDiscountView(),
    );
  }
}

class _AddDiscountView extends StatelessWidget {
  const _AddDiscountView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddDiscountBloc, AddDiscountState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AddDiscountStatus.success) {
          // `true` tells the Offers screen a discount was created so it
          // can refetch instead of showing a stale list.
          Navigator.of(context).pop(true);
        } else if (state.status == AddDiscountStatus.failure &&
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
            context.l10n.addDiscount,
            style: AppTextStyles.h3.copyWith(fontSize: 18.sp(context)),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimens.screenPaddingH.w(context),
            vertical: AppDimens.spaceLg.h(context),
          ),
          child: BlocBuilder<AddDiscountBloc, AddDiscountState>(
            builder: (context, state) {
              final bloc = context.read<AddDiscountBloc>();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.selectAService,
                    style: AppTextStyles.label.copyWith(fontSize: 14.sp(context)),
                  ),
                  SizedBox(height: AppDimens.spaceXs.h(context)),
                  for (final service in state.availableServices)
                    RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      value: service.id,
                      groupValue: state.selectedServiceId,
                      onChanged: (v) =>
                          bloc.add(AddDiscountServiceSelected(v!)),
                      title: Text(service.name),
                      subtitle: Text(service.formattedPrice),
                      activeColor: AppColors.primary,
                    ),
                  SizedBox(height: AppDimens.spaceSm.h(context)),
                  CustomTextField(
                    label: context.l10n.discountPercentage,
                    icon: Icons.percent,
                    keyboardType: TextInputType.number,
                    onChanged: (v) =>
                        bloc.add(AddDiscountPercentageChanged(v)), name: false,
                  ),
                  SizedBox(height: AppDimens.spaceSm.h(context)),
                  // Date pickers rather than free text: the backend
                  // validates both fields with the `date` rule, and a
                  // hand-typed "18/6/2026" is rejected by it.
                  Row(
                    children: [
                      Expanded(
                        child: _DateField(
                          label: context.l10n.startDate,
                          value: state.startDate,
                          firstDate: DateTime.now(),
                          onPicked: (value) =>
                              bloc.add(AddDiscountStartDateChanged(value)),
                        ),
                      ),
                      SizedBox(width: AppDimens.spaceSm.w(context)),
                      Expanded(
                        child: _DateField(
                          label: context.l10n.endDate,
                          value: state.endDate,
                          // Never offer an end date before the start.
                          firstDate: DateTime.tryParse(state.startDate)
                                  ?.add(const Duration(days: 1)) ??
                              DateTime.now(),
                          onPicked: (value) =>
                              bloc.add(AddDiscountEndDateChanged(value)),
                        ),
                      ),
                    ],
                  ),
                  if (state.selectedService != null &&
                      state.percentage.isNotEmpty) ...[
                    SizedBox(height: AppDimens.spaceSm.h(context)),
                    _PricePreview(
                      basicPrice: state.selectedService!.price,
                      percentage:
                          double.tryParse(state.percentage) ?? 0,
                    ),
                  ],
                  SizedBox(height: AppDimens.spaceXl.h(context)),
                  PrimaryButton(
                    label: context.l10n.save,
                    variant: PrimaryButtonVariant.filled,
                    isLoading: state.status == AddDiscountStatus.loading,
                    onPressed: () =>
                        bloc.add(const AddDiscountSubmitted()),
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

/// Tappable field that opens a date picker and reports the value as
/// `YYYY-MM-DD`, which is what Laravel's `date` rule accepts.
class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.firstDate,
    required this.onPicked,
  });

  final String label;
  final String value;
  final DateTime firstDate;
  final ValueChanged<String> onPicked;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final initial = DateTime.tryParse(value) ?? firstDate;

        final picked = await showDatePicker(
          context: context,
          initialDate: initial.isBefore(firstDate) ? firstDate : initial,
          firstDate: firstDate,
          lastDate: DateTime.now().add(const Duration(days: 730)),
        );

        if (picked == null) return;

        final month = picked.month.toString().padLeft(2, '0');
        final day = picked.day.toString().padLeft(2, '0');
        onPicked('${picked.year}-$month-$day');
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(
            Icons.calendar_today_outlined,
            color: AppColors.textHint,
          ),
          filled: true,
          fillColor: AppColors.inputBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.inputRadius),
            borderSide: BorderSide.none,
          ),
        ),
        child: Text(
          value.isEmpty ? 'Select' : value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 14.sp(context),
            color: value.isEmpty ? AppColors.textHint : AppColors.textDark,
          ),
        ),
      ),
    );
  }
}

class _PricePreview extends StatelessWidget {
  const _PricePreview({required this.basicPrice, required this.percentage});

  final double basicPrice;
  final double percentage;

  @override
  Widget build(BuildContext context) {
    final newPrice = basicPrice * (1 - percentage / 100);
    return Container(
      padding: EdgeInsets.all(AppDimens.spaceSm.r(context)),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '\$${basicPrice.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 13.sp(context),
              color: AppColors.priceOld,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          Text(
            '\$${newPrice.toStringAsFixed(2)}',
            style: AppTextStyles.h3.copyWith(
              fontSize: 16.sp(context),
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
