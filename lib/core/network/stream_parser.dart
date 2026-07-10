import 'dart:convert';

class ChatChunkKind {
  const ChatChunkKind._(this.name);
  final String name;

  static const content = ChatChunkKind._('content');
  static const toolCall = ChatChunkKind._('toolCall');
  static const done = ChatChunkKind._('done');
}

class ChatChunk {
  const ChatChunk({
    required this.kind,
    required this.text,
    this.toolCalls,
  });

  final ChatChunkKind kind;
  final String text;
  final List<ToolCallDelta>? toolCalls;
}

class ToolCallDelta {
  const ToolCallDelta({
    required this.index,
    this.id,
    this.name,
    this.arguments,
  });

  final int index;
  final String? id;
  final String? name;
  final String? arguments;
}

class StreamParser {
  static Stream<ChatChunk> parseChunks(Stream<List<int>> byteStream) async* {
    final decoder = utf8.decoder;
    String buffer = '';
    await for (final chunk in byteStream) {
      buffer += decoder.convert(chunk);
      final lines = buffer.split('\n');
      buffer = lines.removeLast();
      for (final line in lines) {
        final trimmed = line.trim();
        if (!trimmed.startsWith('data:')) continue;
        final data = trimmed.substring(5).trim();
        if (data == '[DONE]') {
          yield const ChatChunk(kind: ChatChunkKind.done, text: '');
          return;
        }
        if (data.isEmpty) continue;
        try {
          final json = jsonDecode(data) as Map<String, dynamic>;
          final choices = json['choices'] as List<dynamic>?;
          if (choices == null || choices.isEmpty) continue;
          final choice = choices.first as Map<String, dynamic>;
          final delta = choice['delta'] as Map<String, dynamic>? ?? {};
          final content = delta['content'] as String? ?? '';
          if (content.isNotEmpty) {
            yield ChatChunk(kind: ChatChunkKind.content, text: content);
          }
          final toolCalls = delta['tool_calls'] as List<dynamic>?;
          if (toolCalls != null && toolCalls.isNotEmpty) {
            final parsed = toolCalls
                .whereType<Map<String, dynamic>>()
                .map((tc) => ToolCallDelta(
                      index: tc['index'] as int? ?? 0,
                      id: tc['id'] as String?,
                      name: tc['function']?['name'] as String?,
                      arguments: tc['function']?['arguments'] as String?,
                    ))
                .toList(growable: false);
            yield ChatChunk(kind: ChatChunkKind.toolCall, text: '', toolCalls: parsed);
          }
        } catch (_) {
          // Ignore malformed chunks
        }
      }
    }
    final remaining = buffer.trim();
    if (remaining.startsWith('data:')) {
      final data = remaining.substring(5).trim();
      if (data != '[DONE]' && data.isNotEmpty) {
        try {
          final json = jsonDecode(data) as Map<String, dynamic>;
          final choices = json['choices'] as List<dynamic>?;
          if (choices != null && choices.isNotEmpty) {
            final choice = choices.first as Map<String, dynamic>;
            final delta = choice['delta'] as Map<String, dynamic>? ?? {};
            final content = delta['content'] as String? ?? '';
            if (content.isNotEmpty) {
              yield ChatChunk(kind: ChatChunkKind.content, text: content);
            }
          }
        } catch (_) {}
      }
    }
  }
}