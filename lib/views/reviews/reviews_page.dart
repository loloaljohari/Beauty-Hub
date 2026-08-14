import 'package:flutter/material.dart';
import '../../core/localization/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/reviews/reviews_bloc.dart';
import '../../blocs/reviews/reviews_event.dart';
import '../../blocs/reviews/reviews_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/review_card.dart';
import '../../widgets/state_views.dart';

/// Reviews management screen - matches Figma frame "Reviews" (1138:xxxx).
class ReviewsPage extends StatelessWidget {
  const ReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReviewsBloc()..add(const ReviewsLoaded()),
      child: const _ReviewsView(),
    );
  }
}

class _ReviewsView extends StatelessWidget {
  const _ReviewsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          context.l10n.reviews,
          style: AppTextStyles.h3.copyWith(fontSize: 18.sp(context)),
        ),
      ),
      body: BlocConsumer<ReviewsBloc, ReviewsState>(
        // Action failures (hide/reply) surface as a snackbar rather
        // than replacing the whole list the user is looking at.
        listenWhen: (previous, current) =>
            previous.actionStatus != current.actionStatus,
        listener: (context, state) {
          if (state.actionStatus == ReviewsActionStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          if (state.status == ReviewsStatus.loading ||
              state.status == ReviewsStatus.initial) {
            return const SkeletonList(itemCount: 4, itemHeight: 120);
          }

          if (state.status == ReviewsStatus.failure) {
            return ErrorState(
              message: state.errorMessage,
              onRetry: () =>
                  context.read<ReviewsBloc>().add(const ReviewsLoaded()),
            );
          }

          if (state.isEmpty) {
            return EmptyState(
              icon: Icons.star_border_rounded,
              title: context.l10n.noReviewsYet,
              message:
                  context.l10n.reviewsWillAppear??
                  'appear here.',
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async =>
                context.read<ReviewsBloc>().add(const ReviewsLoaded()),
            child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimens.screenPaddingH.w(context),
              vertical: AppDimens.spaceMd.h(context),
            ),
            children: [
              _SummaryRow(
                averageRating: state.averageRating,
                totalCount: state.totalReviewsCount,
              ),
              SizedBox(height: AppDimens.spaceMd.h(context)),
              for (final review in state.reviews)
                ReviewCard(
                  review: review,
                  onDelete: () => context
                      .read<ReviewsBloc>()
                      .add(ReviewDeleted(review.id)),
                ),
            ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.averageRating, required this.totalCount});

  final double averageRating;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimens.spaceMd.r(context)),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      averageRating.toStringAsFixed(1),
                      style: AppTextStyles.h2.copyWith(fontSize: 28.sp(context)),
                    ),
                    SizedBox(width: AppDimens.spaceXs.w(context)),
                    Icon(Icons.star, size: 22.r(context), color: Colors.amber),
                  ],
                ),
                Text(
                  context.l10n.averageRating,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12.sp(context),
                    color: AppColors.textSecondaryGrey,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.divider),
          Expanded(
            child: Column(
              children: [
                Text(
                  '$totalCount',
                  style: AppTextStyles.h2.copyWith(fontSize: 28.sp(context)),
                ),
                Text(
                  context.l10n.totalReviews,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12.sp(context),
                    color: AppColors.textSecondaryGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
