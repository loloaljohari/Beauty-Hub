import 'package:flutter/material.dart';
import '../../core/localization/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/add_offer/add_offer_bloc.dart';
import '../../blocs/add_offer/add_offer_event.dart';
import '../../blocs/add_offer/add_offer_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/offer_models.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

/// Add offer - full screen. Lets the expert pick one of their
/// existing store products (built in the Basic module / My Store)
/// and configure an offer type + description + date range.
class AddOfferPage extends StatelessWidget {
  const AddOfferPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddOfferBloc()..add(const AddOfferStarted()),
      child: const _AddOfferView(),
    );
  }
}

class _AddOfferView extends StatelessWidget {
  const _AddOfferView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddOfferBloc, AddOfferState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AddOfferStatus.success) {
          Navigator.of(context).pop();
        } else if (state.status == AddOfferStatus.failure &&
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
            context.l10n.addOffer,
            style: AppTextStyles.h3.copyWith(fontSize: 18.sp(context)),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimens.screenPaddingH.w(context),
            vertical: AppDimens.spaceLg.h(context),
          ),
          child: BlocBuilder<AddOfferBloc, AddOfferState>(
            builder: (context, state) {
              final bloc = context.read<AddOfferBloc>();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.addProductFromStore,
                    style: AppTextStyles.label.copyWith(fontSize: 14.sp(context)),
                  ),
                  SizedBox(height: AppDimens.spaceXs.h(context)),
                  for (final product in state.availableProducts)
                    RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      value: product.id,
                      groupValue: state.selectedProductId,
                      onChanged: (v) =>
                          bloc.add(AddOfferProductSelected(v!)),
                      title: Text(product.name),
                      subtitle: Text(product.formattedPrice),
                      activeColor: AppColors.primary,
                    ),
                  SizedBox(height: AppDimens.spaceSm.h(context)),
                  Text(
                    context.l10n.offerType,
                    style: AppTextStyles.label.copyWith(fontSize: 14.sp(context)),
                  ),
                  Wrap(
                    spacing: AppDimens.spaceXs.w(context),
                    children: [
                      for (final type in OfferType.values)
                        ChoiceChip(
                          label: Text(_typeLabel(type)),
                          selected: state.type == type,
                          onSelected: (_) =>
                              bloc.add(AddOfferTypeChanged(type.name)),
                        ),
                    ],
                  ),
                  SizedBox(height: AppDimens.spaceSm.h(context)),
                  CustomTextField(
                    label: context.l10n.offerDescriptionHint,
                    icon: Icons.notes_outlined,
                    onChanged: (v) =>
                        bloc.add(AddOfferDescriptionChanged(v)),
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
                              bloc.add(AddOfferStartDateChanged(v)),
                          name: false,
                        ),
                      ),
                      SizedBox(width: AppDimens.spaceSm.w(context)),
                      Expanded(
                        child: CustomTextField(
                          label: context.l10n.endDate,
                          icon: Icons.calendar_today_outlined,
                          onChanged: (v) =>
                              bloc.add(AddOfferEndDateChanged(v)),
                          name: false,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppDimens.spaceXl.h(context)),
                  PrimaryButton(
                    label: context.l10n.save,
                    variant: PrimaryButtonVariant.filled,
                    isLoading: state.status == AddOfferStatus.loading,
                    onPressed: () => bloc.add(const AddOfferSubmitted()),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _typeLabel(OfferType type) {
    switch (type) {
      case OfferType.discountOnPrice:
        return 'Discount on price';
      case OfferType.buyXGetY:
        return 'Buy X get Y';
      case OfferType.privatePrice:
        return 'Private price';
    }
  }
}
