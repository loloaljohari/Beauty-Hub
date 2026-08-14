import 'package:flutter/material.dart';
import '../../core/localization/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/stock_movements/stock_movements_bloc.dart';
import '../../blocs/stock_movements/stock_movements_event.dart';
import '../../blocs/stock_movements/stock_movements_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../data/repositories/material_inventory_repository.dart';
import '../../widgets/bottom_sheet_wrapper.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/stat_badge_row.dart';
import '../../widgets/state_views.dart';

/// Stock ledger for one material.
///
/// New screen for `GET/POST /expert/inventory/{id}/movements`, which
/// had no UI. Before this the only way to change a quantity was the
/// +/- stepper on the inventory card, which never left the device -
/// the backend tracks stock through movement rows, not direct edits.
class StockMovementsPage extends StatelessWidget {
  const StockMovementsPage({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          StockMovementsBloc()..add(StockMovementsLoaded(itemId)),
      child: const _StockMovementsView(),
    );
  }
}

class _StockMovementsView extends StatelessWidget {
  const _StockMovementsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.textPrimary),
        title: Text(
          context.l10n.stockHistory,
          style: AppTextStyles.h3.copyWith(fontSize: 18.sp(context)),
        ),
      ),
      floatingActionButton: BlocBuilder<StockMovementsBloc,
          StockMovementsState>(
        builder: (context, state) {
          if (state.status != StockMovementsStatus.loaded) {
            return const SizedBox.shrink();
          }

          return FloatingActionButton(
          // Unique tag: FABs default to a shared Hero tag, which
          // throws when two screens with one are on screen together.
          heroTag: 'stock_movements_fab',
            backgroundColor: AppColors.primary,
            onPressed: () => _openAddSheet(context),
            child: const Icon(Icons.add, color: AppColors.white),
          );
        },
      ),
      body: BlocConsumer<StockMovementsBloc, StockMovementsState>(
        listenWhen: (previous, current) =>
            previous.actionStatus != current.actionStatus,
        listener: (context, state) {
          if (state.actionStatus == StockMovementActionStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
          if (state.actionStatus == StockMovementActionStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.stockUpdated)),
            );
          }
        },
        builder: (context, state) {
          if (state.status == StockMovementsStatus.loading ||
              state.status == StockMovementsStatus.initial) {
            return const SkeletonList(itemCount: 6, itemHeight: 64);
          }

          if (state.status == StockMovementsStatus.failure) {
            return ErrorState(
              message: state.errorMessage,
              onRetry: () => context
                  .read<StockMovementsBloc>()
                  .add(StockMovementsLoaded(state.itemId)),
            );
          }

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimens.screenPaddingH.w(context),
                  vertical: AppDimens.spaceMd.h(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.item != null) ...[
                      Text(
                        state.item!.name,
                        style: AppTextStyles.h3
                            .copyWith(fontSize: 17.sp(context)),
                      ),
                      SizedBox(height: AppDimens.spaceXs.h(context)),
                    ],
                    StatBadgeRow(
                      badges: [
                        StatBadge(
                          label: context.l10n.inStock,
                          value: '${state.item?.quantity ?? 0}',
                        ),
                        StatBadge(
                          label: context.l10n.minLevel,
                          value: '${state.item?.min_stock.round() ?? 0}',
                          color: AppColors.statusWarning,
                        ),
                        StatBadge(
                          label: context.l10n.movements,
                          value: '${state.movements.length}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: state.isEmpty
                    ? EmptyState(
                        icon: Icons.swap_vert_rounded,
                        title: context.l10n.noMovementsYet,
                        message:
                            context.l10n.recordPurchaseHint??
                            'show up here.',
                      )
                    : ListView.separated(
                        padding: EdgeInsets.only(
                          left: AppDimens.screenPaddingH.w(context),
                          right: AppDimens.screenPaddingH.w(context),
                          bottom: 90.h(context),
                        ),
                        itemCount: state.movements.length,
                        separatorBuilder: (_, __) => Divider(
                          color: AppColors.divider,
                          height: AppDimens.spaceMd.h(context),
                        ),
                        itemBuilder: (context, index) =>
                            _MovementRow(movement: state.movements[index]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openAddSheet(BuildContext context) {
    final bloc = context.read<StockMovementsBloc>();

    BottomSheetWrapper.show(
      context,
      BlocProvider.value(value: bloc, child: const _AddMovementSheet()),
    );
  }
}

class _MovementRow extends StatelessWidget {
  const _MovementRow({required this.movement});

  final StockMovement movement;

  @override
  Widget build(BuildContext context) {
    final color = movement.isAdjustment
        ? AppColors.statusWarning
        : movement.isIncoming
            ? AppColors.statusSuccess
            : AppColors.statusDanger;

    final sign = movement.isAdjustment
        ? '='
        : movement.isIncoming
            ? '+'
            : '-';

    return Row(
      children: [
        Container(
          width: 38.r(context),
          height: 38.r(context),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            movement.isAdjustment
                ? Icons.tune
                : movement.isIncoming
                    ? Icons.arrow_downward
                    : Icons.arrow_upward,
            size: 18.r(context),
            color: color,
          ),
        ),
        SizedBox(width: AppDimens.spaceSm.w(context)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _reasonLabel(movement.reason),
                style: AppTextStyles.bodyMediumBold
                    .copyWith(fontSize: 15.sp(context)),
              ),
              Text(
                movement.notes.isNotEmpty
                    ? movement.notes
                    : movement.createdAt,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12.sp(context),
                  color: AppColors.textBody,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Text(
          '$sign${_trim(movement.quantity)}',
          style: AppTextStyles.bodyMediumBold.copyWith(
            fontSize: 15.sp(context),
            color: color,
          ),
        ),
      ],
    );
  }
}

/// The backend's `reason` enum, spelled out for humans.
String _reasonLabel(String reason) {
  switch (reason) {
    case 'purchase':
      return 'Purchase';
    case 'sale':
      return 'Sale';
    case 'booking_used':
      return 'Used in a booking';
    case 'return':
      return 'Return';
    case 'adjustment':
      return 'Stock count adjustment';
    case 'expired':
      return 'Expired';
    default:
      return reason;
  }
}

String _trim(double value) {
  return value == value.roundToDouble()
      ? value.round().toString()
      : value.toStringAsFixed(2);
}

class _AddMovementSheet extends StatefulWidget {
  const _AddMovementSheet();

  @override
  State<_AddMovementSheet> createState() => _AddMovementSheetState();
}

class _AddMovementSheetState extends State<_AddMovementSheet> {
  final TextEditingController _quantity = TextEditingController();
  final TextEditingController _notes = TextEditingController();

  String _type = 'in';
  String _reason = 'purchase';
  String? _error;

  /// Only the reason values the backend accepts for each direction -
  /// sending `booking_used` with an `in` movement would pass validation
  /// but make no sense in the ledger.
  static const Map<String, List<String>> _reasonsFor = {
    'in': ['purchase', 'return'],
    'out': ['booking_used', 'sale', 'expired'],
    'adjustment': ['adjustment'],
  };

  @override
  void dispose() {
    _quantity.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _selectType(String type) {
    setState(() {
      _type = type;
      _reason = _reasonsFor[type]!.first;
    });
  }

  void _submit() {
    final value = double.tryParse(_quantity.text.trim());

    if (value == null || value < 0) {
      setState(() => _error = 'Enter a valid quantity.');
      return;
    }

    setState(() => _error = null);

    context.read<StockMovementsBloc>().add(
          StockMovementSubmitted(
            movementType: _type,
            reason: _reason,
            quantity: value,
            notes: _notes.text.trim(),
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.recordStockMovement,
              style: AppTextStyles.h3.copyWith(fontSize: 18.sp(context)),
            ),
            SizedBox(height: AppDimens.spaceMd.h(context)),
            Row(
              children: [
                for (final type in _reasonsFor.keys) ...[
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectType(type),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: AppDimens.spaceXs.h(context),
                        ),
                        decoration: BoxDecoration(
                          color: _type == type
                              ? AppColors.primary
                              : AppColors.inputBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _typeLabel(type),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 13.sp(context),
                            color: _type == type
                                ? AppColors.white
                                : AppColors.textBody,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (type != _reasonsFor.keys.last)
                    SizedBox(width: AppDimens.spaceXs.w(context)),
                ],
              ],
            ),
            SizedBox(height: AppDimens.spaceMd.h(context)),
            Text(
              context.l10n.reason,
              style: AppTextStyles.label.copyWith(fontSize: 14.sp(context)),
            ),
            SizedBox(height: AppDimens.spaceXxs.h(context)),
            Wrap(
              spacing: AppDimens.spaceXs.w(context),
              children: [
                for (final reason in _reasonsFor[_type]!)
                  ChoiceChip(
                    label: Text(_reasonLabel(reason)),
                    selected: _reason == reason,
                    selectedColor: AppColors.planPillBackground,
                    onSelected: (_) => setState(() => _reason = reason),
                  ),
              ],
            ),
            SizedBox(height: AppDimens.spaceMd.h(context)),
            TextField(
              controller: _quantity,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: context.l10n.quantity,
                // This distinction is load-bearing: for an adjustment
                // the backend stores the value as the new balance, not
                // as a difference.
                helperText: _type == 'adjustment'
                    ? 'The new total after your stock count'
                    : 'How much to ${_type == 'in' ? 'add' : 'deduct'}',
                errorText: _error,
                filled: true,
                fillColor: AppColors.inputBackground,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimens.inputRadius),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: AppDimens.spaceSm.h(context)),
            TextField(
              controller: _notes,
              maxLength: 500,
              decoration: InputDecoration(
                labelText: context.l10n.notesOptional,
                filled: true,
                fillColor: AppColors.inputBackground,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimens.inputRadius),
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
      ),
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'in':
        return 'Add stock';
      case 'out':
        return 'Deduct';
      default:
        return 'Adjust';
    }
  }
}
