import 'package:flutter/material.dart';
import '../../core/localization/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/community/community_bloc.dart';
import '../../blocs/community/community_event.dart';
import '../../blocs/community/community_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/image_helpers.dart';
import '../../core/utils/responsive.dart';
import '../../data/repositories/community_repository.dart';
import '../../widgets/segmented_tab_bar.dart';
import '../../widgets/stat_badge_row.dart';
import '../../widgets/state_views.dart';

/// Followers & Blocked users.
///
/// New screen for `GET /expert/followers` and
/// `GET /expert/blocked-users`, which had no UI at all before - the
/// profile only ever showed the `followers_count` number, with no way
/// to see or manage the people behind it.
///
/// Built entirely from existing components ([SegmentedTabBar],
/// [StatBadgeRow], [EmptyState]) and existing tokens, so it reads as
/// the same app rather than a new design.
class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CommunityBloc()..add(const CommunityLoaded()),
      child: const _CommunityView(),
    );
  }
}

class _CommunityView extends StatelessWidget {
  const _CommunityView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          context.l10n.audience,
          style: AppTextStyles.h3.copyWith(fontSize: 18.sp(context)),
        ),
      ),
      body: BlocConsumer<CommunityBloc, CommunityState>(
        listenWhen: (previous, current) =>
            previous.actionStatus != current.actionStatus,
        listener: (context, state) {
          if (state.actionStatus == CommunityActionStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          final bloc = context.read<CommunityBloc>();

          if (state.status == CommunityStatus.loading ||
              state.status == CommunityStatus.initial) {
            return const SkeletonList(itemCount: 6, itemHeight: 72);
          }

          if (state.status == CommunityStatus.failure) {
            return ErrorState(
              message: state.errorMessage,
              onRetry: () => bloc.add(const CommunityLoaded()),
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
                  children: [
                    StatBadgeRow(
                      badges: [
                        StatBadge(
                          label: context.l10n.followers,
                          value: '${state.followers.length}',
                        ),
                        StatBadge(
                          label: context.l10n.blocked,
                          value: '${state.blocked.length}',
                          color: AppColors.statusDanger,
                        ),
                      ],
                    ),
                    SizedBox(height: AppDimens.spaceMd.h(context)),
                    SegmentedTabBar(
                      labels: const ['Followers', 'Blocked'],
                      selectedIndex: state.tabIndex,
                      onChanged: (index) =>
                          bloc.add(CommunityTabChanged(index)),
                    ),
                    // Search is only meaningful on followers - the
                    // blocked-users endpoint takes no `q` parameter.
                    if (state.tabIndex == 0) ...[
                      SizedBox(height: AppDimens.spaceSm.h(context)),
                      _SearchField(
                        onChanged: (value) =>
                            bloc.add(CommunitySearchChanged(value)),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: state.tabIndex == 0
                    ? _FollowersList(state: state, bloc: bloc)
                    : _BlockedList(state: state, bloc: bloc),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: AppTextStyles.bodyMedium.copyWith(fontSize: 14.sp(context)),
      decoration: InputDecoration(
        hintText: context.l10n.searchFollowers,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          fontSize: 14.sp(context),
          color: AppColors.textHint,
        ),
        prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding: EdgeInsets.symmetric(
          vertical: AppDimens.spaceSm.h(context),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.inputRadius),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _FollowersList extends StatelessWidget {
  const _FollowersList({required this.state, required this.bloc});

  final CommunityState state;
  final CommunityBloc bloc;

  @override
  Widget build(BuildContext context) {
    if (state.isFollowersEmpty) {
      return EmptyState(
        icon: Icons.people_outline,
        title: state.searchQuery.isEmpty
            ? 'No followers yet'
            : 'No followers match that search',
        message: state.searchQuery.isEmpty
            ? 'Customers who follow you will appear here, and you will be '
                'able to message them.'
            : null,
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => bloc.add(const CommunityLoaded()),
      child: ListView.builder(
        padding: EdgeInsets.only(
          left: AppDimens.screenPaddingH.w(context),
          right: AppDimens.screenPaddingH.w(context),
          bottom: AppDimens.spaceXl.h(context),
        ),
        itemCount: state.followers.length,
        itemBuilder: (context, index) {
          final user = state.followers[index];

          return _UserRow(
            user: user,
            subtitle: user.since.isEmpty
                ? user.phone
                : 'Following since ${user.since}',
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz, color: AppColors.textBody),
              onSelected: (value) {
                if (value == 'remove') {
                  _confirm(
                    context,
                    title: context.l10n.removeFollowerQuestion,
                    message:
                        '${user.name} will stop following you and will no '
                        'longer see your posts in their feed.',
                    onConfirm: () => bloc.add(FollowerRemoved(user.id)),
                  );
                } else if (value == 'block') {
                  _confirm(
                    context,
                    title: 'Block ${user.name}?',
                    message:
                        context.l10n.removeFollowerHint??
                        'between you will be closed.',
                    onConfirm: () => bloc.add(UserBlocked(user.id)),
                  );
                }
              },
              itemBuilder: (_) =>  [
                PopupMenuItem(value: 'remove', child: Text(context.l10n.removeFollower)),
                PopupMenuItem(value: 'block', child: Text(context.l10n.block)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BlockedList extends StatelessWidget {
  const _BlockedList({required this.state, required this.bloc});

  final CommunityState state;
  final CommunityBloc bloc;

  @override
  Widget build(BuildContext context) {
    if (state.isBlockedEmpty) {
      return EmptyState(
        icon: Icons.block_outlined,
        title: context.l10n.nobodyIsBlocked,
        message: context.l10n.blockedListHint,
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => bloc.add(const CommunityLoaded()),
      child: ListView.builder(
        padding: EdgeInsets.only(
          left: AppDimens.screenPaddingH.w(context),
          right: AppDimens.screenPaddingH.w(context),
          bottom: AppDimens.spaceXl.h(context),
        ),
        itemCount: state.blocked.length,
        itemBuilder: (context, index) {
          final user = state.blocked[index];

          return _UserRow(
            user: user,
            subtitle:
                user.since.isEmpty ? null : 'Blocked on ${user.since}',
            trailing: TextButton(
              onPressed: () => bloc.add(UserUnblocked(user.id)),
              child: Text(
                context.l10n.unblock,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14.sp(context),
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({required this.user, this.subtitle, this.trailing});

  final CommunityUser user;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppDimens.spaceXs.h(context)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22.r(context),
            backgroundColor: AppColors.avatarPlaceholder,
            backgroundImage: remoteImageProvider(user.photoUrl),
            child: remoteImageProvider(user.photoUrl) == null
                ? Icon(
                    Icons.person_outline,
                    size: 22.r(context),
                    color: AppColors.white,
                  )
                : null,
          ),
          SizedBox(width: AppDimens.spaceSm.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name.isEmpty ? 'Unknown' : user.name,
                  style: AppTextStyles.bodyMediumBold
                      .copyWith(fontSize: 15.sp(context)),
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null && subtitle!.isNotEmpty)
                  Text(
                    subtitle!,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12.sp(context),
                      color: AppColors.textBody,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Destructive actions get a confirmation step - removing a follower
/// and blocking are both irreversible from the other side.
void _confirm(
  BuildContext context, {
  required String title,
  required String message,
  required VoidCallback onConfirm,
}) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.white,
      title: Text(title, style: AppTextStyles.h3.copyWith(fontSize: 17)),
      content: Text(
        message,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textBody),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(context.l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            onConfirm();
          },
          child: Text(
            context.l10n.confirm,
            style: TextStyle(color: AppColors.statusDanger),
          ),
        ),
      ],
    ),
  );
}
