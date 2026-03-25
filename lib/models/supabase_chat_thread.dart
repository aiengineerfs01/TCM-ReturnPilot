class SupabaseChatThread {
  final int id;
  final String userId;
  final String threadId;
  final DateTime createdAt;

  SupabaseChatThread({
    required this.id,
    required this.userId,
    required this.threadId,
    required this.createdAt,
  });

  factory SupabaseChatThread.fromJson(Map<String, dynamic> json) {
    return SupabaseChatThread(
      id: json['id'],
      userId: json['user_id'],
      threadId: json['thread_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  factory SupabaseChatThread.empty() {
    return SupabaseChatThread(
      id: 0,
      userId: '',
      threadId: '',
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'thread_id': threadId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
