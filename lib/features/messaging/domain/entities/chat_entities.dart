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

  const ConversationEntity({
    required this.id,
    required this.userAId,
    required this.userAName,
    required this.userBId,
    required this.userBName,
    required this.lastMessage,
    required this.lastSenderId,
    required this.updatedAt,
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
      ];
}

class MessageEntity extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String text;
  final String timestamp;

  const MessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  @override
  List<Object?> get props =>
      [id, conversationId, senderId, text, timestamp];
}