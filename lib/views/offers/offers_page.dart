import 'package:flutter/material.dart';
import '../../core/localization/l10n/app_localizations.dart';
import '../../data/repositories/offers_repository.dart';
import '../../widgets/state_views.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/offers/offers_bloc.dart';
import '../../blocs/offers/offers_event.dart';
import '../../blocs/offers/offers_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/route_names.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/offer_models.dart';
import '../../widgets/offer_cards.dart';

/// Offers & Discounts screen - matches Figma frames (4 variants
/// representing Service Discounts / Products Offers / Packages /
/// Rewards tabs of the same screen).
class OffersPage extends StatefulWidget {
  const OffersPage({super.key});

  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OffersBloc()..add(const OffersLoaded()),
      child: _OffersView(tabController: _tabController),
    );
  }
}

class _OffersView extends StatelessWidget {
  const _OffersView({required this.tabController});

  final TabController tabController;

  /// Product offers is the only tab with no backend to create against,
  /// so its "+" button stays hidden rather than opening a form that
  /// posts nowhere.
  String? _addRouteForTab(int index) {
    return switch (index) {
      0 => RouteNames.addDiscount,
      2 => RouteNames.addPackage,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          context.l10n.offersAndDiscounts,
          style: AppTextStyles.h3.copyWith(fontSize: 18.sp(context)),
        ),
        bottom: TabBar(
          controller: tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondaryGrey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Service Discounts'),
            Tab(text: 'Products Offers'),
            Tab(text: 'Packages'),
            Tab(text: 'Rewards'),
          ],
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: tabController,
        builder: (context, _) {
          final route = _addRouteForTab(tabController.index);
          if (route == null) return const SizedBox.shrink();
          return FloatingActionButton(
          // Unique tag: FABs default to a shared Hero tag, which
          // throws when two screens with one are on screen together.
          heroTag: 'offers_add_fab',
            backgroundColor: AppColors.primary,
            onPressed: () async {
              final created =
                  await Navigator.of(context).pushNamed(route);

              // Refetch so the new discount appears immediately instead
              // of only after the next cold open.
              if (created == true && context.mounted) {
                context.read<OffersBloc>().add(const OffersLoaded());
              }
            },
            child: const Icon(Icons.add, color: AppColors.white),
          );
        },
      ),
      body: BlocBuilder<OffersBloc, OffersState>(
        builder: (context, state) {
          if (state.status == OffersStatus.loading ||
              state.status == OffersStatus.initial) {
            return const SkeletonList(itemCount: 4, itemHeight: 120);
          }

          if (state.status == OffersStatus.failure) {
            return ErrorState(
              message: state.errorMessage,
              onRetry: () =>
                  context.read<OffersBloc>().add(const OffersLoaded()),
            );
          }

          final bloc = context.read<OffersBloc>();

          return TabBarView(
            controller: tabController,
            children: [
              _DiscountsTab(discounts: state.discounts, bloc: bloc),
              _NoBackendTab(
                title: context.l10n.productOffersUnavailable,
                message:
                    context.l10n.offersAttachToService??
                    'product. Use the Service Discounts tab instead.',
              ),
              _PackagesTab(packages: state.packages, bloc: bloc),
              _RewardsTab(followers: state.birthdayFollowers, bloc: bloc),
            ],
          );
        },
      ),
    );
  }
}

class _DiscountsTab extends StatelessWidget {
  const _DiscountsTab({required this.discounts, required this.bloc});

  final List<DiscountModel> discounts;
  final OffersBloc bloc;

  @override
  Widget build(BuildContext context) {
    if (discounts.isEmpty) {
      return EmptyState(
        icon: Icons.local_offer_outlined,
        title: context.l10n.noDiscountsYet,
        message:
            context.l10n.discountHint??
            'here.',
      );
    }
    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.screenPaddingH.w(context),
        vertical: AppDimens.spaceMd.h(context),
      ),
      children: [
        for (final discount in discounts)
          DiscountCard(
            discount: discount,
            onDelete: () => bloc.add(DiscountDeleted(discount.id)),
          ),
      ],
    );
  }
}

// RETAINED, NOT CURRENTLY MOUNTED.
//
// _ProductOffersTab is kept intact so the tab can be switched back on
// the moment the backend grows a product-offer endpoint; deleting it
// would mean rebuilding this UI from scratch later. Until then
// _NoBackendTab is rendered in its place, and the analyzer flags this
// class as unused - expected.
class _ProductOffersTab extends StatelessWidget {
  const _ProductOffersTab({required this.offers, required this.bloc});

  final List<OfferModel> offers;
  final OffersBloc bloc;

  @override
  Widget build(BuildContext context) {
    if (offers.isEmpty) return Center(child: Text(context.l10n.noOffersYet));
    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.screenPaddingH.w(context),
        vertical: AppDimens.spaceMd.h(context),
      ),
      children: [
        for (final offer in offers)
          OfferCard(
            offer: offer,
            onDelete: () => bloc.add(OfferDeleted(offer.id)),
          ),
      ],
    );
  }
}

class _PackagesTab extends StatelessWidget {
  const _PackagesTab({required this.packages, required this.bloc});

  final List<PackageModel> packages;
  final OffersBloc bloc;

  @override
  Widget build(BuildContext context) {
    if (packages.isEmpty) {
      return EmptyState(
        icon: Icons.inventory_2_outlined,
        title: context.l10n.noPackagesYet,
        message:
            context.l10n.bundleHint??
            'them at one price.',
      );
    }
    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.screenPaddingH.w(context),
        vertical: AppDimens.spaceMd.h(context),
      ),
      children: [
        for (final package in packages)
          PackageCard(
            package: package,
            onDelete: () => bloc.add(PackageDeleted(package.id)),
          ),
      ],
    );
  }
}

class _RewardsTab extends StatelessWidget {
  const _RewardsTab({required this.followers, required this.bloc});

  /// Followers with a birthday today, from
  /// `GET /expert/loyalty/birthdays`. There is no points leaderboard
  /// endpoint, so this tab shows who can be gifted today instead of a
  /// ranking the backend cannot produce.
  final List<BirthdayFollower> followers;
  final OffersBloc bloc;

  @override
  Widget build(BuildContext context) {
    if (followers.isEmpty) {
      return EmptyState(
        icon: Icons.card_giftcard_outlined,
        title: context.l10n.noBirthdaysToday,
        message:
            context.l10n.birthdayGiftHint??
            'loyalty points from here.',
      );
    }

    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.screenPaddingH.w(context),
        vertical: AppDimens.spaceMd.h(context),
      ),
      children: [
        for (final follower in followers)
          Padding(
            padding: EdgeInsets.only(bottom: AppDimens.spaceSm.h(context)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        follower.name,
                        style: AppTextStyles.bodyMediumBold
                            .copyWith(fontSize: 15.sp(context)),
                      ),
                      Text(
                        '${follower.loyaltyPoints} points',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 13.sp(context),
                          color: AppColors.textBody,
                        ),
                      ),
                    ],
                  ),
                ),
                if (follower.alreadyGifted)
                  Text(
                    context.l10n.gifted,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 13.sp(context),
                      color: AppColors.textMuted,
                    ),
                  )
                else
                  TextButton(
                    onPressed: () =>
                        bloc.add(BirthdayGiftGranted(follower.id)),
                    child: Text(
                      context.l10n.sendGift,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14.sp(context),
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Placeholder for the two tabs the backend has no endpoints for.
///
/// Showing an honest explanation beats showing invented offers the
/// user could tap and never actually create.
class _NoBackendTab extends StatelessWidget {
  const _NoBackendTab({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.info_outline,
      title: title,
      message: message,
    );
  }
}
