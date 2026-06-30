enum ChatRole {
  system,
  user,
  assistant,
  tool;

  static ChatRole fromName(String name) {
    return ChatRole.values.firstWhere(
      (role) => role.name == name,
      orElse: () => ChatRole.user,
    );
  }
}

enum ChatMessageStatus {
  pending,
  streaming,
  completed,
  failed,
  cancelled;

  static ChatMessageStatus fromName(String name) {
    return ChatMessageStatus.values.firstWhere(
      (status) => status.name == name,
      orElse: () => ChatMessageStatus.completed,
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.thinking = '',
    this.model,
    this.status = ChatMessageStatus.completed,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      role: ChatRole.fromName(json['role'] as String),
      content: json['content'] as String,
      thinking: json['thinking'] as String? ?? '',
      model: json['model'] as String?,
      status: ChatMessageStatus.fromName(
        json['status'] as String? ?? 'completed',
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  final String id;
  final String conversationId;
  final ChatRole role;
  final String content;
  final String thinking;
  final String? model;
  final ChatMessageStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isStreaming => status == ChatMessageStatus.streaming;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'role': role.name,
      'content': content,
      'thinking': thinking,
      'model': model,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toOllamaJson() {
    return {'role': role.name, 'content': content};
  }
}
