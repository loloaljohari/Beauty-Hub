import 'package:flutter/material.dart';
import '../../core/localization/l10n/app_localizations.dart';
import '../../widgets/state_views.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/material_inventory/material_inventory_bloc.dart';
import '../../blocs/material_inventory/material_inventory_event.dart';
import '../../blocs/material_inventory/material_inventory_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/route_names.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/material_card.dart';
import '../../widgets/stat_badge_row.dart';
import '../update _material/update_material.dart';

/// Material Inventory screen - matches Figma frame "Material
/// Inventory" (1067:xxxx): the expert's own salon supplies.
class MaterialInventoryPage extends StatelessWidget {
  const MaterialInventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          MaterialInventoryBloc()..add(const MaterialInventoryLoaded()),
      child: const _MaterialInventoryView(),
    );
  }
}

class _MaterialInventoryView extends StatelessWidget {
  const _MaterialInventoryView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          context.l10n.materialInventory,
          style: AppTextStyles.h3.copyWith(fontSize: 18.sp(context)),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notification_important_outlined,
                color: AppColors.textPrimary, size: 22.r(context)),
            tooltip: 'Stock alerts',
            onPressed: () =>
                Navigator.of(context).pushNamed(RouteNames.inventoryAlerts),
          ),
          IconButton(
            icon: Icon(Icons.inventory_outlined,
                color: AppColors.textPrimary, size: 22.r(context)),
            tooltip: 'Archived',
            onPressed: () async {
          final updated =
              await Navigator.of(context).pushNamed(RouteNames.archivedMaterials);
          if (context.mounted || updated == true) {
            context
                .read<MaterialInventoryBloc>()
                .add(const MaterialInventoryLoaded());
          }
        },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          // Unique tag: FABs default to a shared Hero tag, which
          // throws when two screens with one are on screen together.
          heroTag: 'inventory_add_fab',
        backgroundColor: AppColors.primary,
        onPressed: () async {
          final updated =
              await Navigator.of(context).pushNamed(RouteNames.addMaterial);
          if (context.mounted || updated == true) {
            context
                .read<MaterialInventoryBloc>()
                .add(const MaterialInventoryLoaded());
          }
        },
        child: const Icon(Icons.add, color: AppColors.white),
      ),
      body: BlocBuilder<MaterialInventoryBloc, MaterialInventoryState>(
        builder: (context, state) {
          if (state.status == MaterialInventoryStatus.loading ||
              state.status == MaterialInventoryStatus.initial) {
            return const SkeletonList(itemCount: 5, itemHeight: 110);
          }

          if (state.status == MaterialInventoryStatus.failure) {
            return ErrorState(
              message: state.errorMessage,
              onRetry: () => context
                  .read<MaterialInventoryBloc>()
                  .add(const MaterialInventoryLoaded()),
            );
          }

          final bloc = context.read<MaterialInventoryBloc>();

          return ListView(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimens.screenPaddingH.w(context),
              vertical: AppDimens.spaceMd.h(context),
            ),
            children: [
              StatBadgeRow(
                badges: [
                  StatBadge(label: context.l10n.items, value: '${state.itemsCount}'),
                  StatBadge(
                    label: context.l10n.expiring,
                    value: '${state.expiringSoonCount}',
                    color: AppColors.statusWarning,
                  ),
                  StatBadge(
                    label: context.l10n.outOfStock,
                    value: '${state.outOfStockCount}',
                    color: AppColors.statusDanger,
                  ),
                ],
              ),
              SizedBox(height: AppDimens.spaceMd.h(context)),
              for (final material in state.materials)
                InkWell(
                  onTap: () async {
                    final updated = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            UpdateMaterial(materialItem: material),
                      ),
                    );
                    if (context.mounted && updated == true) {
                      bloc.add(const MaterialInventoryLoaded());
                    }
                  },
                  // Long-press opens the stock ledger. Tap still edits
                  // the item, so no existing gesture changes meaning.
                  onLongPress: () async {
                    await Navigator.of(context).pushNamed(
                      RouteNames.stockMovements,
                      arguments: material.id,
                    );
                    if (context.mounted) {
                      bloc.add(const MaterialInventoryLoaded());
                    }
                  },
                  child: MaterialCard(
                    material: material,
                    onIncrement: () =>
                        bloc.add(MaterialQuantityChanged(material.id, 1)),
                    onDecrement: () =>
                        bloc.add(MaterialQuantityChanged(material.id, -1)),
                    onDelete: () => bloc.add(MaterialDeleted(material.id)),
                  ),
                ),
           SizedBox(height: 50.h(context)),
            ],
            
          );
        },
      ),
    );
  }
}
