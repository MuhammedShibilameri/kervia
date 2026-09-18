import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/kervia_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/datasources/messaging_remote_data_source.dart';
import '../../domain/entities/chat_entities.dart';
import 'other_user_profile_page.dart';

class ChatPage extends StatefulWidget {
  final String userId;
  final String displayName;
  final String? otherUserId;
  final String? otherName;
  final ConversationEntity? conversation;

  /// When true the user starts conversations themselves (companies only).
  /// Job seekers must receive the first message from the company before they
  /// can reply, so they pass false.
  final bool canInitiate;

  /// True when this chat was opened from the Archive page (Restore shown).
  final bool fromArchive;

  /// True when this chat was opened from the Spam (reported) page.
  final bool fromSpam;

  /// Called after the conversation is deleted, archived, unarchived, spammed
  /// or unspammed so the parent list can reload.
  final VoidCallback? onChanged;

  const ChatPage({
    super.key,
    required this.userId,
    required this.displayName,
    this.otherUserId,
    this.otherName,
    this.conversation,
    this.canInitiate = false,
    this.fromArchive = false,
    this.fromSpam = false,
    this.onChanged,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final MessagingRemoteDataSource _dataSource = MessagingRemoteDataSourceImpl();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late String _conversationId;
  bool _ready = false;
  bool _sending = false;
  bool _started = false;

  String get _otherName =>
      widget.otherName ?? widget.conversation?.nameFor(widget.userId) ?? '';

  String? get _otherUserId =>
      widget.otherUserId ??
      (widget.conversation != null
          ? (widget.conversation!.userAId == widget.userId
              ? widget.conversation!.userBId
              : widget.conversation!.userAId)
          : null);

  bool get _canSend => _ready && (_started || widget.canInitiate);

  @override
  void initState() {
    super.initState();
    _started = widget.conversation != null;
    _conversationId = widget.conversation?.id ??
        MessagingRemoteDataSourceImpl.conversationIdFor(
            widget.userId,
            widget.otherUserId ?? 'other');
    _prepare();
  }

  Future<void> _prepare() async {
    if (!mounted) return;
    setState(() => _ready = true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await _dataSource.sendMessage(
        conversationId: _conversationId,
        senderId: widget.userId,
        text: text,
        allowCreate: widget.canInitiate && !_started,
        otherUserId: widget.otherUserId,
        senderName: widget.displayName,
        otherName: _otherName,
      );
      _controller.clear();
      if (!_started) setState(() => _started = true);
    } on ConversationNotStartedException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr(
                'You can only reply after the company has messaged you first.')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('Could not send message. Try again.')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
    if (mounted) setState(() => _sending = false);
  }

  void _onMenuSelected(String value) {
    switch (value) {
      case 'archive':
        _setArchive(true);
        break;
      case 'restore':
        _setArchive(false);
        break;
      case 'spam':
        _markSpam();
        break;
      case 'unspam':
        _unspam();
        break;
      case 'delete':
        _confirmDelete();
        break;
    }
  }

  Future<void> _setArchive(bool archive) async {
    try {
      await _dataSource.archiveConversation(
        _conversationId,
        widget.userId,
        archive: archive,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Conversation archived.')),
          backgroundColor: AppColors.primary,
          duration: const Duration(milliseconds: 1200),
        ),
      );
      widget.onChanged?.call();
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Could not archive the conversation.')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _markSpam() async {
    try {
      await _dataSource.spamConversation(_conversationId, widget.userId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Reported as spam.')),
          backgroundColor: AppColors.primary,
          duration: const Duration(milliseconds: 1200),
        ),
      );
      widget.onChanged?.call();
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Could not report the conversation.')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _unspam() async {
    try {
      await _dataSource.unspamConversation(_conversationId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Unspammed.')),
          backgroundColor: AppColors.primary,
          duration: const Duration(milliseconds: 1200),
        ),
      );
      widget.onChanged?.call();
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Could not update the conversation.')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          context.tr('Delete conversation?'),
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          context.tr(
              'This removes the conversation from your messages. The other person can still see it.'),
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              context.tr('Cancel'),
              style: GoogleFonts.inter(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              context.tr('Delete'),
              style: GoogleFonts.inter(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await _dataSource.deleteConversation(_conversationId, widget.userId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Conversation deleted.')),
          backgroundColor: AppColors.primary,
          duration: const Duration(milliseconds: 1200),
        ),
      );
      widget.onChanged?.call();
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Could not delete the conversation.')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showMessageActions(MessageEntity message) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.edit_outlined, color: AppColors.primary),
              title: Text(
                context.tr('Edit'),
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                _editMessage(message);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: AppColors.error),
              title: Text(
                context.tr('Delete'),
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                _deleteMessage(message);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _editMessage(MessageEntity message) async {
    final controller = TextEditingController(text: message.text);
    final newText = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          context.tr('Edit message'),
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: context.tr('Type a message…'),
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              context.tr('Cancel'),
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: Text(
              context.tr('Save'),
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
    controller.dispose();
    final trimmed = newText?.trim() ?? '';
    if (trimmed.isEmpty || trimmed == message.text) return;
    try {
      await _dataSource.editMessage(
        conversationId: _conversationId,
        messageId: message.id,
        text: trimmed,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('Could not edit the message.')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteMessage(MessageEntity message) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          context.tr('Delete message'),
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        content: Text(
          context.tr('This message will be removed for everyone.'),
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              context.tr('Cancel'),
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              context.tr('Delete'),
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _dataSource.deleteMessage(
        conversationId: _conversationId,
        messageId: message.id,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('Could not delete the message.')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _timeLabel(String timestamp) {
    final parsed = DateTime.tryParse(timestamp);
    if (parsed == null) return '';
    final t = parsed.toLocal();
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m ${t.hour < 12 ? 'am' : 'pm'}';
  }

  @override
  Widget build(BuildContext context) {
    context.adaptive();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.textPrimary),
            color: AppColors.surface,
            onSelected: _onMenuSelected,
            itemBuilder: (context) => widget.fromArchive
                ? [
                    PopupMenuItem(
                      value: 'restore',
                      child: Row(
                        children: [
                          const Icon(Icons.unarchive_outlined, size: 20),
                          const SizedBox(width: 12),
                          Text(context.tr('Restore')),
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
                  ]
                : widget.fromSpam
                    ? [
                        PopupMenuItem(
                          value: 'unspam',
                          child: Row(
                            children: [
                              const Icon(Icons.forward_to_inbox_outlined,
                                  size: 20),
                              const SizedBox(width: 12),
                              Text(context.tr('Unspam')),
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
                      ]
                    : [
                        PopupMenuItem(
                          value: 'archive',
                          child: Row(
                            children: [
                              const Icon(Icons.archive_outlined, size: 20),
                              const SizedBox(width: 12),
                              Text(context.tr('Archive')),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'spam',
                          child: Row(
                            children: [
                              const Icon(Icons.report_outlined, size: 20),
                              const SizedBox(width: 12),
                              Text(context.tr('Spam')),
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
          const SizedBox(width: 4),
        ],
        title: InkWell(
          onTap: _otherUserId == null || _otherUserId!.isEmpty
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OtherUserProfilePage(
                        otherUserId: _otherUserId!,
                        otherName: _otherName,
                      ),
                    ),
                  );
                },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primarySoft,
                  child: Text(
                    _otherName.isNotEmpty
                        ? _otherName[0].toUpperCase()
                        : '?',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _otherName.isNotEmpty ? _otherName : context.tr('Chat'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: !_ready
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : Column(
                children: [
                  Expanded(
                    child: StreamBuilder<List<MessageEntity>>(
                      stream: _dataSource.watchMessages(_conversationId),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              context.tr('Could not load messages.'),
                              style: GoogleFonts.inter(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          );
                        }
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          );
                        }
                        final messages = snapshot.data!;
                        if (messages.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.waving_hand_outlined,
                                  size: 40,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _canSend
                                      ? context
                                          .tr('No messages yet. Send the first message to start the conversation!')
                                      : context.tr(
                                          'The company will send you the first message here.'),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_scrollController.hasClients) {
                            _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                            );
                          }
                        });
                        return ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            return _MessageBubble(
                              mine: message.senderId == widget.userId,
                              text: message.text,
                              time: _timeLabel(message.timestamp),
                              edited: message.edited,
                              deleted: message.deleted,
                              onLongPress:
                                  message.senderId == widget.userId &&
                                          !message.deleted
                                      ? () => _showMessageActions(message)
                                      : null,
                            );
                          },
                        );
                      },
                    ),
                  ),
                  _canSend
                      ? _buildComposer(context)
                      : _buildLockedHint(context),
                ],
              ),
      ),
    );
  }

  Widget _buildLockedHint(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.tr(
                  'You can reply here once the company sends you a message.'),
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComposer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: context.tr('Type a message…'),
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
                isDense: true,
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
              onSubmitted: (_) => _send(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _sending ? null : _send,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            icon: _sending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final bool mine;
  final String text;
  final String time;
  final bool edited;
  final bool deleted;
  final VoidCallback? onLongPress;

  const _MessageBubble({
    required this.mine,
    required this.text,
    required this.time,
    this.edited = false,
    this.deleted = false,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          constraints: const BoxConstraints(maxWidth: 300),
          decoration: BoxDecoration(
            color: mine ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(mine ? 18 : 4),
              bottomRight: Radius.circular(mine ? 4 : 18),
            ),
            border: mine ? null : Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                deleted ? context.tr('This message was deleted') : text,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.4,
                  fontStyle: deleted ? FontStyle.italic : FontStyle.normal,
                  color: mine
                      ? Colors.white.withValues(alpha: deleted ? 0.7 : 1)
                      : (deleted ? AppColors.textMuted : AppColors.textPrimary),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: mine
                      ? Colors.white.withValues(alpha: 0.8)
                      : AppColors.textMuted,
                ),
              ),
              if (edited && !deleted) ...[
                const SizedBox(height: 2),
                Text(
                  context.tr('Edited'),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                    color: mine
                        ? Colors.white.withValues(alpha: 0.7)
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}