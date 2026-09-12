import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/kervia_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/datasources/messaging_remote_data_source.dart';
import '../../domain/entities/chat_entities.dart';
import 'chat_page.dart';

class MessagesPage extends StatefulWidget {
  final String userId;
  final String displayName;

  /// When true the user can start new conversations with anyone
  /// (companies). Job seekers can only see and reply to conversations the
  /// company started, so they pass false and the "New message" action is
  /// hidden.
  final bool canInitiate;

  const MessagesPage({
    super.key,
    required this.userId,
    required this.displayName,
    this.canInitiate = false,
  });

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final MessagingRemoteDataSource _dataSource = MessagingRemoteDataSourceImpl();
  List<ConversationEntity> _conversations = [];
  final List<({String id, String name})> _contacts = [];
  bool _loading = true;

  static FirebaseFirestore? _db() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _dataSource.getConversations(widget.userId);
    await _loadContacts();
    if (!mounted) return;
    setState(() {
      _conversations = list;
      _loading = false;
    });
  }

  Future<void> _loadContacts() async {
    final db = _db();
    if (db == null) return;
    final seen = <String>{};
    final contacts = <({String id, String name})>[];
    try {
      final myApps = await db
          .collection('applications')
          .where('userId', isEqualTo: widget.userId)
          .get();
      for (final doc in myApps.docs) {
        final data = doc.data();
        final id = (data['companyId'] as String?) ?? '';
        final name = (data['companyName'] as String?) ?? '';
        if (id.isNotEmpty && seen.add(id)) {
          contacts.add((id: id, name: name.isEmpty ? 'Employer' : name));
        }
      }
      final theirApps = await db
          .collection('applications')
          .where('companyId', isEqualTo: widget.userId)
          .get();
      for (final doc in theirApps.docs) {
        final data = doc.data();
        final id = (data['userId'] as String?) ?? '';
        final name = (data['candidateName'] as String?) ?? '';
        if (id.isNotEmpty && seen.add(id)) {
          contacts.add((id: id, name: name.isEmpty ? 'Candidate' : name));
        }
      }
    } catch (_) {
      // ignore unreadable contacts
    }
    _contacts
      ..clear()
      ..addAll(contacts);
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
      floatingActionButton: widget.canInitiate
          ? FloatingActionButton.extended(
              onPressed: _openNewMessage,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_comment_outlined, size: 20),
              label: Text(
                context.tr('New message'),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  Text(
                    context.tr('Messages'),
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.chat_bubble_outline, color: AppColors.primary),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : _conversations.isEmpty
                      ? _buildEmpty(context)
                      : RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: _load,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                            itemCount: _conversations.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final c = _conversations[index];
                              return _ConversationTile(
                                conversation: c,
                                myUserId: widget.userId,
                                canInitiate: widget.canInitiate,
                                timeLabel: _timeLabel(c.updatedAt),
                              );
                            },
                          ),
                        ),
            ),
          ],
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
            Icon(Icons.forum_outlined, size: 44, color: AppColors.textMuted),
            const SizedBox(height: 14),
            Text(
              context.tr('No messages yet.'),
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.canInitiate
                  ? context.tr(
                      'Tap "New message" to start a chat with a candidate who applied to your job.')
                  : context.tr(
                      'When a company sends you a message, it will appear here and you can reply.'),
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

  Future<void> _openNewMessage() async {
    if (_contacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr(
              'No contacts yet. Apply to a job to message its employer.')),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }
    final contact = await showModalBottomSheet<({String id, String name})>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Text(
                context.tr('Start a new chat'),
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                itemCount: _contacts.length,
                separatorBuilder: (context, index) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final c = _contacts[index];
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primarySoft,
                      child: Text(
                        c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    title: Text(
                      c.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    onTap: () => Navigator.pop(sheetContext, c),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
    if (contact != null && mounted) {
      await _startChat(contact.id, contact.name);
    }
  }

  Future<void> _startChat(String otherId, String otherName) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPage(
          userId: widget.userId,
          displayName: widget.displayName,
          otherUserId: otherId,
          otherName: otherName,
          canInitiate: widget.canInitiate,
        ),
      ),
    );
    await _load();
  }
}

class _ConversationTile extends StatelessWidget {
  final ConversationEntity conversation;
  final String myUserId;
  final bool canInitiate;
  final String timeLabel;

  const _ConversationTile({
    required this.conversation,
    required this.myUserId,
    required this.canInitiate,
    required this.timeLabel,
  });

  @override
  Widget build(BuildContext context) {
    context.adaptive();
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
                displayName: otherName,
                conversation: conversation,
                canInitiate: canInitiate,
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
                          : (conversation.lastSenderId == myUserId
                              ? '${context.tr('You')}: ${conversation.lastMessage}'
                              : conversation.lastMessage),
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
              const SizedBox(width: 8),
              Text(
                timeLabel,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}