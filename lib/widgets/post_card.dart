import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/responsive.dart';
import '../data/models/post_model.dart';

/// Feed post card matching Figma "Frame 79": avatar + author/salon
/// name + Follow button, an image area (placeholder grey box), and
/// like/comment icon row.
class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    this.onFollowTap,
    required this.onLikeTap,
  });

  final PostModel post;
  final VoidCallback? onFollowTap;
  final VoidCallback onLikeTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.postCardBackground,
        borderRadius: BorderRadius.circular(AppDimens.postCardRadius.r(context)),
      ),
      padding: EdgeInsets.all(AppDimens.spaceSm.r(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(
            post: post,
            onFollowTap: onFollowTap,
          ),
          SizedBox(height: AppDimens.spaceSm.h(context)),
            Text(
                post.caption,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 16.sp(context),
                  color: const Color.fromARGB(255, 64, 64, 64),
                ),
              ),
               SizedBox(height: AppDimens.spaceSm.h(context)),
         SizedBox(
        height: 266,
         child: ListView.separated(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: post.imageUrls.length,
          separatorBuilder: (_, __) => SizedBox(width: 3.w(context)),
          itemBuilder: (context, index) {
           
            return  post.imageUrls.isEmpty?null: Container( child: _ImagePlaceholder(post.imageUrls[index]));    },
               ),
       ),
   
          SizedBox(height: AppDimens.spaceXs.h(context)),
          _ActionsRow(post: post, onLikeTap: onLikeTap),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.post, this.onFollowTap});

  final PostModel post;
  final VoidCallback? onFollowTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: (AppDimens.avatarSizeSmall / 2).r(context),
          backgroundColor: AppColors.avatarPlaceholder,
          backgroundImage: post.authorAvatarUrl==null? null : NetworkImage(post.authorAvatarUrl!),
        ),
        SizedBox(width: AppDimens.spaceSm.w(context)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.authorName!,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 14.sp(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                post.providerType!,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12.sp(context),
                  color: AppColors.textSecondaryGrey,
                ),
              ),
            ],
          ),
        ),
        // No follow button on the expert's OWN posts. Those arrive from
        // `getMyPosts` and carry no provider identity, because there is
        // nothing to follow - you cannot follow yourself.
        if (onFollowTap != null)
          GestureDetector(
            onTap: onFollowTap,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimens.spaceMd.w(context),
                vertical: AppDimens.spaceXs.h(context),
              ),
              decoration: BoxDecoration(
                color: post.isFollowing
                    ? AppColors.inputBackgroundAlt
                    : AppColors.followBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                post.isFollowing ? 'Following' : 'Follow',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamilyText,
                  fontSize: 13.sp(context),
                  fontWeight: FontWeight.w600,
                  color: post.isFollowing
                      ? AppColors.textPrimary
                      : AppColors.followText,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder(this.image);
  final String image; // Placeholder image URL
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
         
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.imagePlaceholder,
              borderRadius: BorderRadius.circular(10.r(context)),
              image: DecorationImage(image:NetworkImage(image), fit: BoxFit.cover),
            ),
            alignment: Alignment.center,
              ),
        ),
      ],
    );
  }
}

class _ActionsRow extends StatelessWidget {
  const _ActionsRow({required this.post, required this.onLikeTap});

  final PostModel post;
  final VoidCallback onLikeTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onLikeTap,
          child: Icon(
            post.isLiked ? Icons.favorite : Icons.favorite_border,
            size: 22.r(context),
            color: post.isLiked
                ? AppColors.profileAccent
                : AppColors.textPrimary,
          ),
        ),
        SizedBox(width: AppDimens.spaceXs.w(context)),
        Text(
          '${post.likesCount}',
          style: AppTextStyles.bodySmall.copyWith(fontSize: 13.sp(context)),
        ),
        SizedBox(width: AppDimens.spaceMd.w(context)),
        Icon(
          Icons.mode_comment_outlined,
          size: 20.r(context),
          color: AppColors.textPrimary,
        ),
      ],
    );
  }
}