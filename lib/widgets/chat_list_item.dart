import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/responsive.dart';
import '../core/utils/image_helpers.dart';
import '../data/models/chat_model.dart';
import '../data/repositories/chats_repository.dart';

import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';


/// Single row in the Chats list: avatar + name + last message + date.
class ChatListItem extends StatelessWidget {
  const ChatListItem({super.key, required this.chat, required this.onTap});

  final ChatModel chat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppDimens.spaceSm.h(context)),
        child: Row(
          children: [
                CircleAvatar(
            radius: (AppDimens.avatarSizeMedium / 2).r(context),
            backgroundColor: chat.avatarUrl == '' || chat.avatarUrl == null
                ? AppColors.primaryAccent
                : null,
            backgroundImage: chat.avatarUrl != ''
                ? remoteImageProvider(chat.avatarUrl)
                : null,
            child: Text(
              // في حال عدم وجود اسم أو صوره، نأخذ أول حرف أو حرف 'U'
              (chat.avatarUrl==null)
                  ? chat.userName[0].toUpperCase()
                  : '',
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white),
            ),
          ),
        
           
    
            SizedBox(width: AppDimens.spaceSm.w(context)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.userName,
                    style:
                        AppTextStyles.label.copyWith(fontSize: 15.sp(context)),
                  ),
                  SizedBox(height: 2.h(context)),
                  Text(
                    chat.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 13.sp(context),
                      color: AppColors.textSecondaryGrey,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              chat.date,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 11.sp(context),
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Circular story avatar shown at the top of the Chats screen.
class StoryAvatar extends StatelessWidget {
  const StoryAvatar({super.key, required this.story});

  final StoryModel story;

  @override
  Widget build(BuildContext context) {
    final size = AppDimens.avatarSizeLarge.r(context) * 0.7;
    return InkWell(
      onTap: () {
   Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryDisplayPage(
          userId: story.id,
          userName: story.userName,
          avatarUrl: story.avatarUrl,
        ),
      ),
    );      },
      child: Padding(
        padding: EdgeInsets.only(right: AppDimens.spaceSm.w(context)),
        child: Column(
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: story.isViewed
                      ? AppColors.divider
                      : AppColors.primaryAccent,
                  width: 2,
                ),
              ),
              padding: const EdgeInsets.all(2),
              child: CircleAvatar(
                backgroundColor: AppColors.avatarPlaceholder,
                backgroundImage: remoteImageProvider(story.avatarUrl),
              ),
            ),
            SizedBox(height: 4.h(context)),
            SizedBox(
              width: size,
              child: Text(
                story.userName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(fontSize: 11.sp(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



/// Full-screen story viewer for ONE provider's reel.
///
/// Everything here used to be hardcoded: an Unsplash photo, a
/// placeholder avatar, "Bariq Salon" and "منذ ساعتين". It now loads the
/// real reel from `GET /expert/discover/stories`, which returns live
/// stories grouped by author (expired and inactive rows are filtered
/// server-side, so nothing dead ever reaches this screen).
class StoryDisplayPage extends StatefulWidget {
  const StoryDisplayPage({
    super.key,
    required this.userId,
    this.userName = '',
    this.avatarUrl,
  });

  /// `providerType:providerId` for a followed provider, or `me` for the
  /// signed-in expert's own reel.
  final String userId;

  /// Shown in the header while the reel loads, so the name is not blank
  /// for the first frame.
  final String userName;
  final String? avatarUrl;

  @override
  State<StoryDisplayPage> createState() => _StoryDisplayPageState();
}

class _StoryDisplayPageState extends State<StoryDisplayPage> {
  final StoryController _storyController = StoryController();

  List<StoryItem> _items = const [];
  List<Map<String, dynamic>> _raw = const [];

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _storyController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      // `me` is the expert's own reel and has its own endpoint; anything
      // else is a followed provider.
      final result = widget.userId == 'me'
          ? await const ChatsRepository().getmystory(_storyController)
          : await const ChatsRepository()
              .getProviderStory(widget.userId, _storyController);

      if (!mounted) return;

      final rows = (result.isNotEmpty && result.first is List)
          ? (result.first as List)
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
          : <Map<String, dynamic>>[];

      final items = (result.length > 1 && result[1] is List)
          ? (result[1] as List).whereType<StoryItem>().toList()
          : <StoryItem>[];

      setState(() {
        _raw = rows;
        _items = items;
        _loading = false;
        _error = items.isEmpty ? 'لا توجد قصص لعرضها.' : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'تعذّر تحميل القصص.';
      });
    }
  }

  /// "منذ ساعتين" was a fixed string; this derives it from created_at.
  String get _postedAgo {
    if (_raw.isEmpty) return '';

    final createdAt = _raw.first['created_at']?.toString();
    final created = DateTime.tryParse(createdAt ?? '');
    if (created == null) return '';

    final diff = DateTime.now().difference(created);

    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            if (_loading)
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            else if (_error != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              )
            else
              StoryView(
                storyItems: _items,
                controller: _storyController,
                // `repeat: true` looped forever with no way out; closing
                // at the end is what every story UI does.
                repeat: false,
                onComplete: () => Navigator.of(context).maybePop(),
                onVerticalSwipeComplete: (direction) {
                  if (direction == Direction.down) {
                    Navigator.of(context).maybePop();
                  }
                },
              ),

            // Header sits above the reel, below the progress bar.
            Positioned(
              top: 20,
              left: 16,
              right: 16,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.avatarPlaceholder,
                    backgroundImage: (widget.avatarUrl != null &&
                            widget.avatarUrl!.isNotEmpty)
                        ? NetworkImage(widget.avatarUrl!)
                        : null,
                    child: (widget.avatarUrl == null ||
                            widget.avatarUrl!.isEmpty)
                        ? const Icon(Icons.person, color: Colors.white54)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.userName.isEmpty
                              ? 'قصة'
                              : widget.userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(blurRadius: 4, color: Colors.black54),
                            ],
                          ),
                        ),
                        if (_postedAgo.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            _postedAgo,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                              shadows: const [
                                Shadow(blurRadius: 4, color: Colors.black54),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close,
                        color: Colors.white, size: 28),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
