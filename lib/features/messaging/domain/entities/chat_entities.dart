import 'package:equatable/equatable.dart';

class ConversationEntity extends Equatable {
  final String id;
  final String userAId;
  final String userAName;
  final String userBId;
  final String userBName;
  final String lastMessage;
  final String lastSenderId;
  final String updatedAt;
  final String archivedBy;
  final String spamBy;
  final List<String> deletedFor;

  const ConversationEntity({
    required this.id,
    required this.userAId,
    required this.userAName,
    required this.userBId,
    required this.userBName,
    required this.lastMessage,
    required this.lastSenderId,
    required this.updatedAt,
    this.archivedBy = '',
    this.spamBy = '',
    this.deletedFor = const [],
  });

  String nameFor(String userId) => userId == userAId ? userBName : userAName;

  String idFor(String userId) => userId == userAId ? userBId : userAId;

  @override
  List<Object?> get props => [
        id,
        userAId,
        userAName,
        userBId,
        userBName,
        lastMessage,
        lastSenderId,
        updatedAt,
        archivedBy,
        spamBy,
        deletedFor,
      ];
}

class MessageEntity extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String text;
  final String timestamp;
  final bool edited;
  final bool deleted;

  const MessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.edited = false,
    this.deleted = false,
  });

  @override
  List<Object?> get props =>
      [id, conversationId, senderId, text, timestamp, edited, deleted];
}