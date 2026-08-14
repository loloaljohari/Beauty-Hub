import 'package:equatable/equatable.dart';

abstract class ChatDetailEvent extends Equatable {
  const ChatDetailEvent();

  @override
  List<Object?> get props => [];
}

class ChatDetailLoaded extends ChatDetailEvent {
  const ChatDetailLoaded(this.chatId);

  final String chatId;

  @override
  List<Object?> get props => [chatId];
}

/// [mediaPath] is a local file path; the endpoint accepts images,
/// PDFs, mp4 and mp3 up to 10 MB.
class ChatMessageSent extends ChatDetailEvent {
  const ChatMessageSent(this.text, {this.mediaPath});

  final String text;
  final String? mediaPath;

  @override
  List<Object?> get props => [text, mediaPath];
}

/// Fired on a timer; fetches only messages newer than the last seen id.
class ChatMessagesPolled extends ChatDetailEvent {
  const ChatMessagesPolled();
}

class ChatMessageDeleted extends ChatDetailEvent {
  const ChatMessageDeleted(this.messageId);

  final String messageId;

  @override
  List<Object?> get props => [messageId];
}
