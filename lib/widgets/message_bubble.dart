import 'package:flutter/material.dart';
import '../core/localization/l10n/app_localizations.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/responsive.dart';
import '../data/models/chat_model.dart';

/// Single chat bubble, aligned right (mine) or left (theirs).
class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message});

  final MessageModel message;

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: AppDimens.spaceXxs.h(context)),
          padding: EdgeInsets.symmetric(
            horizontal: AppDimens.spaceMd.w(context),
            vertical: AppDimens.spaceSm.h(context),
          ),
          decoration: BoxDecoration(
            color: isMine ? AppColors.primary : AppColors.inputBackground,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMine ? 16 : 4),
              bottomRight: Radius.circular(isMine ? 4 : 16),
            ),
          ),
          child: Column(
            crossAxisAlignment:
                isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image and file messages carry a media_url and often no
              // text at all, so the attachment gets rendered first.
              if (message.hasMedia) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: message.type == 'image'
                      ? Image.network(
                          message.mediaUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.broken_image_outlined,
                            color: isMine
                                ? AppColors.white
                                : AppColors.avatarPlaceholder,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.attach_file,
                              size: 18.r(context),
                              color:
                                  isMine ? AppColors.white : AppColors.black,
                            ),
                            SizedBox(width: AppDimens.spaceXxs.w(context)),
                            Text(
                              context.l10n.attachment,
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 13.sp(context),
                                color: isMine
                                    ? AppColors.white
                                    : AppColors.black,
                              ),
                            ),
                          ],
                        ),
                ),
                if (message.text.isNotEmpty)
                  SizedBox(height: AppDimens.spaceXxs.h(context)),
              ],
              if (message.text.isNotEmpty)
                Text(
                  message.text,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 14.sp(context),
                    color: isMine ? AppColors.white : AppColors.black,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
