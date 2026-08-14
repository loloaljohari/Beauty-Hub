import 'package:beautyhup/data/models/post_model.dart';
import '../../core/localization/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/salon_detail/salon_detail_bloc.dart';
import '../../blocs/salon_detail/salon_detail_event.dart';
import '../../blocs/salon_detail/salon_detail_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/review_model.dart';
import '../../data/models/salon_model.dart';
import '../../widgets/review_card.dart';
import '../../widgets/segmented_tab_bar.dart';
import '../profile/postfeedpage.dart';

/// "detail of salon" screen - matches Figma frames (3 variants
/// representing Info / Reviews / Posts tabs of the same screen).
class SalonDetailPage extends StatelessWidget {
  const SalonDetailPage({
    super.key,
    required this.salonId,
    this.type = SalonType.salon,
  });

  final String salonId;

  /// Salons and centers live in separate tables and can share an id,
  /// so the type has to be passed through with it.
  final SalonType type;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          SalonDetailBloc()..add(SalonDetailLoaded(salonId, type: type)),
      child: const _SalonDetailView(),
    );
  }
}

class _SalonDetailView extends StatelessWidget {
  const _SalonDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocBuilder<SalonDetailBloc, SalonDetailState>(
        builder: (context, state) {
          if (state.status != SalonDetailStatus.loaded || state.salon == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final salon = state.salon!;
          final bloc = context.read<SalonDetailBloc>();

          return CustomScrollView(
            
            slivers: [
              SliverAppBar(
                backgroundColor: AppColors.white,
                pinned: true,
                expandedHeight: 200.h(context),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(color: AppColors.imagePlaceholder,child:salon.imageUrl==null?null:  Image.network(salon.imageUrl!,fit: BoxFit.cover,),),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(AppDimens.screenPaddingH.w(context)),
                  child: _SalonHeader(
                    salon: salon,
                    onFollowTap: () =>
                        bloc.add(const SalonFollowToggled()),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimens.screenPaddingH.w(context),
                  ),
                  child: SegmentedTabBar(
                    labels: const ['Info', 'Reviews', 'Posts'],
                    selectedIndex: state.tabIndex,
                    onChanged: (index) =>
                        bloc.add(SalonDetailTabChanged(index)),
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.all(AppDimens.screenPaddingH.w(context)),
                sliver: SliverToBoxAdapter(
                  child: switch (state.tabIndex) {
                    0 => _InfoTab(salon: salon),
                    1 => _ReviewsTab(reviews: state.reviews),
                    _ => _PostsTab(posts: state.posts,salon:salon),
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

class _SalonHeader extends StatelessWidget {
  const _SalonHeader({required this.salon, required this.onFollowTap});

  final SalonModel salon;
  final VoidCallback onFollowTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                salon.name,
                style: AppTextStyles.h2.copyWith(fontSize: 22.sp(context)),
              ),
            ),
            ElevatedButton(
              onPressed: onFollowTap,
              style: ElevatedButton.styleFrom(
                fixedSize: Size(100, 50),
                backgroundColor: salon.isFollowing
                    ? AppColors.inputBackgroundAlt
                    : AppColors.followBackground,
                foregroundColor: salon.isFollowing
                    ? AppColors.textPrimary
                    : AppColors.followText,
                elevation: 0,
              ),
              child: Text(salon.isFollowing ? 'Following' : 'Follow'),
            ),
          ],
        ),
        Row(
          children: [
            Icon(Icons.star, size: 16.r(context), color: Colors.amber),
            SizedBox(width: 4.w(context)),
            Text(
              '${salon.rating.toStringAsFixed(1)} (${salon.reviewsCount})',
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 13.sp(context)),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoTab extends StatelessWidget {
  const _InfoTab({required this.salon});

  final SalonModel salon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          salon.description,
          style: AppTextStyles.bodyMedium.copyWith(fontSize: 14.sp(context)),
        ),
        SizedBox(height: AppDimens.spaceMd.h(context)),
        Text(
          context.l10n.callInfo,
          style: AppTextStyles.h3.copyWith(fontSize: 15.sp(context)),
        ),
        for (final phone in salon.phoneNumbers)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 2.h(context)),
            child: Row(
              children: [
                Icon(Icons.phone_outlined, size: 16.r(context)),
                SizedBox(width: AppDimens.spaceXs.w(context)),
                Text(phone, style: AppTextStyles.bodyMedium.copyWith(fontSize: 13.sp(context))),
              ],
            ),
          ),
        SizedBox(height: AppDimens.spaceSm.h(context)),
        Text(
          context.l10n.positionInfo,
          style: AppTextStyles.h3.copyWith(fontSize: 15.sp(context)),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 2.h(context)),
          child: Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16.r(context)),
              SizedBox(width: AppDimens.spaceXs.w(context)),
              Expanded(
                child: Text(salon.address, style: AppTextStyles.bodyMedium.copyWith(fontSize: 13.sp(context))),
              ),
            ],
          ),
        ),
        SizedBox(height: AppDimens.spaceMd.h(context)),
        Text(
          context.l10n.services,
          style: AppTextStyles.h3.copyWith(fontSize: 15.sp(context)),
        ),
        SizedBox(height: AppDimens.spaceXs.h(context)),
        Wrap(
          spacing: AppDimens.spaceXs.w(context),
          runSpacing: AppDimens.spaceXs.h(context),
          children: [
            for (final service in salon.services)
              Chip(label: Text(service)),
          ],
        ),
        SizedBox(height: AppDimens.spaceMd.h(context)),
        Text(
          context.l10n.employees,
          style: AppTextStyles.h3.copyWith(fontSize: 15.sp(context)),
        ),
        SizedBox(height: AppDimens.spaceXs.h(context)),
        Wrap(
          spacing: AppDimens.spaceSm.w(context),
          runSpacing: AppDimens.spaceSm.h(context),
          children: [
            for (final employee in salon.employees)
              Column(
                children: [
                  CircleAvatar(
                    radius: 24.r(context),
                    backgroundColor: AppColors.avatarPlaceholder,
                    backgroundImage: employee.image==null?null:NetworkImage(employee.image),
                  ),
                  SizedBox(height: 2.h(context)),
                  Text(employee.name, style: TextStyle(fontSize: 11.sp(context))),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  const _ReviewsTab({required this.reviews});

  final List<ReviewModel> reviews;

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return Center(child: Text(context.l10n.noReviewsYet));
    }
    return Column(
      children: [for (final review in reviews) ReviewCard(review: review)],
    );
  }
}

class _PostsTab extends StatelessWidget {
  const _PostsTab({required this.posts, this.salon});
 
  final List<PostModel> posts;
 final salon;
  @override
  Widget build(BuildContext context) {
    // Was `itemCount: 9` with nine empty grey boxes - the provider's
    // real posts already arrive with the profile in one request and
    // were simply never read.
    if (posts.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: AppDimens.spaceXl.h(context)),
        child: Column(
          children: [
            Icon(
              Icons.grid_on_outlined,
              size: 40.r(context),
              color: AppColors.textHint,
            ),
            SizedBox(height: AppDimens.spaceSm.h(context)),
            Text(
              context.l10n.noPostsYet,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 14.sp(context),
                color: AppColors.textSecondaryGrey,
              ),
            ),
          ],
        ),
      );
    }
 
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: posts.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width >= 600 ? 4 : 3,
        mainAxisSpacing: AppDimens.spaceXs.h(context),
        crossAxisSpacing: AppDimens.spaceXs.w(context),
      ),
      itemBuilder: (context, index) {
        final post = posts[index];
        // A post can carry several images; the grid shows the first.
        final cover =
            post.imageUrls.isEmpty ? null : post.imageUrls.first;
 
        return GestureDetector(
          onTap: () => _openPost(context, posts, index,salon),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.imagePlaceholder,
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: cover == null
                // Caption-only post: show the text rather than a blank
                // tile, which is indistinguishable from a broken image.
                ? Padding(
                    padding: EdgeInsets.all(AppDimens.spaceXs.r(context)),
                    child: Center(
                      child: Text(
                        post.caption,
                        maxLines: 4,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 11.sp(context),
                          color: AppColors.textSecondaryGrey,
                        ),
                      ),
                    ),
                  )
                : Image.network(
                    cover,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.broken_image_outlined,
                      color: AppColors.avatarPlaceholder,
                    ),
                  ),
          ),
        );
      },
    );
  }
 
  /// Opens the provider's posts in the same full-screen viewer the
  /// profile grid uses, starting at the tapped one.
  void _openPost(BuildContext context, List<PostModel> posts, int index,SalonModel salon) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PostFeedPage(
          posts: posts,
          initialIndex: index,
          userName: posts[index].authorName ?? '',
          userRole: posts[index].salonName ?? '',
          userAvatar: salon.imageUrl==null?null:salon.imageUrl,
        ),
      ),
    );
  }
}
 
/// Route argument for [RouteNames.salonDetail] when the provider type
/// matters (a center id can collide with a salon id).
class SalonDetailArgs {
  const SalonDetailArgs({required this.id, required this.type});
 
  final String id;
  final SalonType type;
}
 
