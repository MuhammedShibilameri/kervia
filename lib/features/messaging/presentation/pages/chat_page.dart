import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/kervia_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/datasources/messaging_remote_data_source.dart';
import '../../domain/entities/chat_entities.dart';

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

  const ChatPage({
    super.key,
    required this.userId,
    required this.displayName,
    this.otherUserId,
    this.otherName,
    this.conversation,
    this.canInitiate = false,
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
        title: Row(
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

  const _MessageBubble({
    required this.mine,
    required this.text,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
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
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.4,
                color: mine ? Colors.white : AppColors.textPrimary,
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
          ],
        ),
      ),
    );
  }
}