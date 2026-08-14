import 'package:flutter/material.dart';
import '../../core/localization/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/archived_materials/archived_materials_bloc.dart';
import '../../blocs/archived_materials/archived_materials_event.dart';
import '../../blocs/archived_materials/archived_materials_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';

class ArchivedMaterialsPage extends StatelessWidget {
  const ArchivedMaterialsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ArchivedMaterialsBloc()..add(const ArchivedMaterialsLoaded()),
      child: const _ArchivedMaterialsView(),
    );
  }
}

class _ArchivedMaterialsView extends StatelessWidget {
  const _ArchivedMaterialsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          context.l10n.archivedMaterials,
          style: AppTextStyles.h3.copyWith(fontSize: 18.sp(context)),
        ),
      ),
      body: BlocConsumer<ArchivedMaterialsBloc, ArchivedMaterialsState>(
        listenWhen: (prev, curr) => curr.errorMessage != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        },
        builder: (context, state) {
          if (state.status == ArchivedMaterialsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.materials.isEmpty) {
            return Center(
              child: Text(
                context.l10n.noArchivedMaterials,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondaryGrey),
              ),
            );
          }
          return ListView.separated(
            padding: EdgeInsets.all(AppDimens.screenPaddingH.w(context)),
            itemCount: state.materials.length,
            separatorBuilder: (_, __) =>
                SizedBox(height: AppDimens.spaceSm.h(context)),
            itemBuilder: (context, index) {
              final material = state.materials[index];
              final isRestoring = state.restoringId == material.id;

              return Container(
                padding: EdgeInsets.all(AppDimens.spaceSm.r(context)),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(
                      AppDimens.productCardRadius.r(context)),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52.r(context),
                      height: 52.r(context),
                      decoration: BoxDecoration(
                        color: AppColors.imagePlaceholder,
                        borderRadius: BorderRadius.circular(10),
                        image: material.imageUrl != null
                            ? DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                    '${material.imageUrl}'),
                              )
                            : null,
                      ),
                      child: material.imageUrl != null
                          ? null
                          : Icon(Icons.science_outlined,
                              size: 22.r(context), color: AppColors.textHint),
                    ),
                    SizedBox(width: AppDimens.spaceSm.w(context)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            material.name,
                            style: AppTextStyles.label
                                .copyWith(fontSize: 14.sp(context)),
                          ),
                          Text(
                            'SKU: ${material.sku}  •  Qty: ${material.quantity}',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 11.sp(context),
                              color: AppColors.textSecondaryGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    isRestoring
                        ? SizedBox(
                            width: 20.r(context),
                            height: 20.r(context),
                            child: const CircularProgressIndicator(
                                strokeWidth: 2),
                          )
                        : TextButton(
                            onPressed: () => context
                                .read<ArchivedMaterialsBloc>()
                                .add(ArchivedMaterialRestored(material.id)),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.statusSuccess,
                              padding: EdgeInsets.symmetric(
                                  horizontal: AppDimens.spaceSm.w(context)),
                            ),
                            child: Text(
                              context.l10n.restore,
                              style: TextStyle(
                                  fontSize: 13.sp(context),
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}