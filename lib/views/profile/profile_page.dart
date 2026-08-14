import 'package:beautyhup/blocs/add_post/post_bloc.dart';
import '../../core/localization/l10n/app_localizations.dart';
import '../../core/utils/image_helpers.dart';
import 'package:beautyhup/blocs/add_service/add_service_bloc.dart';
import 'package:beautyhup/blocs/chats/chats_bloc.dart';
import 'package:beautyhup/blocs/chats/chats_event.dart';
import 'package:beautyhup/data/models/post_model.dart';
import 'package:beautyhup/data/models/settings_models.dart';
import 'package:beautyhup/views/update_service/update_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:story_view/controller/story_controller.dart';
import '../../blocs/nav/nav_bloc.dart';
import '../../blocs/nav/nav_state.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../blocs/profile/profile_event.dart';
import '../../blocs/profile/profile_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/route_names.dart';
import '../../core/utils/main_shell_scope.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/user_model.dart';
import '../../widgets/app_header.dart';
import '../../widgets/segmented_tab_bar.dart';
import '../../widgets/service_list_item.dart';
import 'postfeedpage.dart';

/// Unified owner Profile screen - merges the two Figma "Profile"
/// frames (personal info + Posts grid + editable Services list)
/// into a single screen, as agreed: every user sees the same
/// owner-style profile with both Posts and Services tabs.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileBloc()..add(const ProfileLoaded()),
      child: BlocListener<NavBloc, NavState>(
          listenWhen: (previous, current) =>
              previous.currentIndex != current.currentIndex &&
              current.currentIndex == 4,
          listener: (context, state) {
            // استدعاء تحديث البيانات فور كبس التاب رقم 3
            context.read<ProfileBloc>().add(ProfileLoaded());
          },
          child: const _ProfileView()),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: AppHeader(
            prof: true,
            onNotificationTap: () async {
              final value = await showMenu<String>(
                color: const Color.fromARGB(255, 220, 220, 225),
                context: context,
                position: RelativeRect.fill,
                items: [
                  PopupMenuItem(
                    value: "1",
                    onTap: () async {
                      await Navigator.of(context).pushNamed(RouteNames.addPost);
                      if (context.mounted) {
                        context.read<ProfileBloc>().add(const ProfileLoaded());
                      }
                    },
                    child: const Text("add post"),
                  ),
                  PopupMenuItem(
                    value: "2",
                    onTap: () async {
                      await Navigator.of(context)
                          .pushNamed(RouteNames.addStory);
                      if (context.mounted) {
                        // context.read<ChatsBloc>().add(ChatsLoaded( StoryController()));
                      }
                    },
                    child: const Text("add story"),
                  ),
                ],
              );

              if (value != null) {
                print(value);
              }
            },
            onMenuTap: () {
              print("STEP 1");

              final scope = MainShellScope.of(context);

              print("STEP 2");

              scope.openMenu();

              print("STEP 3");
            },
          )),
      floatingActionButton: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state.tabIndex != 1) return const SizedBox.shrink();
          return FloatingActionButton(
          // Unique tag: FABs default to a shared Hero tag, which
          // throws when two screens with one are on screen together.
          heroTag: 'profile_add_service_fab',
            backgroundColor: AppColors.primary,
            onPressed: () =>
                Navigator.of(context).pushNamed(RouteNames.addService),
            child: const Icon(Icons.add, color: AppColors.white),
          );
        },
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state.status != ProfileStatus.loaded || state.user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimens.screenPaddingH.w(context),
            ),
            children: [
              _ProfileHeader(
                user: state.user!,
                postsCount: state.posts.length,
              ),
              SizedBox(height: AppDimens.spaceSm.h(context)),
              _QuickAccessRow(),
              SizedBox(height: AppDimens.spaceMd.h(context)),
              SegmentedTabBar(
                labels: const ['Posts', 'Services'],
                selectedIndex: state.tabIndex,
                onChanged: (index) =>
                    context.read<ProfileBloc>().add(ProfileTabChanged(index)),
              ),
              SizedBox(height: AppDimens.spaceMd.h(context)),
              if (state.tabIndex == 0)
                _PostsGrid(
                    posts: state.posts,
                    userName: state.user!.name,
                    userRole: state.user!.typeOfWork,
                    // `avatarUrl!` crashed the whole Profile tab for
                    // any expert without a photo. It is nullable all
                    // the way down now, and the avatar widget falls
                    // back to a placeholder.
                    userAvatar: state.user!.avatarUrl)
              else
                Column(
                  children: [
                    for (final service in state.services)
                      ServiceListItem(
                        service: service,
                        onManageMaterials: () => Navigator.of(context)
                            .pushNamed(
                          RouteNames.serviceMaterials,
                          arguments: service.id,
                        ),
                        onEdit: () async {
                          final updated = await Navigator.of(context)
                              .push(MaterialPageRoute(
                            builder: (context) => BlocProvider(
                                create: (context) => AddServiceBloc(),
                                child: UpdateService(
                                  id: service.id,
                                )),
                          ));

                          if (updated == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("success ")),
                            );
                            context.read<ProfileBloc>().add(GetServicesEvent());
                          }
                        },
                        onDelete: () => context
                            .read<ProfileBloc>()
                            .add(ProfileServiceDeleted(service.id)),
                      ),
                  ],
                ),
              SizedBox(height: AppDimens.spaceXl.h(context)),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user, required this.postsCount});

  final SettingsProfileModel user;
  final int postsCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        user.avatarUrl != "null"
            ? CircleAvatar(
                radius: (AppDimens.avatarSizeLarge / 2).r(context),
                backgroundImage: remoteImageProvider(user.avatarUrl),
              )
            : CircleAvatar(
                radius: (AppDimens.avatarSizeLarge / 2).r(context),
                backgroundColor: AppColors.avatarPlaceholder,
              ),
        SizedBox(height: AppDimens.spaceSm.h(context)),
        Text(
          user.name,
          style: AppTextStyles.h3.copyWith(fontSize: 19.sp(context)),
        ),
        Text(
          user.typeOfWork,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 13.sp(context),
            color: AppColors.textSecondaryGrey,
          ),
        ),
        SizedBox(height: AppDimens.spaceSm.h(context)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StatItem(label: context.l10n.posts, value: '${postsCount}'),
            _StatDivider(),
            _StatItem(label: context.l10n.followers, value: '${user.followersCount}'),
            _StatDivider(),
            _StatItem(label: context.l10n.following, value: '${user.followingCount}'),
          ],
        ),
        SizedBox(height: AppDimens.spaceSm.h(context)),
        if (user.location.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on_outlined,
                  size: 14.r(context), color: AppColors.textSecondaryGrey),
              SizedBox(width: 4.w(context)),
              Flexible(
                child: Text(
                  user.location,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12.sp(context),
                    color: AppColors.textSecondaryGrey,
                  ),
                ),
              ),
            ],
          ),
        if (user.bio.isNotEmpty) ...[
          SizedBox(height: AppDimens.spaceXs.h(context)),
          Text(
            user.bio,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(fontSize: 13.sp(context)),
          ),
        ],
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDimens.spaceMd.w(context)),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.h3.copyWith(fontSize: 16.sp(context)),
          ),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11.sp(context),
              color: AppColors.textSecondaryGrey,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 28, color: AppColors.divider);
  }
}

/// Quick-access row linking to screens that don't have their own
/// bottom-nav tab: My Courses, and the seller-side Store Orders
/// (customer orders placed against this expert's own store).
class _QuickAccessRow extends StatelessWidget {
  const _QuickAccessRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickAccessButton(
            icon: Icons.school_outlined,
            label: context.l10n.myCourses,
            onTap: () => Navigator.of(context).pushNamed(RouteNames.myCourses),
          ),
        ),
        SizedBox(width: AppDimens.spaceSm.w(context)),
        Expanded(
          child: _QuickAccessButton(
            icon: Icons.receipt_long_outlined,
            label: context.l10n.storeOrders,
            onTap: () =>
                Navigator.of(context).pushNamed(RouteNames.sellerOrders),
          ),
        ),
      ],
    );
  }
}

class _QuickAccessButton extends StatelessWidget {
  const _QuickAccessButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: AppDimens.spaceSm.h(context),
          horizontal: AppDimens.spaceSm.w(context),
        ),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18.r(context), color: AppColors.primary),
            SizedBox(width: AppDimens.spaceXs.w(context)),
            Text(
              label,
              style: AppTextStyles.label.copyWith(fontSize: 13.sp(context)),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostsGrid extends StatelessWidget {
  const _PostsGrid(
      {required this.posts,
      required this.userName,
      required this.userRole,
      this.userAvatar});

  final List<PostModel> posts;
  final String userName;
  final String userRole;
  final String? userAvatar;

  @override
  Widget build(BuildContext context) {
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
        print(
            "Post image URL: ${posts[index].imageUrls.isNotEmpty ? posts[index].imageUrls[0] : 'No image'}");
        return posts[index].imageUrls[0] != null
            ? InkWell(
                onTap: () async {
                  await Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => PostFeedPage(
                        posts: posts,
                        initialIndex: index,
                        userName: userName,
                        userRole: userRole,
                        userAvatar: userAvatar,
                      ),
                    ),
                    (route) => route.isFirst,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.imagePlaceholder,
                    borderRadius: BorderRadius.circular(8),
                    image: _thumbnailFor(posts[index]),
                  ),
                  alignment: Alignment.center,
                  child: posts[index].imageUrls[0] != null
                      ? SizedBox()
                      : Icon(
                          Icons.image_outlined,
                          size: 24.r(context),
                          color: AppColors.textHint,
                        ),
                ),
              )
            : InkWell(
                onTap: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => PostFeedPage(
                        posts: posts,
                        initialIndex: index,
                        userName: userName,
                        userRole: userRole,
                        userAvatar: userAvatar,
                      ),
                    ),
                    (route) => route.isFirst,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.imagePlaceholder,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: posts[index].caption.isNotEmpty
                      ? Text(
                          posts[index].caption,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 12.sp(context),
                            color: AppColors.white,
                            backgroundColor: Colors.black45,
                          ),
                        )
                      : SizedBox.shrink(),
                ),
              );
      },
    );
  }
}

/// Grid thumbnail for a post, or `null` when the post has no usable
/// image so the placeholder colour shows through instead of a broken
/// image request.
DecorationImage? _thumbnailFor(PostModel post) {
  if (post.imageUrls.isEmpty) return null;

  final provider = remoteImageProvider(post.imageUrls.first);
  if (provider == null) return null;

  return DecorationImage(image: provider, fit: BoxFit.cover);
}
