import 'package:flutter/material.dart';
import '../../core/localization/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/service_materials/service_materials_bloc.dart';
import '../../blocs/service_materials/service_materials_event.dart';
import '../../blocs/service_materials/service_materials_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/material_item_model.dart';
import '../../data/repositories/add_service_repository.dart';
import '../../widgets/bottom_sheet_wrapper.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/state_views.dart';

/// Links a service to the materials one session of it consumes.
///
/// New screen for `GET/POST /expert/services/{id}/materials`. This is
/// the missing piece that makes the smart alert work at all: without
/// these links the backend cannot know what tomorrow's bookings will
/// use, so `inventory/smart-alert` returns an empty list no matter how
/// many bookings exist.
class ServiceMaterialsPage extends StatelessWidget {
  const ServiceMaterialsPage({super.key, required this.serviceId});

  final String serviceId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ServiceMaterialsBloc()..add(ServiceMaterialsLoaded(serviceId)),
      child: const _ServiceMaterialsView(),
    );
  }
}

class _ServiceMaterialsView extends StatelessWidget {
  const _ServiceMaterialsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.textPrimary),
        title: BlocBuilder<ServiceMaterialsBloc, ServiceMaterialsState>(
          builder: (context, state) => Text(
            state.serviceName.isEmpty ? 'Materials' : state.serviceName,
            style: AppTextStyles.h3.copyWith(fontSize: 18.sp(context)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      floatingActionButton:
          BlocBuilder<ServiceMaterialsBloc, ServiceMaterialsState>(
        builder: (context, state) {
          if (state.status != ServiceMaterialsStatus.loaded) {
            return const SizedBox.shrink();
          }

          return FloatingActionButton(
          // Unique tag: FABs default to a shared Hero tag, which
          // throws when two screens with one are on screen together.
          heroTag: 'service_materials_fab',
            backgroundColor: AppColors.primary,
            onPressed: state.availableToAdd.isEmpty
                ? null
                : () => _openPicker(context),
            child: const Icon(Icons.add, color: AppColors.white),
          );
        },
      ),
      body: BlocConsumer<ServiceMaterialsBloc, ServiceMaterialsState>(
        listenWhen: (previous, current) =>
            previous.actionStatus != current.actionStatus,
        listener: (context, state) {
          if (state.actionStatus == ServiceMaterialsActionStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          final bloc = context.read<ServiceMaterialsBloc>();

          if (state.status == ServiceMaterialsStatus.loading ||
              state.status == ServiceMaterialsStatus.initial) {
            return const SkeletonList(itemCount: 4, itemHeight: 76);
          }

          if (state.status == ServiceMaterialsStatus.failure) {
            return ErrorState(
              message: state.errorMessage,
              onRetry: () =>
                  bloc.add(ServiceMaterialsLoaded(state.serviceId)),
            );
          }

          if (state.isEmpty) {
            return EmptyState(
              icon: Icons.link_off,
              title: context.l10n.noMaterialsLinked,
              message: state.inventory.isEmpty
                  ? 'Add items to your inventory first, then link them to '
                      'this service.'
                  : 'Link the materials this service uses so the app can '
                      'warn you before you run out.',
              actionLabel:
                  state.inventory.isEmpty ? null : 'Link a material',
              onAction: state.inventory.isEmpty
                  ? null
                  : () => _openPicker(context),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.only(
              left: AppDimens.screenPaddingH.w(context),
              right: AppDimens.screenPaddingH.w(context),
              top: AppDimens.spaceMd.h(context),
              bottom: 90.h(context),
            ),
            itemCount: state.materials.length,
            separatorBuilder: (_, __) => Divider(
              color: AppColors.divider,
              height: AppDimens.spaceMd.h(context),
            ),
            itemBuilder: (context, index) {
              final material = state.materials[index];

              return _MaterialRow(
                material: material,
                onEdit: () => _openQuantitySheet(
                  context,
                  productId: material.productId,
                  productName: material.productName,
                  initialQuantity: material.quantityPerSession,
                  initialUnit: material.unit,
                ),
                onRemove: () =>
                    bloc.add(ServiceMaterialRemoved(material.productId)),
              );
            },
          );
        },
      ),
    );
  }

  void _openPicker(BuildContext context) {
    final bloc = context.read<ServiceMaterialsBloc>();

    BottomSheetWrapper.show(
      context,
      BlocProvider.value(
        value: bloc,
        child: const _InventoryPickerSheet(),
      ),
    );
  }
}

void _openQuantitySheet(
  BuildContext context, {
  required String productId,
  required String productName,
  double initialQuantity = 1,
  String initialUnit = '',
}) {
  final bloc = context.read<ServiceMaterialsBloc>();

  BottomSheetWrapper.show(
    context,
    BlocProvider.value(
      value: bloc,
      child: _QuantitySheet(
        productId: productId,
        productName: productName,
        initialQuantity: initialQuantity,
        initialUnit: initialUnit,
      ),
    ),
  );
}

class _MaterialRow extends StatelessWidget {
  const _MaterialRow({
    required this.material,
    required this.onEdit,
    required this.onRemove,
  });

  final ServiceMaterial material;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    // `covers_sessions` is computed server-side from current stock; it
    // is the number that actually matters to the expert.
    final runningLow = material.coversSessions <= 3;

    return InkWell(
      onTap: onEdit,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppDimens.spaceXxs.h(context)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    material.productName,
                    style: AppTextStyles.bodyMediumBold
                        .copyWith(fontSize: 15.sp(context)),
                  ),
                  SizedBox(height: 2.h(context)),
                  Text(
                    '${_trim(material.quantityPerSession)}'
                    '${material.unit.isEmpty ? '' : ' ${material.unit}'}'
                    ' per session',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12.sp(context),
                      color: AppColors.textBody,
                    ),
                  ),
                  Text(
                    'Covers ${material.coversSessions} more session(s)',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12.sp(context),
                      color: runningLow
                          ? AppColors.statusDanger
                          : AppColors.statusSuccess,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(
                Icons.link_off,
                color: AppColors.textHint,
              ),
              tooltip: 'Unlink',
            ),
          ],
        ),
      ),
    );
  }
}

class _InventoryPickerSheet extends StatelessWidget {
  const _InventoryPickerSheet();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServiceMaterialsBloc, ServiceMaterialsState>(
      builder: (context, state) {
        final available = state.availableToAdd;

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimens.screenPaddingH.w(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.pickAMaterial,
                style: AppTextStyles.h3.copyWith(fontSize: 18.sp(context)),
              ),
              SizedBox(height: AppDimens.spaceSm.h(context)),
              if (available.isEmpty)
                Padding(
                  padding: EdgeInsets.all(AppDimens.spaceLg.h(context)),
                  child: Text(
                    context.l10n.everyItemLinked??
                    'this service.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14.sp(context),
                      color: AppColors.textBody,
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: available.length,
                    itemBuilder: (context, index) {
                      final MaterialItemModel item = available[index];

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          item.name,
                          style: AppTextStyles.bodyMedium
                              .copyWith(fontSize: 15.sp(context)),
                        ),
                        subtitle: Text(
                          '${item.quantity} in stock',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 12.sp(context),
                            color: AppColors.textBody,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: AppColors.textHint,
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          _openQuantitySheet(
                            context,
                            productId: item.id,
                            productName: item.name,
                          );
                        },
                      );
                    },
                  ),
                ),
              SizedBox(height: AppDimens.spaceLg.h(context)),
            ],
          ),
        );
      },
    );
  }
}

class _QuantitySheet extends StatefulWidget {
  const _QuantitySheet({
    required this.productId,
    required this.productName,
    this.initialQuantity = 1,
    this.initialUnit = '',
  });

  final String productId;
  final String productName;
  final double initialQuantity;
  final String initialUnit;

  @override
  State<_QuantitySheet> createState() => _QuantitySheetState();
}

class _QuantitySheetState extends State<_QuantitySheet> {
  late final TextEditingController _quantity;
  late final TextEditingController _unit;
  String? _error;

  @override
  void initState() {
    super.initState();
    _quantity = TextEditingController(
      text: _trim(widget.initialQuantity),
    );
    _unit = TextEditingController(text: widget.initialUnit);
  }

  @override
  void dispose() {
    _quantity.dispose();
    _unit.dispose();
    super.dispose();
  }

  void _submit() {
    final value = double.tryParse(_quantity.text.trim());

    // The backend validates `gt:0`, so zero is rejected server-side.
    // Catching it here gives a clearer message than a 422 would.
    if (value == null || value <= 0) {
      setState(() => _error = 'Enter an amount greater than zero.');
      return;
    }

    context.read<ServiceMaterialsBloc>().add(
          ServiceMaterialUpserted(
            productId: widget.productId,
            quantityPerSession: value,
            unit: _unit.text.trim(),
          ),
        );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppDimens.screenPaddingH.w(context),
        right: AppDimens.screenPaddingH.w(context),
        bottom: MediaQuery.of(context).viewInsets.bottom +
            AppDimens.spaceLg.h(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.productName,
            style: AppTextStyles.h3.copyWith(fontSize: 18.sp(context)),
          ),
          SizedBox(height: AppDimens.spaceXs.h(context)),
          Text(
            context.l10n.howMuchPerSession,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 13.sp(context),
              color: AppColors.textBody,
            ),
          ),
          SizedBox(height: AppDimens.spaceMd.h(context)),
          TextField(
            controller: _quantity,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: context.l10n.quantityPerSession,
              errorText: _error,
              filled: true,
              fillColor: AppColors.inputBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimens.inputRadius),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: AppDimens.spaceSm.h(context)),
          TextField(
            controller: _unit,
            maxLength: 20,
            decoration: InputDecoration(
              labelText: context.l10n.unitOptional,
              hintText: context.l10n.unitHint,
              filled: true,
              fillColor: AppColors.inputBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimens.inputRadius),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: AppDimens.spaceMd.h(context)),
          PrimaryButton(
            label: context.l10n.save,
            variant: PrimaryButtonVariant.filled,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

String _trim(double value) {
  return value == value.roundToDouble()
      ? value.round().toString()
      : value.toStringAsFixed(2);
}
