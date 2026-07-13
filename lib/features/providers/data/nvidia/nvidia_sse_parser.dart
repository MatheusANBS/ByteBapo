import 'dart:convert';

import '../../domain/chat_completion_gateway.dart';

class NvidiaSseParser {
  const NvidiaSseParser._();

  static Stream<ChatChunk> parse(Stream<List<int>> byteStream) async* {
    await for (final line
        in byteStream.transform(utf8.decoder).transform(const LineSplitter())) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || !trimmed.startsWith('data:')) {
        continue;
      }
      final data = trimmed.substring('data:'.length).trim();
      if (data == '[DONE]') {
        break;
      }
      if (data.isEmpty) {
        continue;
      }
      final payload = jsonDecode(data);
      if (payload is! Map<String, dynamic>) {
        throw const FormatException('NVIDIA SSE event must be an object.');
      }
      final choices = payload['choices'];
      if (choices is! List || choices.isEmpty) {
        continue;
      }
      final first = choices.first;
      if (first is! Map<String, dynamic>) {
        continue;
      }
      final delta = first['delta'];
      if (delta is! Map<String, dynamic>) {
        continue;
      }
      final content = delta['content'];
      if (content is String && content.isNotEmpty) {
        yield ChatChunk(kind: ChatChunkKind.content, text: content);
      }
      final toolCalls = delta['tool_calls'];
      if (toolCalls is List) {
        for (final toolCall in toolCalls) {
          if (toolCall is! Map<String, dynamic>) {
            continue;
          }
          final function = toolCall['function'];
          final index = toolCall['index'];
          yield ChatChunk(
            kind: ChatChunkKind.toolCall,
            text: '',
            toolCall: ToolCallDelta(
              index: index is int ? index : 0,
              id: toolCall['id'] as String?,
              name: function is Map<String, dynamic>
                  ? function['name'] as String?
                  : null,
              arguments: function is Map<String, dynamic>
                  ? function['arguments'] as String?
                  : null,
            ),
          );
        }
      }
      if (first['finish_reason'] != null) {
        break;
      }
    }
  }
}
