import 'package:flutter/material.dart';
import '../../core/localization/l10n/app_localizations.dart';
import '../../widgets/state_views.dart';
import '../salon_detail/salon_detail_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/salons/salons_bloc.dart';
import '../../blocs/salons/salons_event.dart';
import '../../blocs/salons/salons_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/route_names.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/salon_card.dart';
import '../../widgets/segmented_tab_bar.dart';

/// "Salons & Centers" browsing screen - matches the Figma frame
/// previously mislabeled "Material Inventory" in the export
/// (corrected per your note: this is salon/center discovery, not
/// inventory).
class SalonsPage extends StatelessWidget {
  const SalonsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SalonsBloc()..add(const SalonsLoaded()),
      child: const _SalonsView(),
    );
  }
}

class _SalonsView extends StatelessWidget {
  const _SalonsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          context.l10n.salonsAndCenters,
          style: AppTextStyles.h3.copyWith(fontSize: 18.sp(context)),
        ),
      ),
      body: BlocBuilder<SalonsBloc, SalonsState>(
        builder: (context, state) {
          if (state.status == SalonsStatus.loading ||
              state.status == SalonsStatus.initial) {
            return const SkeletonList(itemCount: 4, itemHeight: 180);
          }

          if (state.status == SalonsStatus.failure) {
            return ErrorState(
              message: state.errorMessage,
              onRetry: () =>
                  context.read<SalonsBloc>().add(const SalonsLoaded()),
            );
          }

          final bloc = context.read<SalonsBloc>();
          final results = state.filteredSalons;

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimens.screenPaddingH.w(context),
                ),
                child: SegmentedTabBar(
                  labels: const ['Salons', 'Centers'],
                  selectedIndex: state.tabIndex,
                  onChanged: (index) =>
                      bloc.add(SalonsTabChanged(index)),
                ),
              ),
              SizedBox(height: AppDimens.spaceSm.h(context)),
              SizedBox(
                height: 36.h(context),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimens.screenPaddingH.w(context),
                  ),
                  children: [
                    for (final city in state.cities)
                      Padding(
                        padding: EdgeInsets.only(right: AppDimens.spaceXs.w(context)),
                        child: ChoiceChip(
                          label: Text(city),
                          selected: state.selectedCity == city,
                          onSelected: (_) =>
                              bloc.add(SalonsCityChanged(city)),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: AppDimens.spaceSm.h(context)),
              Expanded(
                child: results.isEmpty
                    ? EmptyState(
                        icon: Icons.storefront_outlined,
                        title: context.l10n.nothingHereYet,
                        message:
                            context.l10n.noProvidersMatch??
                            'another city or tab.',
                      )
                    : GridView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimens.screenPaddingH.w(context),
                  ),
                  itemCount: results.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        MediaQuery.of(context).size.width >= 600 ? 3 : 2,
                    mainAxisSpacing: AppDimens.spaceSm.h(context),
                    crossAxisSpacing: AppDimens.spaceSm.w(context),
                    childAspectRatio: 0.6,
                  ),
                  itemBuilder: (context, index) {
                    final salon = results[index];
                    return SalonCard(
                      salon: salon,
                      onTap: () => Navigator.of(context).pushNamed(
                        RouteNames.salonDetail,
                        // The type travels with the id: salons and
                        // centers are separate tables and can share one.
                        arguments: SalonDetailArgs(
                          id: salon.id,
                          type: salon.type,
                        ),
                      ),
                    );
                  },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
