import 'package:file_picker/file_picker.dart';
import 'package:tcm_return_pilot/models/chat_media_model.dart';

enum SenderType { tcm, user, system }

class ChatMessage {
  final String id;
  final String sender; // 'tcm' or 'user'
  final String text;
  final DateTime timestamp;

  final List<PlatformFile>
  attachedLocalFiles; // This is to store the file locally before upload
  final List<ChatMedia> attachments; // This is to store the file IDs after upload

  ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.attachments = const [],
    this.attachedLocalFiles = const [],
  });

  bool get isUser => sender == 'user';
}

class ChatAttachment {
  final String type; // image, file, url
  final String data; // url or id

  ChatAttachment({required this.type, required this.data});
}
