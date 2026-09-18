import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_entities.dart';

/// Thrown when a job seeker tries to send a message before the company has
/// started the conversation (i.e. sent the first message).
class ConversationNotStartedException implements Exception {
  final String message;

  const ConversationNotStartedException(
      [this.message = 'The company has not messaged you yet.']);
}

abstract class MessagingRemoteDataSource {
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
    bool allowCreate = false,
    String? otherUserId,
    String? senderName,
    String? otherName,
  });
  Stream<List<MessageEntity>> watchMessages(String conversationId);
  Future<List<ConversationEntity>> getConversations(String userId);
  Future<List<ConversationEntity>> getArchivedConversations(String userId);
  Future<List<ConversationEntity>> getSpamConversations(String userId);
  Future<void> archiveConversation(String conversationId, String userId,
      {bool archive = true});
  Future<void> spamConversation(String conversationId, String userId);
  Future<void> unspamConversation(String conversationId);
  Future<void> deleteConversation(String conversationId, String userId);
  Future<void> editMessage({
    required String conversationId,
    required String messageId,
    required String text,
  });
  Future<void> deleteMessage({
    required String conversationId,
    required String messageId,
  });
}

class MessagingRemoteDataSourceImpl implements MessagingRemoteDataSource {
  final FirebaseFirestore? _firestore;

  MessagingRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? _safeFirestore;

  static FirebaseFirestore? get _safeFirestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  static String conversationIdFor(String a, String b) {
    final ids = [a, b]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  CollectionReference<Map<String, dynamic>>? get _conversations =>
      _firestore?.collection('conversations');

  @override
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
    bool allowCreate = false,
    String? otherUserId,
    String? senderName,
    String? otherName,
  }) async {
    final conversations = _conversations;
    if (conversations == null) return;
    final docRef = conversations.doc(conversationId);
    final doc = await docRef.get();
    final now = DateTime.now().toIso8601String();

    if (!doc.exists || doc.data() == null) {
      if (!allowCreate) {
        throw const ConversationNotStartedException();
      }
      if (otherUserId == null || otherUserId.isEmpty) {
        throw const ConversationNotStartedException();
      }
      final safeA = [senderId, otherUserId]..sort();
      final aId = safeA[0];
      final bId = safeA[1];
      await docRef.set({
        'participantIds': [senderId, otherUserId],
        'userAId': aId,
        'userAName': aId == senderId ? (senderName ?? '') : (otherName ?? ''),
        'userBId': bId,
        'userBName': bId == senderId ? (senderName ?? '') : (otherName ?? ''),
        'initiatorRole': 'company',
        'initiatorId': senderId,
        'lastMessage': '',
        'lastSenderId': '',
        'createdAt': now,
        'updatedAt': now,
      });
    }

    await docRef.collection('messages').add({
      'conversationId': conversationId,
      'senderId': senderId,
      'text': text,
      'timestamp': now,
      'read': false,
    });
    await docRef.set({
      'initiatorRole': 'company',
      'initiatorId': doc.data()?['initiatorId'] as String? ?? senderId,
      'lastMessage': text,
      'lastSenderId': senderId,
      'updatedAt': now,
    }, SetOptions(merge: true));
  }

  @override
  Stream<List<MessageEntity>> watchMessages(String conversationId) {
    final conversations = _conversations;
    if (conversations == null) {
      return Stream.value(const []);
    }
    return conversations
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  @override
  Future<List<ConversationEntity>> getConversations(String userId) async {
    final conversations = _conversations;
    if (conversations == null) return const [];
    try {
      final snapshot = await conversations
          .where('participantIds', arrayContains: userId)
          .get();
      final list = snapshot.docs
          .map((doc) => ConversationModel.fromMap(doc.data(), doc.id))
          .where((c) =>
              !c.deletedFor.contains(userId) &&
              c.archivedBy != userId &&
              c.spamBy != userId)
          .toList();
      list.sort((a, b) {
        final ta = DateTime.tryParse(a.updatedAt);
        final tb = DateTime.tryParse(b.updatedAt);
        return (tb ?? DateTime.fromMillisecondsSinceEpoch(0))
            .compareTo(ta ?? DateTime.fromMillisecondsSinceEpoch(0));
      });
      return list;
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<ConversationEntity>> getArchivedConversations(
      String userId) async {
    final conversations = _conversations;
    if (conversations == null) return const [];
    try {
      final snapshot = await conversations
          .where('participantIds', arrayContains: userId)
          .where('archivedBy', isEqualTo: userId)
          .get();
      final list = snapshot.docs
          .map((doc) => ConversationModel.fromMap(doc.data(), doc.id))
          .where((c) =>
              !c.deletedFor.contains(userId) && c.spamBy != userId)
          .toList();
      list.sort((a, b) {
        final ta = DateTime.tryParse(a.updatedAt);
        final tb = DateTime.tryParse(b.updatedAt);
        return (tb ?? DateTime.fromMillisecondsSinceEpoch(0))
            .compareTo(ta ?? DateTime.fromMillisecondsSinceEpoch(0));
      });
      return list;
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<ConversationEntity>> getSpamConversations(String userId) async {
    final conversations = _conversations;
    if (conversations == null) return const [];
    try {
      final snapshot = await conversations
          .where('participantIds', arrayContains: userId)
          .where('spamBy', isEqualTo: userId)
          .get();
      final list = snapshot.docs
          .map((doc) => ConversationModel.fromMap(doc.data(), doc.id))
          .where((c) => !c.deletedFor.contains(userId))
          .toList();
      list.sort((a, b) {
        final ta = DateTime.tryParse(a.updatedAt);
        final tb = DateTime.tryParse(b.updatedAt);
        return (tb ?? DateTime.fromMillisecondsSinceEpoch(0))
            .compareTo(ta ?? DateTime.fromMillisecondsSinceEpoch(0));
      });
      return list;
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> archiveConversation(String conversationId, String userId,
      {bool archive = true}) async {
    final conversations = _conversations;
    if (conversations == null) return;
    await conversations.doc(conversationId).set(
          {'archivedBy': archive ? userId : ''},
          SetOptions(merge: true),
        );
  }

  @override
  Future<void> spamConversation(String conversationId, String userId) async {
    final conversations = _conversations;
    if (conversations == null) return;
    await conversations.doc(conversationId).set(
          {'spamBy': userId},
          SetOptions(merge: true),
        );
  }

  @override
  Future<void> unspamConversation(String conversationId) async {
    final conversations = _conversations;
    if (conversations == null) return;
    await conversations.doc(conversationId).set(
          {'spamBy': ''},
          SetOptions(merge: true),
        );
  }

  @override
  Future<void> deleteConversation(String conversationId, String userId) async {
    final conversations = _conversations;
    if (conversations == null) return;
    await conversations.doc(conversationId).set(
          {'deletedFor': FieldValue.arrayUnion([userId])},
          SetOptions(merge: true),
        );
  }

  @override
  Future<void> editMessage({
    required String conversationId,
    required String messageId,
    required String text,
  }) async {
    final conversations = _conversations;
    if (conversations == null) return;
    final docRef = conversations.doc(conversationId);
    await docRef.collection('messages').doc(messageId).update({
      'text': text,
      'edited': true,
    });
    await _syncLastMessage(docRef);
  }

  @override
  Future<void> deleteMessage({
    required String conversationId,
    required String messageId,
  }) async {
    final conversations = _conversations;
    if (conversations == null) return;
    final docRef = conversations.doc(conversationId);
    await docRef.collection('messages').doc(messageId).update({
      'text': 'deleted',
      'deleted': true,
    });
    await _syncLastMessage(docRef);
  }

  Future<void> _syncLastMessage(
      DocumentReference<Map<String, dynamic>> docRef) async {
    final conv = await docRef.get();
    if (!conv.exists) return;
    final now = DateTime.now().toIso8601String();
    final msgs = await docRef
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();
    if (msgs.docs.isEmpty) {
      await docRef.set({
        'lastMessage': '',
        'lastSenderId': '',
        'updatedAt': now,
      }, SetOptions(merge: true));
      return;
    }
    final data = msgs.docs.first.data();
    await docRef.set({
      'lastMessage': data['text'] ?? '',
      'lastSenderId': data['senderId'] ?? '',
      'updatedAt': now,
    }, SetOptions(merge: true));
  }
}

class ConversationModel extends ConversationEntity {
  const ConversationModel({
    required super.id,
    required super.userAId,
    required super.userAName,
    required super.userBId,
    required super.userBName,
    required super.lastMessage,
    required super.lastSenderId,
    required super.updatedAt,
    super.archivedBy,
    super.spamBy,
    super.deletedFor,
  });

  factory ConversationModel.fromMap(Map<String, dynamic> map, String id) {
    return ConversationModel(
      id: id,
      userAId: map['userAId'] as String? ?? '',
      userAName: map['userAName'] as String? ?? '',
      userBId: map['userBId'] as String? ?? '',
      userBName: map['userBName'] as String? ?? '',
      lastMessage: map['lastMessage'] as String? ?? '',
      lastSenderId: map['lastSenderId'] as String? ?? '',
      updatedAt: map['updatedAt'] as String? ?? '',
      archivedBy: map['archivedBy'] as String? ?? '',
      spamBy: map['spamBy'] as String? ?? '',
      deletedFor: (map['deletedFor'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.text,
    required super.timestamp,
    super.edited,
    super.deleted,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      conversationId: map['conversationId'] as String? ?? '',
      senderId: map['senderId'] as String? ?? '',
      text: map['text'] as String? ?? '',
      timestamp: map['timestamp'] as String? ?? '',
      edited: (map['edited'] as bool?) ?? false,
      deleted: (map['deleted'] as bool?) ?? false,
    );
  }
}