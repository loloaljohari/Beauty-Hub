import 'package:equatable/equatable.dart';
import '../../data/models/chat_model.dart';

enum ChatDetailStatus { initial, loading, loaded, failure }

enum ChatSendStatus { idle, sending, sent, failure }

class ChatDetailState extends Equatable {
  const ChatDetailState({
    this.chatId = '',
    this.userName = '',
    this.avatarUrl,
    this.messages = const [],
    this.status = ChatDetailStatus.initial,
    this.sendStatus = ChatSendStatus.idle,
    this.lastId = 0,
    this.errorMessage,
  });

  final String chatId;
  final String userName;
  final String? avatarUrl;
  final List<MessageModel> messages;
  final ChatDetailStatus status;
  final ChatSendStatus sendStatus;

  /// Highest message id seen; sent back as `after_id` when polling so
  /// only new messages are transferred.
  final int lastId;
  final String? errorMessage;

  bool get isEmpty =>
      status == ChatDetailStatus.loaded && messages.isEmpty;

  ChatDetailState copyWith({
    String? chatId,
    String? userName,
    String? avatarUrl,
    List<MessageModel>? messages,
    ChatDetailStatus? status,
    ChatSendStatus? sendStatus,
    int? lastId,
    String? errorMessage,
  }) {
    return ChatDetailState(
      chatId: chatId ?? this.chatId,
      userName: userName ?? this.userName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      messages: messages ?? this.messages,
      status: status ?? this.status,
      sendStatus: sendStatus ?? this.sendStatus,
      lastId: lastId ?? this.lastId,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        chatId,
        userName,
        avatarUrl,
        messages,
        status,
        sendStatus,
        lastId,
        errorMessage,
      ];
}
