import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/responsive.dart';

/// The three non-success states every API-backed screen needs, in the
/// app's existing visual language.
///
/// Built from the tokens already in `core/constants` - the same
/// burgundy, the same fonts, the same spacing scale - so these do not
/// read as a different design. Nothing new is introduced beyond what
/// the palette already defines.

/// Centred spinner in the brand colour.
class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          if (message != null) ...[
            SizedBox(height: AppDimens.spaceMd.h(context)),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 14.sp(context),
                color: AppColors.textBody,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Shown when a request succeeded but returned nothing.
///
/// Deliberately distinct from [ErrorState]: an empty inventory is not
/// a failure, and telling the user "something went wrong" when their
/// list is simply empty is misleading.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppDimens.spaceXl.w(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.w(context),
              height: 72.w(context),
              decoration: const BoxDecoration(
                color: AppColors.planPillBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 34.w(context),
                color: AppColors.primaryAccent,
              ),
            ),
            SizedBox(height: AppDimens.spaceMd.h(context)),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.h3.copyWith(fontSize: 17.sp(context)),
            ),
            if (message != null) ...[
              SizedBox(height: AppDimens.spaceXs.h(context)),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14.sp(context),
                  color: AppColors.textBody,
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: AppDimens.spaceLg.h(context)),
              TextButton(
                onPressed: onAction,
                child: Text(
                  actionLabel!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 15.sp(context),
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shown when a request failed.
///
/// [message] is the server's own message where there is one (the API
/// returns human-readable Arabic/English strings), never a stack trace
/// or a raw exception.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    this.message,
    this.onRetry,
    this.retryLabel = 'Try again',
  });

  final String? message;
  final VoidCallback? onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppDimens.spaceXl.w(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.w(context),
              height: 72.w(context),
              decoration: const BoxDecoration(
                color: AppColors.planPillBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_outlined,
                size: 34.w(context),
                color: AppColors.primaryAccent,
              ),
            ),
            SizedBox(height: AppDimens.spaceMd.h(context)),
            Text(
              message?.isNotEmpty == true
                  ? message!
                  : 'Something went wrong. Please try again.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 15.sp(context),
                color: AppColors.textBody,
              ),
            ),
            if (onRetry != null) ...[
              SizedBox(height: AppDimens.spaceLg.h(context)),
              TextButton(
                onPressed: onRetry,
                child: Text(
                  retryLabel,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 15.sp(context),
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A grey rounded block used to build skeleton placeholders while a
/// list loads, matching the app's existing card radius.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    required this.height,
    this.width,
    this.radius = 12,
  });

  final double height;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.imagePlaceholder.withOpacity(0.45),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Vertical stack of skeleton cards, for list screens where a bare
/// spinner would make the whole screen jump on load.
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.itemCount = 5, this.itemHeight = 86});

  final int itemCount;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.screenPaddingH.w(context),
        vertical: AppDimens.spaceMd.h(context),
      ),
      itemCount: itemCount,
      separatorBuilder: (_, __) =>
          SizedBox(height: AppDimens.spaceSm.h(context)),
      itemBuilder: (_, __) => SkeletonBox(height: itemHeight.h(context)),
    );
  }
}

/// Square thumbnail used by the offer, package and course cards.
///
/// These all rendered a flat grey box regardless of whether the record
/// had an image, so every list looked like a loading skeleton that
/// never finished. The model already carries `imageUrl`; this just
/// shows it, and keeps the grey box as the genuine no-image state.
class CardThumbnail extends StatelessWidget {
  const CardThumbnail({
    super.key,
    required this.imageUrl,
    required this.size,
    this.fallbackIcon = Icons.image_outlined,
    this.radius = 10,
  });

  final String? imageUrl;
  final double size;
  final IconData fallbackIcon;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.imagePlaceholder,
        borderRadius: BorderRadius.circular(radius),
      ),
      clipBehavior: Clip.antiAlias,
      child: (url == null || url.isEmpty)
          ? Icon(
              fallbackIcon,
              size: size * 0.4,
              color: AppColors.avatarPlaceholder,
            )
          : Image.network(
              url,
              fit: BoxFit.cover,
              // A broken link must not look identical to "no image" -
              // it means the file is missing on the server.
              errorBuilder: (_, __, ___) => Icon(
                Icons.broken_image_outlined,
                size: size * 0.4,
                color: AppColors.avatarPlaceholder,
              ),
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : const SizedBox.shrink(),
            ),
    );
  }
}