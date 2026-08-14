import 'package:flutter/material.dart';
import '../../core/localization/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/chat_detail/chat_detail_bloc.dart';
import '../../blocs/chat_detail/chat_detail_event.dart';
import '../../blocs/chat_detail/chat_detail_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/image_helpers.dart';
import '../../widgets/message_bubble.dart';
import '../../widgets/state_views.dart';

/// Individual chat conversation screen - matches Figma frame
/// "iPhone 16 - 2" (single chat with message bubbles + input field).
class ChatDetailPage extends StatelessWidget {
  const ChatDetailPage({super.key, required this.chatId});

  final String chatId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatDetailBloc()..add(ChatDetailLoaded(chatId)),
      child: const _ChatDetailView(),
    );
  }
}

class _ChatDetailView extends StatefulWidget {
  const _ChatDetailView();

  @override
  State<_ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends State<_ChatDetailView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send(BuildContext context) {
    if (_controller.text.trim().isEmpty) return;
    context.read<ChatDetailBloc>().add(ChatMessageSent(_controller.text));
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.textPrimary),
        title: BlocBuilder<ChatDetailBloc, ChatDetailState>(
          builder: (context, state) {
            return Row(
              children: [
                CircleAvatar(
                  radius: 18.r(context),
                  backgroundColor: AppColors.avatarPlaceholder,
                  backgroundImage: remoteImageProvider(state.avatarUrl),
                ),
                SizedBox(width: AppDimens.spaceSm.w(context)),
                Text(
                  state.userName,
                  style: AppTextStyles.label.copyWith(fontSize: 16.sp(context)),
                ),
              ],
            );
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: BlocConsumer<ChatDetailBloc, ChatDetailState>(
                listenWhen: (previous, current) =>
                    previous.sendStatus != current.sendStatus ||
                    previous.messages.length != current.messages.length,
                listener: (context, state) {
                  if (state.sendStatus == ChatSendStatus.failure &&
                      state.errorMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.errorMessage!)),
                    );
                  }

                  // Keep the newest message in view as the thread grows.
                  if (state.messages.isNotEmpty &&
                      _scrollController.hasClients) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!_scrollController.hasClients) return;
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                      );
                    });
                  }
                },
                builder: (context, state) {
                  if (state.status == ChatDetailStatus.loading ||
                      state.status == ChatDetailStatus.initial) {
                    return const LoadingState();
                  }

                  if (state.status == ChatDetailStatus.failure) {
                    return ErrorState(
                      message: state.errorMessage,
                      onRetry: () => context
                          .read<ChatDetailBloc>()
                          .add(ChatDetailLoaded(state.chatId)),
                    );
                  }

                  if (state.isEmpty) {
                    return EmptyState(
                      icon: Icons.chat_bubble_outline,
                      title: context.l10n.noMessagesYet,
                      message: context.l10n.sayHello,
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimens.screenPaddingH.w(context),
                      vertical: AppDimens.spaceSm.h(context),
                    ),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) =>
                        MessageBubble(message: state.messages[index]),
                  );
                },
              ),
            ),
            MessageInputBar(controller: _controller, onSend: _send ,text:'type a message'),
          ],
        ),
      ),
    );
  }
}

class MessageInputBar extends StatelessWidget {
  const MessageInputBar({required this.controller,  this.onSend, required this.text, this.service=false});
  final String text;
  final bool service;
  final TextEditingController controller;
  final void Function(BuildContext context)? onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal:service? 0: AppDimens.screenPaddingH.w(context),
        vertical: AppDimens.spaceSm.h(context),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: text,
                filled: true,
                fillColor: AppColors.inputBackground,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppDimens.spaceMd.w(context),
                  vertical: AppDimens.spaceSm.h(context),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(width: AppDimens.spaceXs.w(context)),
        service? SizedBox(): CircleAvatar(
            backgroundColor: AppColors.primary,
            radius: 22.r(context),
            child: IconButton(
              onPressed: () => onSend?.call(context),
              icon: const Icon(Icons.send, color: AppColors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
