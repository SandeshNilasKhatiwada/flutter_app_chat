abstract class ChatsEntity {
  final String id;
  final String chatName;
  final bool isGroupChat;
  final List<GroupAdmin> users;
  final LatestMessage latestMessage;
  final GroupAdmin? groupAdmin;

  ChatsEntity({
    required this.id,
    required this.chatName,
    required this.isGroupChat,
    required this.users,
    required this.latestMessage,
    this.groupAdmin,
  });

  @override
  String toString() {
    return 'ChatsEntity(id: $id, chatName: $chatName, isGroupChat: $isGroupChat, users: $users, latestMessage: $latestMessage, groupAdmin: $groupAdmin)';
  }
}

class GroupAdmin {
  final String id;
  final String name;
  final String email;
  final dynamic image;

  GroupAdmin({
    required this.id,
    required this.name,
    required this.email,
    required this.image,
  });

  factory GroupAdmin.fromJson(Map<String, dynamic> json) {
    return GroupAdmin(
      id: json['_id'] ?? '', // Default to empty string if null
      name: json['name'] ?? '', // Default to empty string if null
      email: json['email'] ?? '', // Default to empty string if null
      image: json['image'] ?? '', // Default to empty string if null
    );
  }

  @override
  String toString() {
    return 'GroupAdmin(id: $id, name: $name, email: $email, image: $image)';
  }
}

class LatestMessage {
  final String id;
  final Sender sender;
  final String content;
  final String chat;
  final DateTime createdAt;
  final DateTime updatedAt;

  LatestMessage({
    required this.id,
    required this.sender,
    required this.content,
    required this.chat,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LatestMessage.fromJson(Map<String, dynamic> json) {
    return LatestMessage(
      id: json['_id'] ?? '', // Default to empty string if null
      sender: json['sender'] != null
          ? Sender.fromJson(json['sender'])
          : Sender(id: '', name: '', email: ''), // Default sender if null
      content: json['content'] ?? '', // Default to empty string if null
      chat: json['chat'] ?? '', // Default to empty string if null
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ??
              DateTime
                  .now() // Try to parse and default to current time if null or invalid
          : DateTime.now(), // Default to current time if null
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt']) ??
              DateTime
                  .now() // Try to parse and default to current time if null or invalid
          : DateTime.now(), // Default to current time if null
    );
  }

  @override
  String toString() {
    return 'LatestMessage(id: $id, sender: $sender, content: $content, chat: $chat, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

class Sender {
  final String id;
  final String name;
  final String email;

  Sender({
    required this.id,
    required this.name,
    required this.email,
  });

  factory Sender.fromJson(Map<String, dynamic> json) {
    return Sender(
      id: json['_id'] ?? '', // Default to empty string if null
      name: json['name'] ?? '', // Default to empty string if null
      email: json['email'] ?? '', // Default to empty string if null
    );
  }

  @override
  String toString() {
    return 'Sender(id: $id, name: $name, email: $email)';
  }
}
