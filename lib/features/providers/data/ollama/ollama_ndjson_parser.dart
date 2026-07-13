import 'dart:convert';

import '../../domain/chat_completion_gateway.dart';

class OllamaNdjsonParser {
  const OllamaNdjsonParser._();

  static Stream<ChatChunk> parse(Stream<List<int>> byteStream) async* {
    await for (final line
        in byteStream.transform(utf8.decoder).transform(const LineSplitter())) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        continue;
      }
      final payload = jsonDecode(trimmed);
      if (payload is! Map<String, dynamic>) {
        throw const FormatException('Ollama NDJSON line must be an object.');
      }
      final message = payload['message'];
      if (message is Map<String, dynamic>) {
        final thinking = message['thinking'];
        if (thinking is String && thinking.isNotEmpty) {
          yield ChatChunk(kind: ChatChunkKind.thinking, text: thinking);
        }
        final content = message['content'];
        if (content is String && content.isNotEmpty) {
          yield ChatChunk(kind: ChatChunkKind.content, text: content);
        }
        final toolCalls = message['tool_calls'];
        if (toolCalls is List) {
          for (var index = 0; index < toolCalls.length; index++) {
            final toolCall = toolCalls[index];
            if (toolCall is! Map<String, dynamic>) {
              continue;
            }
            final function = toolCall['function'];
            if (function is! Map<String, dynamic>) {
              continue;
            }
            final name = function['name'];
            if (name is! String || name.isEmpty) {
              continue;
            }
            final arguments = function['arguments'];
            yield ChatChunk(
              kind: ChatChunkKind.toolCall,
              text: '',
              toolCall: ToolCallDelta(
                index: index,
                id: toolCall['id'] as String?,
                name: name,
                arguments: arguments is String
                    ? arguments
                    : jsonEncode(arguments),
              ),
            );
          }
        }
      }
      if (payload['done'] == true) {
        break;
      }
    }
  }
}
