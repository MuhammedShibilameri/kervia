import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/kervia_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/chat_entities.dart';
import 'chat_page.dart';

class ManagedConversationTile extends StatelessWidget {
  final ConversationEntity conversation;
  final String myUserId;
  final String displayName;
  final String timeLabel;
  final String fallbackTitle;
  final IconData fallbackIcon;
  final String fallbackValue;
  final VoidCallback onFallback;
  final VoidCallback onDelete;
  final VoidCallback onRefresh;

  const ManagedConversationTile({
    super.key,
    required this.conversation,
    required this.myUserId,
    required this.displayName,
    required this.timeLabel,
    required this.fallbackTitle,
    required this.fallbackIcon,
    required this.fallbackValue,
    required this.onFallback,
    required this.onDelete,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final otherName = conversation.nameFor(myUserId);
    final initial = otherName.isNotEmpty ? otherName[0].toUpperCase() : '?';
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatPage(
                userId: myUserId,
                displayName: displayName,
                conversation: conversation,
                fromArchive: fallbackValue == 'restore',
                fromSpam: fallbackValue == 'unspam',
                onChanged: onRefresh,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primarySoft,
                child: Text(
                  initial,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      otherName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      conversation.lastMessage.isEmpty
                          ? context.tr('Say hello to start the chat.')
                          : conversation.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Text(
                timeLabel,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: AppColors.textMuted),
                color: AppColors.surface,
                onSelected: (value) {
                  if (value == 'fallback') {
                    onFallback();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'fallback',
                    child: Row(
                      children: [
                        Icon(fallbackIcon, size: 20),
                        const SizedBox(width: 12),
                        Text(fallbackTitle),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline, size: 20),
                        const SizedBox(width: 12),
                        Text(context.tr('Delete')),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}