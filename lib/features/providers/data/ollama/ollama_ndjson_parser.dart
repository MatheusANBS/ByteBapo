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
      }
      if (payload['done'] == true) {
        break;
      }
    }
  }
}
