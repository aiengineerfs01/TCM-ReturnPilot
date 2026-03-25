import 'package:tcm_return_pilot/models/chat_message.dart';
import 'package:uuid/uuid.dart';

class ChatMedia {
  final int? id;
  final DateTime createdAt;
  final int chatId;
  final String threadId;
  final String fileId;
  final String? url;
  final String userId;
  final SenderType userType;

  ChatMedia({
    this.id,
    required this.createdAt,
    required this.chatId,
    required this.threadId,
    required this.fileId,
    this.url,
    required this.userId,
    required this.userType,
  });

  // Empty factory
  factory ChatMedia.empty() {
    return ChatMedia(
      id: null,
      createdAt: DateTime.now(),
      chatId: 0,
      threadId: '',
      fileId: '',
      url: null,
      userId: const Uuid().v4(),
      userType: SenderType.system,
    );
  }

  // Optional: factory to create from JSON if needed
  factory ChatMedia.fromJson(Map<String, dynamic> json) {
    return ChatMedia(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      chatId: json['chat_id'],
      threadId: json['thread_id'],
      fileId: json['file_id'],
      url: json['url'],
      userId: json['user_id'],
      userType: SenderType.values.firstWhere(
        (e) => e.toString() == 'SenderType.${json['user_type']}',
        orElse: () => SenderType.system,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'chat_id': chatId,
      'thread_id': threadId,
      'file_id': fileId,
      'url': url,
      'user_id': userId,
      'user_type': userType.toString().split('.').last,
    };
  }
}
