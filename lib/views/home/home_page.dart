import 'package:beautyhup/core/utils/main_shell_scope.dart';
import '../../core/localization/l10n/app_localizations.dart';
import '../../widgets/state_views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/home/home_bloc.dart';
import '../../blocs/home/home_event.dart';
import '../../blocs/home/home_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/highlight_card_model.dart';
import '../../widgets/app_header.dart';
import '../../widgets/post_card.dart';

/// Home feed screen - matches Figma frame "Home" (948:1398).
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc()..add(const HomeLoaded()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false  ,
          title: AppHeader(
        hasUnreadNotification: true,
        onMenuTap: () {
          print("STEP 1");

          final scope = MainShellScope.of(context);

          print("STEP 2");

          scope.openMenu();

        },
      )
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state.status == HomeStatus.loading ||
              state.status == HomeStatus.initial) {
            return const SkeletonList(itemCount: 3, itemHeight: 220);
          }

          if (state.status == HomeStatus.failure) {
            return ErrorState(
              message: state.errorMessage,
              onRetry: () =>
                  context.read<HomeBloc>().add(const HomeLoaded()),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async =>
                context.read<HomeBloc>().add(const HomeLoaded()),
            child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimens.screenPaddingH.w(context),
              vertical: AppDimens.spaceSm.h(context),
            ),
            children: [
              // if (state.notifications.isNotEmpty) ...[
              //   _NotificationsSection(notifications: state.notifications),
              //   SizedBox(height: AppDimens.spaceMd.h(context)),
              // ],
              _HighlightCardsRow(cards: state.notifications),
              SizedBox(height: AppDimens.spaceLg.h(context)),
              if (state.isEmpty)
                Padding(
                  padding: EdgeInsets.only(top: AppDimens.spaceXxl.h(context)),
                  child: EmptyState(
                    icon: Icons.photo_library_outlined,
                    title: context.l10n.noPostsYet,
                    message:
                        context.l10n.shareYourWork??
                        'followers.',
                  ),
                ),
              for (final post in state.posts) ...[
                PostCard(
                  post: post,
                  // Null hides the button: a post with no provider
                  // identity is the expert's own.
                  onFollowTap: post.providerType.isEmpty
                      ? null
                      : () => context
                          .read<HomeBloc>()
                          .add(HomePostFollowToggled(post.id)),
                  onLikeTap: () => context
                      .read<HomeBloc>()
                      .add(HomePostLikeToggled(post.id)),
                ),
                SizedBox(height: 5.h(context)),
                Divider(color: AppColors.textHint, thickness: 1.5),
                SizedBox(height: AppDimens.spaceMd.h(context)),
              ],
            ],
            ),
          );
        },
      ),
    );
  }
}

class _NotificationsSection extends StatelessWidget {
  const _NotificationsSection({required this.notifications});

  final List<HomeNotificationModel> notifications;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final notification in notifications) ...[
          _NotificationBanner(notification: notification),
          SizedBox(height: AppDimens.spaceXs.h(context)),
        ],
      ],
    );
  }
}

class _NotificationBanner extends StatelessWidget {
  const _NotificationBanner({required this.notification});

  final HomeNotificationModel notification;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimens.spaceSm.r(context)),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notification.message,
            style: AppTextStyles.label.copyWith(fontSize: 14.sp(context)),
          ),
          SizedBox(height: AppDimens.spaceXs.h(context)),
          Row(
            children: [
              TextButton(
                onPressed: () => context
                    .read<HomeBloc>()
                    .add(HomeNotificationDismissed(notification.id)),
                child: Text(
                  notification.declineLabel,
                  style: TextStyle(
                    fontSize: 13.sp(context),
                    color: AppColors.textSecondaryGrey,
                  ),
                ),
              ),
              SizedBox(width: AppDimens.spaceXs.w(context)),
              ElevatedButton(
                onPressed: () => context
                    .read<HomeBloc>()
                    .add(HomeNotificationDismissed(notification.id)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimens.spaceMd.w(context),
                    vertical: AppDimens.spaceXxs.h(context),
                  ),
                ),
                child: Text(
                  notification.acceptLabel,
                  style: TextStyle(fontSize: 13.sp(context)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HighlightCardsRow extends StatelessWidget {
  const _HighlightCardsRow({required this.cards});

  final List<HomeNotificationModel> cards;

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) return const SizedBox.shrink();

    // A horizontal ListView forces a fixed height on its parent, and
    // the old `height: 140` overflowed as soon as Arabic text wrapped
    // to a third line. A scrolling Row inside IntrinsicHeight instead
    // lets every card grow to fit its own text, and `stretch` keeps
    // them all the height of the tallest one so the strip stays even.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var index = 0; index < cards.length; index++) ...[
              if (index > 0)
                SizedBox(width: AppDimens.spaceSm.w(context)),
              _HighlightCard(card: cards[index]),
            ],
          ],
        ),
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({required this.card});

  final HomeNotificationModel card;

  @override
  Widget build(BuildContext context) {
    // `n2` is the "no action" variant: a plain informational card with
    // no accept/decline pair.
    final isActionable = card.id != 'n2';

    return Container(
      width: 300.w(context),
      padding: EdgeInsets.all(AppDimens.spaceSm.r(context)),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // Without this the Column tries to fill the stretched height and
        // IntrinsicHeight can no longer measure it.
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            card.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamilyDisplay,
              fontSize: 14.sp(context),
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondaryGrey,
            ),
          ),
          SizedBox(height: AppDimens.spaceXs.h(context)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: (AppDimens.avatarSizeSmall - 10).r(context),
                backgroundColor: AppColors.avatarPlaceholder,
                backgroundImage:card.image==null?null: 
                NetworkImage(card.image)
              ),
              SizedBox(width: AppDimens.spaceSm.w(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      card.nameUser,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 14.sp(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      isActionable ? card.message : card.timestamp,
                      // Three lines of Arabic is what broke the old
                      // fixed height; the card grows for it now.
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12.sp(context),
                        color: AppColors.textSecondaryGrey,
                      ),
                    ),
                    if (isActionable) ...[
                      SizedBox(height: AppDimens.spaceXs.h(context)),
                      Row(
                        children: [
                          // Expanded on both, so the buttons share the
                          // width instead of relying on a hardcoded
                          // 60px gap that pushed them off the edge.
                          Expanded(
                            child: TextButton(
                              onPressed: () => context
                                  .read<HomeBloc>()
                                  .add(HomeNotificationDismissed(card.id)),
                              child: Text(
                                card.declineLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13.sp(context),
                                  color: AppColors.textSecondaryGrey,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: AppDimens.spaceXs.w(context)),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => context
                                  .read<HomeBloc>()
                                  .add(HomeNotificationDismissed(card.id)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppDimens.spaceSm.w(context),
                                  vertical: AppDimens.spaceXs.h(context),
                                ),
                              ),
                              child: Text(
                                card.acceptLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 13.sp(context)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}