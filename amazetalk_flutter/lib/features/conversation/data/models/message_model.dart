import 'package:amazetalk_flutter/features/conversation/domain/entities/message_entity.dart';

class Message extends MessageEntity {
  Message(
      {required super.id,
      required super.sender,
      required super.content,
      required super.chat,
      required super.createdAt,
      required super.updatedAt});

  factory Message._fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'] ?? '',
      sender: Sender.fromJson(json['sender'] ?? {}),
      content: json['content'] ?? '',
      chat: Chat.fromJson(json['chat'] ?? {}),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  static List<Message> fromResponse(List<dynamic> data) {
    // final jsonData = jsonDecode(jsonString);
    return data.map((json) => Message._fromJson(json)).toList();
  }
}
