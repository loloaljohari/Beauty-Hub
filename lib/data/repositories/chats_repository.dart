import 'dart:async';

import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';
import 'package:video_player/video_player.dart';

import '../../core/config/app_config.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_response.dart';
import '../../core/storage/storage_service.dart';
import '../../core/theme/app_colors_export.dart';
import '../models/chat_model.dart';
import 'discovery_repository.dart';

/// Chats and stories.
///
/// Chat endpoints are registered under four role prefixes with the
/// same shape; `ChatService` resolves the caller from the token, so
/// this app only ever calls the `expert` ones.
///
/// One rule from the backend worth knowing before debugging an empty
/// list: a provider may only open a conversation with a customer who
/// already follows them (`NOT_A_FOLLOWER`), and blocking in either
/// direction closes the conversation entirely.
class ChatsRepository {
  const ChatsRepository();

  // ── conversations ───────────────────────────────────────────────

  /// GET /expert/chats -> data.conversations, data.total_unread
  ///
  /// Row shape:
  ///   {chat_id, other:{type,id,name,photo}, unread_count,
  ///    last_message:{id,type,content,from_me,created_at}|null,
  ///    last_message_at}
  Future<List<ChatModel>> getChats({bool unreadOnly = false}) async {
    final response = await ApiClient.get(
      ApiEndpoints.chats,
      query: {if (unreadOnly) 'unread_only': 1},
    );

    final payload = ApiResponse.data(response);

    // Keep the badge in sync without a second request.
    await StorageService.saveUnreadChats(
      ApiResponse.asInt(payload['total_unread']),
    );

    return ApiResponse.asMapList(payload['conversations'])
        .map(_toChat)
        .toList();
  }

  /// GET /expert/chats/unread-count - for the nav badge.
  Future<int> getUnreadCount() async {
    final response = await ApiClient.get(ApiEndpoints.chatsUnreadCount);
    final count = ApiResponse.asInt(ApiResponse.data(response)['unread']);
    await StorageService.saveUnreadChats(count);
    return count;
  }

  /// GET /expert/chats/{id}/messages
  ///
  /// [afterId] turns this into a cheap poll: only newer messages come
  /// back, which is how the detail screen refreshes without refetching
  /// the whole history.
  Future<ChatThread> getMessages(
    Object chatId, {
    int? afterId,
    int limit = 50,
  }) async {
    final response = await ApiClient.get(
      ApiEndpoints.chatMessages(chatId),
      query: {
        if (afterId != null && afterId > 0) 'after_id': afterId,
        'limit': limit,
      },
    );

    final payload = ApiResponse.data(response);
    final other = ApiResponse.asMap(payload['other']);

    return ChatThread(
      chatId: ApiResponse.asString(payload['chat_id']),
      otherName: ApiResponse.asString(other['name']),
      otherPhoto: AppConfig.mediaUrl(
        ApiResponse.asStringOrNull(other['photo']),
      ),
      lastId: ApiResponse.asInt(payload['last_id']),
      messages: ApiResponse.asMapList(payload['messages'])
          .map((row) => MessageModel(
                id: ApiResponse.asString(row['id']),
                text: ApiResponse.asString(row['content']),
                isMine: ApiResponse.asBool(row['from_me']),
                timestamp: ApiResponse.asString(row['created_at']),
                mediaUrl: AppConfig.mediaUrl(
                  ApiResponse.asStringOrNull(row['media_url']),
                ),
                type: ApiResponse.asString(row['type'], fallback: 'text'),
              ))
          .toList(),
    );
  }

  /// POST /expert/chats/{id}/messages
  ///
  /// Sent as multipart because the endpoint also accepts an attachment;
  /// `message_type` is inferred by the server when omitted.
  Future<void> sendMessage(
    Object chatId, {
    String? content,
    String? mediaPath,
  }) async {
    await ApiClient.postMultipart(
      ApiEndpoints.chatMessages(chatId),
      fields: {
        if (content != null && content.isNotEmpty) 'content': content,
      },
      files: {
        if (mediaPath != null && mediaPath.isNotEmpty) 'media': mediaPath,
      },
    );
  }

  /// POST /expert/chats/{id}/read
  Future<void> markRead(Object chatId) async {
    await ApiClient.post(ApiEndpoints.markChatRead(chatId));
  }

  /// DELETE /expert/chats/{id}/messages/{messageId}
  Future<void> deleteMessage(Object chatId, Object messageId) async {
    await ApiClient.delete(
      ApiEndpoints.deleteChatMessage(chatId, messageId),
    );
  }

  /// POST /expert/chats/open - creates the conversation or returns the
  /// existing one for this pair.
  Future<String> openConversation({
    required String otherType,
    required int otherId,
  }) async {
    final response = await ApiClient.post(
      ApiEndpoints.openChat,
      body: {'other_type': otherType, 'other_id': otherId},
    );

    return ApiResponse.asString(ApiResponse.data(response)['chat_id']);
  }

  ChatModel _toChat(Map<String, dynamic> row) {
    final other = ApiResponse.asMap(row['other']);
    final last = ApiResponse.asMap(row['last_message']);

    return ChatModel(
      id: ApiResponse.asString(row['chat_id']),
      userName: ApiResponse.asString(other['name'], fallback: 'Unknown'),
      lastMessage: last.isEmpty
          ? ''
          : ApiResponse.asString(
              last['content'],
              // An attachment has no text body; showing nothing would
              // make the row look like an empty conversation.
              fallback: ApiResponse.asString(last['type']) == 'text'
                  ? ''
                  : 'Attachment',
            ),
      date: ApiResponse.asDate(row['last_message_at']),
      avatarUrl:
          AppConfig.mediaUrl(ApiResponse.asStringOrNull(other['photo'])),
      unreadCount: ApiResponse.asInt(row['unread_count']),
    );
  }

  // ── stories ─────────────────────────────────────────────────────
  // These are the expert's OWN stories (`GET /expert/getMyStories`).
  // There is no expert-side feed of other people's stories - that is a
  // customer endpoint - so the avatar row at the top of the screen can
  // only ever show this expert.

  /// Builds the `story_view` items alongside the raw rows the screen
  /// needs for its delete action.
  Future<List<dynamic>> getmystory(StoryController storyController) async {
    final response = await ApiClient.get(ApiEndpoints.myStories);
    final data = ApiResponse.paginated(response).isNotEmpty
        ? ApiResponse.paginated(response)
        : ApiResponse.list(response, 'stories');

    final items = <StoryItem>[];

    for (final raw in data) {
      final story = ApiResponse.asMap(raw);
      final mediaType = ApiResponse.asString(story['media_type']);
      final caption = ApiResponse.asStringOrNull(story['caption']);
      final mediaUrl =
          AppConfig.mediaUrl(ApiResponse.asStringOrNull(story['media_url']));

      if (mediaType == 'video' && mediaUrl != null) {
        var duration = Duration.zero;
        final controller =
            VideoPlayerController.networkUrl(Uri.parse(mediaUrl));
        try {
          await controller.initialize();
          duration = controller.value.duration;
        } catch (_) {
          // A broken video must not abort the whole story reel.
        } finally {
          await controller.dispose();
        }

        items.add(
          StoryItem.pageVideo(
            mediaUrl,
            controller: storyController,
            duration: duration,
            caption: caption == null
                ? const SizedBox()
                : Text(
                    caption,
                    style: const TextStyle(color: Colors.white),
                  ),
          ),
        );
      } else if (mediaType == 'image' && mediaUrl != null) {
        items.add(
          StoryItem.pageImage(
            url: mediaUrl,
            controller: storyController,
            caption: Text(caption ?? ''),
          ),
        );
      } else {
        items.add(
          StoryItem.text(
            title: caption ?? '',
            backgroundColor: const Color(0xFF6A1B29),
            textStyle: const TextStyle(
              fontSize: 25,
              color: Colors.white,
              fontFamily: AppTextStyles.fontFamilyDisplay,
            ),
          ),
        );
      }
    }

    return [data, items];
  }

  /// The row of story avatars: the expert first, then every provider
  /// they follow who has a live story.
  ///
  /// The followed-provider half comes from
  /// `GET /expert/discover/stories`. Before that endpoint existed only
  /// the expert's own avatar could appear, because there was no
  /// expert-side way to read anyone else's stories.
  Future<List<StoryModel>> getStories() async {
    final stories = <StoryModel>[];

    final summary = await StorageService.getUserSummary();
    final name = summary['name'];

    if (name != null && name.isNotEmpty) {
      stories.add(
        StoryModel(
          id: 'me',
          userName: name,
          avatarUrl: AppConfig.mediaUrl(summary['photo']),
        ),
      );
    }

    try {
      final groups = await const DiscoveryRepository().getStories();

      stories.addAll(
        groups.map(
          (group) => StoryModel(
            // Prefixed so the id can never collide with 'me' and the
            // screen can tell whose reel to open.
            id: '${group.providerType}:${group.providerId}',
            userName: group.name,
            avatarUrl: group.avatarUrl,
            postedAt: group.items.isEmpty ? '' : group.items.first.createdAt,
          ),
        ),
      );
    } on ApiException catch (e) {
      // Older backends have no discovery routes; the expert's own
      // avatar is still worth showing.
      if (!e.isNotFound) rethrow;
    } catch (_) {
      // Never let the stories strip take down the chats screen.
    }

    return stories;
  }

  /// Story reel for one followed provider, keyed by the id produced in
  /// [getStories] (`providerType:providerId`).
  ///
  /// Returns `[rawRows, storyItems]` to match the shape
  /// [getmystory] already returns, so the viewer widget is unchanged.
  Future<List<dynamic>> getProviderStory(
    String groupId,
    StoryController storyController,
  ) async {
    final groups = await const DiscoveryRepository().getStories();

    final group = groups
        .where((g) => '${g.providerType}:${g.providerId}' == groupId)
        .toList();

    if (group.isEmpty) return [const [], <StoryItem>[]];

    final items = <StoryItem>[];
    final raw = <Map<String, dynamic>>[];

    for (final story in group.first.items) {
      raw.add({
        'id': story.id,
        'media_type': story.mediaType,
        'media_url': story.mediaUrl,
        'caption': story.caption,
      });

      if (story.mediaType == 'video' && story.mediaUrl != null) {
        var duration = Duration.zero;
        final controller =
            VideoPlayerController.networkUrl(Uri.parse(story.mediaUrl!));
        try {
          await controller.initialize();
          duration = controller.value.duration;
        } catch (_) {
          // A broken video must not abort the reel.
        } finally {
          await controller.dispose();
        }

        items.add(
          StoryItem.pageVideo(
            story.mediaUrl!,
            controller: storyController,
            duration: duration,
            caption: story.caption.isEmpty
                ? const SizedBox()
                : Text(
                    story.caption,
                    style: const TextStyle(color: Colors.white),
                  ),
          ),
        );
      } else if (story.mediaType == 'image' && story.mediaUrl != null) {
        items.add(
          StoryItem.pageImage(
            url: story.mediaUrl!,
            controller: storyController,
            caption: Text(story.caption),
          ),
        );
      } else {
        items.add(
          StoryItem.text(
            title: story.caption,
            backgroundColor: const Color(0xFF6A1B29),
            textStyle: const TextStyle(
              fontSize: 25,
              color: Colors.white,
              fontFamily: AppTextStyles.fontFamilyDisplay,
            ),
          ),
        );
      }

      // Best-effort view count; never blocks playback.
      unawaited(_markViewed(story.id));
    }

    return [raw, items];
  }

  Future<void> _markViewed(Object storyId) async {
    try {
      await const DiscoveryRepository().markStoryViewed(storyId);
    } catch (_) {}
  }

  /// DELETE /expert/deleteStory/{id}
  Future<void> deleteStory(Object id) async {
    await ApiClient.delete(ApiEndpoints.deleteStory(id));
  }

  /// Kept for the existing call sites that use the old capitalised name.
  Future<void> DeleteStory(Object id) => deleteStory(id);
}

/// One conversation's messages plus who it is with.
class ChatThread {
  const ChatThread({
    this.chatId = '',
    this.otherName = '',
    this.otherPhoto,
    this.messages = const [],
    this.lastId = 0,
  });

  final String chatId;
  final String otherName;
  final String? otherPhoto;
  final List<MessageModel> messages;

  /// Highest message id received - pass back as `after_id` to poll.
  final int lastId;
}
