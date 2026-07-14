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
    this.toolCalls,
    this.toolCallId,
    this.characterIdSnapshot,
    this.characterNameSnapshot,
    this.characterAvatarPathSnapshot,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final toolCallsJson = json['toolCalls'];
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
      toolCalls: toolCallsJson is List
          ? toolCallsJson
                .whereType<Map<String, dynamic>>()
                .map(ToolCall.fromJson)
                .toList(growable: false)
          : const [],
      toolCallId: json['toolCallId'] as String?,
      characterIdSnapshot: json['characterIdSnapshot'] as String?,
      characterNameSnapshot: json['characterNameSnapshot'] as String?,
      characterAvatarPathSnapshot:
          json['characterAvatarPathSnapshot'] as String?,
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
  final List<ToolCall>? toolCalls;
  final String? toolCallId;
  final String? characterIdSnapshot;
  final String? characterNameSnapshot;
  final String? characterAvatarPathSnapshot;

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
      'toolCalls': toolCalls?.map((t) => t.toJson()).toList(),
      'toolCallId': toolCallId,
      'characterIdSnapshot': characterIdSnapshot,
      'characterNameSnapshot': characterNameSnapshot,
      'characterAvatarPathSnapshot': characterAvatarPathSnapshot,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class ToolCall {
  const ToolCall({
    required this.id,
    required this.name,
    required this.arguments,
  });

  factory ToolCall.fromJson(Map<String, dynamic> json) {
    return ToolCall(
      id: json['id'] as String,
      name: json['function']['name'] as String,
      arguments: json['function']['arguments'] as String,
    );
  }

  final String id;
  final String name;
  final String arguments;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': 'function',
      'function': {'name': name, 'arguments': arguments},
    };
  }
}
