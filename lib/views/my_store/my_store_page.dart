import 'package:beautyhup/views/my_store/ProductDetailPage.dart';
import '../../core/localization/l10n/app_localizations.dart';
import '../../widgets/state_views.dart';
import 'package:beautyhup/widgets/chat_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/my_store/my_store_bloc.dart';
import '../../blocs/my_store/my_store_event.dart';
import '../../blocs/my_store/my_store_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/route_names.dart';
import '../../core/utils/main_shell_scope.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/app_header.dart';
import '../../widgets/product_card.dart';
import '../../widgets/segmented_tab_bar.dart';
import '../../widgets/stat_metric_card.dart';

/// Combined Warehouse + My Store screen - matches Figma frames
/// "Warehouse" (948:1647) and "My store" (948:2442), unified into a
/// single screen with a top [SegmentedTabBar] as agreed.
class MyStorePage extends StatelessWidget {
  const MyStorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MyStoreBloc()..add(const MyStoreLoaded()),
      child: const _MyStoreView(),
    );
  }
}

class _MyStoreView extends StatelessWidget {
  const _MyStoreView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
                automaticallyImplyLeading: false  ,

        title: AppHeader(
            onMenuTap: () {
  print("STEP 1");

  final scope = MainShellScope.of(context);

  print("STEP 2");

  scope.openMenu();

  print("STEP 3");
},
          mystore:true,
          hasUnreadNotification: true,
          onNotificationTap: () =>
              Navigator.of(context).pushNamed(RouteNames.cartOrders),
        ),
      ),
      floatingActionButton: BlocBuilder<MyStoreBloc, MyStoreState>(
        builder: (context, state) {
          if (state.tabIndex != 1) return const SizedBox.shrink();
          return FloatingActionButton(
            // Every FloatingActionButton defaults to the SAME Hero tag,
            // so pushing a screen that also has one throws "multiple
            // heroes share the same tag". The warehouse tab has no FAB,
            // which is why only My Store crashed.
            heroTag: 'my_store_add_product_fab',
            backgroundColor: AppColors.primary,
            onPressed: () async {
              final saved =
                  await Navigator.of(context).pushNamed(RouteNames.addProduct);

              if (saved == true && context.mounted) {
                context.read<MyStoreBloc>().add(const MyStoreLoaded());
              }
            },
            child: const Icon(Icons.add, color: AppColors.white),
          );
        },
      ),
      body: BlocConsumer<MyStoreBloc, MyStoreState>(
        listenWhen: (previous, current) =>
            previous.actionStatus != current.actionStatus,
        listener: (context, state) {
          if (state.actionStatus == MyStoreActionStatus.addedToCart) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.addedToCart)),
            );
          } else if (state.actionStatus == MyStoreActionStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          if (state.status == MyStoreStatus.loading ||
              state.status == MyStoreStatus.initial) {
            return const SkeletonList(itemCount: 4, itemHeight: 200);
          }

          if (state.status == MyStoreStatus.failure) {
            return ErrorState(
              message: state.errorMessage,
              onRetry: () =>
                  context.read<MyStoreBloc>().add(const MyStoreLoaded()),
            );
          }

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimens.screenPaddingH.w(context),
                ),
                child: SegmentedTabBar(
                  labels: const ['Buy from warehouse', 'My Store'],
                  selectedIndex: state.tabIndex,
                  onChanged: (index) => context
                      .read<MyStoreBloc>()
                      .add(MyStoreTabChanged(index)),
                ),
              ),
              SizedBox(height: AppDimens.spaceSm.h(context)),
              Expanded(
                child: state.tabIndex == 0
                    ? _WarehouseTab(state: state)
                    : _MyStoreTab(state: state),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _WarehouseTab extends StatelessWidget {
  const _WarehouseTab({required this.state});

  final MyStoreState state;

  @override
  Widget build(BuildContext context) {
    final products = state.filteredWarehouseProducts;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimens.screenPaddingH.w(context),
          ),
          sliver: SliverToBoxAdapter(
            child: _SearchField(
              onChanged: (value) => context
                  .read<MyStoreBloc>()
                  .add(MyStoreSearchChanged(value)),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimens.screenPaddingH.w(context),
            vertical: AppDimens.spaceSm.h(context),
          ),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width >= 600 ? 3 : 2,
              mainAxisSpacing: AppDimens.spaceSm.h(context),
              crossAxisSpacing: AppDimens.spaceSm.w(context),
              childAspectRatio: 0.60,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final product = products[index];
                return ProductCard(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProductDetailsScreen(productId: product.id),
                      ),
                    );
                    // The cart badge may have changed while it was open.
                    if (context.mounted) {
                      context.read<MyStoreBloc>().add(const MyStoreLoaded());
                    }
                  },
                  product: product,
                  onFavoriteTap: () => context
                      .read<MyStoreBloc>()
                      .add(MyStoreFavoriteToggled(product.id)),
                  onCartTap: () => context
                      .read<MyStoreBloc>()
                      .add(MyStoreAddToCart(product.id)),
                );
              },
              childCount: products.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _MyStoreTab extends StatelessWidget {
  const _MyStoreTab({required this.state});

  final MyStoreState state;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimens.screenPaddingH.w(context),
          ),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppDimens.spaceXs.h(context)),
                Row(
                  children: [
                    for (final metric in state.metrics) ...[
                      Expanded(child: StatMetricCard(metric: metric)),
                      SizedBox(width: AppDimens.spaceXs.w(context)),
                    ],
                  ],
                ),
                SizedBox(height: AppDimens.spaceMd.h(context)),
                Text(
                  context.l10n.manageProducts,
                  style:
                      AppTextStyles.h3.copyWith(fontSize: 16.sp(context)),
                ),
                SizedBox(height: AppDimens.spaceSm.h(context)),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimens.screenPaddingH.w(context),
          ),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width >= 600 ? 3 : 2,
              mainAxisSpacing: AppDimens.spaceSm.h(context),
              crossAxisSpacing: AppDimens.spaceSm.w(context),
              childAspectRatio: 0.6,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final product = state.myStoreProducts[index];
                return ProductCard(
                  product: product,
                  showManagementBadge: true,
                  onEdit: () async {
                    await Navigator.of(context).pushNamed(
                      RouteNames.addProduct,
                      arguments: product.id,
                    );
                    if (context.mounted) {
                      context.read<MyStoreBloc>().add(const MyStoreLoaded());
                    }
                  },
                  onDelete: () => _confirmDelete(context, product.id),
                );
              },
              childCount: state.myStoreProducts.length,
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.only(bottom: AppDimens.spaceXl.h(context)),
          sliver: const SliverToBoxAdapter(child: SizedBox.shrink()),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppDimens.spaceSm.h(context)),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: context.l10n.searchProducts,
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: AppColors.inputBackground,
          contentPadding: EdgeInsets.symmetric(
            vertical: AppDimens.spaceSm.h(context),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

/// Deleting archives the product server-side, so buyers' order history
/// survives. Confirmed first because it is not reversible from the app.
void _confirmDelete(BuildContext context, String productId) {
  final bloc = context.read<MyStoreBloc>();

  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.white,
      title: Text(context.l10n.removeThisProduct),
      content: Text(
        context.l10n.removeProductHint,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(context.l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            bloc.add(MyStoreProductDeleted(productId));
          },
          child: Text(
            context.l10n.remove,
            style: TextStyle(color: AppColors.statusDanger),
          ),
        ),
      ],
    ),
  );
}
