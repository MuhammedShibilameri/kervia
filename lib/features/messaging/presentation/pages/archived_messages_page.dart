import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/kervia_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/datasources/messaging_remote_data_source.dart';
import '../../domain/entities/chat_entities.dart';
import 'managed_conversation_tile.dart';

class ArchivedMessagesPage extends StatefulWidget {
  final String userId;
  final String displayName;

  const ArchivedMessagesPage({
    super.key,
    required this.userId,
    required this.displayName,
  });

  @override
  State<ArchivedMessagesPage> createState() => _ArchivedMessagesPageState();
}

class _ArchivedMessagesPageState extends State<ArchivedMessagesPage> {
  final MessagingRemoteDataSource _dataSource = MessagingRemoteDataSourceImpl();
  List<ConversationEntity> _conversations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _dataSource.getArchivedConversations(widget.userId);
    if (!mounted) return;
    setState(() {
      _conversations = list;
      _loading = false;
    });
  }

  String _timeLabel(String updatedAt) {
    final parsed = DateTime.tryParse(updatedAt);
    if (parsed == null) return '';
    final diff = DateTime.now().difference(parsed.toLocal());
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${parsed.day}-${parsed.month}-${parsed.year}';
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
        title: Text(
          context.tr('Archived Messages'),
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : _conversations.isEmpty
                ? _buildEmpty(context)
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _conversations.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final c = _conversations[index];
                      return ManagedConversationTile(
                        conversation: c,
                        myUserId: widget.userId,
                        displayName: widget.displayName,
                        timeLabel: _timeLabel(c.updatedAt),
                        fallbackTitle: context.tr('Restore'),
                        fallbackIcon: Icons.unarchive_outlined,
                        fallbackValue: 'restore',
                        onFallback: () async {
                        await _dataSource.archiveConversation(c.id,
                            widget.userId, archive: false);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.tr('Restored to inbox.')),
                            backgroundColor: AppColors.primary,
                            duration: const Duration(milliseconds: 1200),
                          ),
                        );
                        _load();
                      },
                        onDelete: () => _deleteConversation(c),
                        onRefresh: _load,
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 44, color: AppColors.textMuted),
            const SizedBox(height: 14),
            Text(
              context.tr('No archived conversations.'),
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              context.tr(
                  'When you archive a conversation it will appear here so you can restore it.'),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteConversation(ConversationEntity c) async {
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
    await _dataSource.deleteConversation(c.id, widget.userId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.tr('Conversation deleted.')),
        backgroundColor: AppColors.primary,
        duration: const Duration(milliseconds: 1200),
      ),
    );
    _load();
  }
}