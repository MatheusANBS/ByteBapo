import 'dart:convert';

import '../errors/app_exception.dart';

enum ChatChunkKind { thinking, content, toolCall }

class ChatChunk {
  const ChatChunk({required this.kind, required this.text, this.toolCall});

  final ChatChunkKind kind;
  final String text;
  final ToolCallDelta? toolCall;

  @override
  String toString() => 'ChatChunk(kind: $kind, text: $text, toolCall: $toolCall)';
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

  @override
  String toString() =>
      'ToolCallDelta(index: $index, id: $id, name: $name, arguments: $arguments)';
}

class StreamParser {
  const StreamParser._();

  static Stream<String> parseTokens(Stream<List<int>> byteStream) async* {
    await for (final chunk in parseChunks(byteStream)) {
      if (chunk.kind == ChatChunkKind.content) {
        yield chunk.text;
      }
    }
  }

  static Stream<ChatChunk> parseChunks(Stream<List<int>> byteStream) async* {
    final lines = byteStream
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    await for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        continue;
      }

      // Handle SSE format (data: {...})
      String jsonStr = trimmed;
      if (trimmed.startsWith('data: ')) {
        jsonStr = trimmed.substring(6).trim();
        if (jsonStr == '[DONE]') {
          break;
        }
        if (jsonStr.isEmpty) {
          continue;
        }
      }

      final Map<String, dynamic> payload;
      try {
        final decoded = jsonDecode(jsonStr);
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('Expected a JSON object.');
        }
        payload = decoded;
      } on FormatException catch (error) {
        throw StreamParseException(error);
      } on TypeError catch (error) {
        throw StreamParseException(error);
      }

      // OpenAI-compatible format (NVIDIA, self-hosted NIM)
      final choices = payload['choices'];
      if (choices is List && choices.isNotEmpty) {
        final choice = choices.first as Map<String, dynamic>;
        final delta = choice['delta'] as Map<String, dynamic>?;

        if (delta != null) {
          final content = delta['content'];
          if (content is String && content.isNotEmpty) {
            yield ChatChunk(kind: ChatChunkKind.content, text: content);
          }

          final toolCalls = delta['tool_calls'] as List<dynamic>?;
          if (toolCalls != null) {
            for (final tc in toolCalls) {
              if (tc is Map<String, dynamic>) {
                final index = tc['index'] as int? ?? 0;
                final id = tc['id'] as String?;
                final function = tc['function'] as Map<String, dynamic>?;
                final name = function?['name'] as String?;
                final arguments = function?['arguments'] as String?;
                yield ChatChunk(
                  kind: ChatChunkKind.toolCall,
                  text: '',
                  toolCall: ToolCallDelta(
                    index: index,
                    id: id,
                    name: name,
                    arguments: arguments,
                  ),
                );
              }
            }
          }
        }

        if (choice['finish_reason'] != null) {
          break;
        }
        continue;
      }

      // Ollama format
      final message = payload['message'];
      if (message is Map<String, dynamic>) {
        final thinking = message['thinking'];
        if (thinking is String && thinking.isNotEmpty) {
          yield ChatChunk(
            kind: ChatChunkKind.thinking,
            text: thinking,
          );
        }

        final content = message['content'];
        if (content is String && content.isNotEmpty) {
          yield ChatChunk(kind: ChatChunkKind.content, text: content);
        }
      }

      if (payload['done'] == true) {
        break;
      }
    }
  }
}
