import 'package:beautyhup/blocs/profile/profile_event.dart';
import '../../core/localization/l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/image_helpers.dart';
import 'package:beautyhup/core/utils/responsive.dart';
import 'package:beautyhup/views/edit_post/EditPost.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/profile/profile_bloc.dart';
import '../../blocs/profile/profile_state.dart';
import '../../data/models/post_model.dart';
import '../../data/repositories/profile_repository.dart';

class PostFeedPage extends StatefulWidget {
  final List<PostModel> posts; // قائمة المنشورات
  final int initialIndex; // رقم المنشور الذي تم الضغط عليه
  final String userName;
  final String userRole;
  final String? userAvatar;

  const PostFeedPage({
    super.key,
    required this.posts,
    required this.initialIndex,
    required this.userName,
    required this.userRole,
    this.userAvatar,
  });

  @override
  State<PostFeedPage> createState() => _PostFeedPageState();
}

class _PostFeedPageState extends State<PostFeedPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialIndex > 0) {
        _scrollController.jumpTo(widget.initialIndex * 480.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => ProfileRepository(),
      child: BlocProvider(
        create: (context) => ProfileBloc()..add(ProfileLoaded()),
        child: BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state.actionStatus == ProfileActionStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.l10n.postDeleted),
                ),
            
              );   Navigator.pop(context); // Close the PostFeedPage after deletion
              
            }
            else if (state.actionStatus == ProfileActionStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Failed to delete post'),
                ),
              );
            }
          },
          child:   Scaffold(
          appBar: AppBar(
            title: const Text(
              "Posts",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            elevation: 0.5,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: ListView.builder(
            controller: _scrollController,
            itemCount: widget.posts.length,
            itemBuilder: (context, index) {
              final post = widget.posts[index];
              return _buildInstagramPostCard(post, context);
            },
          ),
        ),
         
        ),
       ),
    );
  }

  Widget _buildInstagramPostCard(PostModel post, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            leading: CircleAvatar(
                radius: 20,
                backgroundImage: remoteImageProvider(widget.userAvatar)),
            title: Text(
              widget.userName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              widget.userRole,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            trailing: PopupMenuButton<String>(
              
              color: const Color.fromARGB(255, 237, 237, 243),
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'edit') {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Editpost(
                        id: post.id,
                        caption: post.caption ?? '',
                        // images: post.imageUrls,
                      ),
                    ),
                  );
                } 
                else if (value == 'delete') {
                  context
                      .read<ProfileBloc>()
                      .add(DeletePostEvent(postId: post.id));
                } 
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text(context.l10n.edit),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text(context.l10n.delete, style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            )),
        SizedBox(
          height: 300,
        
          child: ListView.separated(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: post.imageUrls.length,
            separatorBuilder: (_, __) => SizedBox(width: 3.w(context)),
            itemBuilder: (context, index) {
              final imageUrl = remoteImageUrl(post.imageUrls[index]);

              return Container(
                width: 300.w(context),
                color: AppColors.imagePlaceholder,
                child: imageUrl == null
                    ? const SizedBox.shrink()
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        // A dead image URL must not blow up the feed.
                        errorBuilder: (context, error, stack) => const Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.avatarPlaceholder,
                        ),
                        loadingBuilder: (context, child, progress) =>
                            progress == null
                                ? child
                                : const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                      ),
              );
            },
          ),
        ),
        Row(
          children: [
          TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.favorite_border),
                  label: Text('${post.likesCount}'),
                ),
           TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.mode_comment_outlined),
                  label: Text('${post.likesCount}'),
                ),
            TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.bookmark_border),
                  label: Text('${post.likesCount}'),
                ),
          ],
        ),
        if (post.caption != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 14),
                children: [
                  TextSpan(
                    text: '${widget.userName} ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: post.caption ?? '',
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        const Divider(height: 1, thickness: 0.8),
      ],
    );
  }
}

