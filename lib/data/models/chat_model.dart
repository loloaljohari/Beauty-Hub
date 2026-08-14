import 'package:equatable/equatable.dart';

/// A circular story avatar shown at the top of the Chats screen.
class StoryModel extends Equatable {
  const StoryModel({
    required this.id,
    required this.userName,
    this.avatarUrl,
    this.postedAt = '',
    this.isViewed = false,
  });

  final String id;
  final String userName;
  final String? avatarUrl;
  final String postedAt;
  final bool isViewed;

  @override
  List<Object?> get props => [id, userName, avatarUrl, postedAt, isViewed];
}

/// A single conversation entry in the Chats list.
class ChatModel extends Equatable {
  const ChatModel({
    required this.id,
    required this.userName,
    required this.lastMessage,
    required this.date,
    this.avatarUrl,
    this.unreadCount = 0,
  });

  final String id;
  final String userName;
  final String lastMessage;
  final String date;
  final String? avatarUrl;
  final int unreadCount;

  @override
  List<Object?> get props => [
        id,
        userName,
        lastMessage,
        date,
        avatarUrl,
        unreadCount,
      ];
}

/// A single chat bubble message within a conversation.
class MessageModel extends Equatable {
  const MessageModel({
    required this.id,
    required this.text,
    required this.isMine,
    this.timestamp = '',
    this.mediaUrl,
    this.type = 'text',
  });

  final String id;
  final String text;
  final bool isMine;
  final String timestamp;

  /// Absolute URL for image/file messages; null for plain text.
  final String? mediaUrl;

  /// `text` | `image` | `file`, straight from the server.
  final String type;

  bool get hasMedia => mediaUrl != null && mediaUrl!.isNotEmpty;

  @override
  List<Object?> get props => [id, text, isMine, timestamp, mediaUrl, type];
}
