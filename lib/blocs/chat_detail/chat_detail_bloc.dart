import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import '../../data/models/chat_model.dart';
import '../../data/repositories/chats_repository.dart';
import 'chat_detail_event.dart';
import 'chat_detail_state.dart';

class ChatDetailBloc extends Bloc<ChatDetailEvent, ChatDetailState> {
  ChatDetailBloc({ChatsRepository? repository})
      : _repository = repository ?? const ChatsRepository(),
        super(const ChatDetailState()) {
    on<ChatDetailLoaded>(_onLoaded);
    on<ChatMessageSent>(_onMessageSent);
    on<ChatMessagesPolled>(_onPolled);
    on<ChatMessageDeleted>(_onMessageDeleted);
  }

  final ChatsRepository _repository;
  Timer? _poll;

  Future<void> _onLoaded(
    ChatDetailLoaded event,
    Emitter<ChatDetailState> emit,
  ) async {
    emit(state.copyWith(
      status: ChatDetailStatus.loading,
      chatId: event.chatId,
      errorMessage: null,
    ));

    try {
      final thread = await _repository.getMessages(event.chatId);

      emit(state.copyWith(
        chatId: thread.chatId.isEmpty ? event.chatId : thread.chatId,
        userName: thread.otherName,
        avatarUrl: thread.otherPhoto,
        messages: thread.messages,
        lastId: thread.lastId,
        status: ChatDetailStatus.loaded,
      ));

      // Opening a conversation is what marks it read server-side.
      unawaited(_markReadQuietly(event.chatId));
      _startPolling();
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: ChatDetailStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: ChatDetailStatus.failure,
        errorMessage: 'Could not open this conversation.',
      ));
    }
  }

  /// There is no websocket in this backend, but `after_id` makes a
  /// short poll cheap: only messages newer than [state.lastId] come
  /// back, so this is a few bytes rather than the whole history.
  void _startPolling() {
    _poll?.cancel();
    _poll = Timer.periodic(
      const Duration(seconds: 8),
      (_) => add(const ChatMessagesPolled()),
    );
  }

  Future<void> _onPolled(
    ChatMessagesPolled event,
    Emitter<ChatDetailState> emit,
  ) async {
    if (state.chatId.isEmpty) return;

    try {
      final thread = await _repository.getMessages(
        state.chatId,
        afterId: state.lastId,
      );

      if (thread.messages.isEmpty) return;

      emit(state.copyWith(
        messages: [...state.messages, ...thread.messages],
        lastId: thread.lastId,
      ));

      unawaited(_markReadQuietly(state.chatId));
    } catch (_) {
      // A failed poll is not worth interrupting the conversation for.
    }
  }

  Future<void> _onMessageSent(
    ChatMessageSent event,
    Emitter<ChatDetailState> emit,
  ) async {
    final text = event.text.trim();
    if (text.isEmpty && (event.mediaPath == null || event.mediaPath!.isEmpty)) {
      return;
    }

    // Optimistic bubble so the input feels instant; replaced by the
    // server's copy on the refresh below.
    final pendingId = 'local_${DateTime.now().microsecondsSinceEpoch}';
    emit(state.copyWith(
      messages: [
        ...state.messages,
        MessageModel(id: pendingId, text: text, isMine: true),
      ],
      sendStatus: ChatSendStatus.sending,
    ));

    try {
      await _repository.sendMessage(
        state.chatId,
        content: text.isEmpty ? null : text,
        mediaPath: event.mediaPath,
      );

      final thread = await _repository.getMessages(
        state.chatId,
        afterId: state.lastId,
      );

      emit(state.copyWith(
        messages: [
          ...state.messages.where((m) => m.id != pendingId),
          ...thread.messages,
        ],
        lastId: thread.lastId,
        sendStatus: ChatSendStatus.sent,
      ));
    } on ApiException catch (e) {
      // Drop the optimistic bubble - pretending it sent would be worse
      // than showing the error.
      emit(state.copyWith(
        messages: state.messages.where((m) => m.id != pendingId).toList(),
        sendStatus: ChatSendStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        messages: state.messages.where((m) => m.id != pendingId).toList(),
        sendStatus: ChatSendStatus.failure,
        errorMessage: 'Message not sent. Check your connection.',
      ));
    }
  }

  Future<void> _onMessageDeleted(
    ChatMessageDeleted event,
    Emitter<ChatDetailState> emit,
  ) async {
    final previous = state.messages;

    emit(state.copyWith(
      messages: previous.where((m) => m.id != event.messageId).toList(),
    ));

    try {
      await _repository.deleteMessage(state.chatId, event.messageId);
    } on ApiException catch (e) {
      emit(state.copyWith(messages: previous, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(
        messages: previous,
        errorMessage: 'Could not delete this message.',
      ));
    }
  }

  Future<void> _markReadQuietly(String chatId) async {
    try {
      await _repository.markRead(chatId);
    } catch (_) {
      // Read receipts are not worth surfacing a failure for.
    }
  }

  @override
  Future<void> close() {
    _poll?.cancel();
    return super.close();
  }
}
