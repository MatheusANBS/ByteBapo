import 'dart:convert';

import '../errors/app_exception.dart';

enum OllamaChatChunkKind { thinking, content }

class OllamaChatChunk {
  const OllamaChatChunk({required this.kind, required this.text});

  final OllamaChatChunkKind kind;
  final String text;
}

class OllamaStreamParser {
  const OllamaStreamParser._();

  static Stream<String> parseChatTokens(Stream<List<int>> byteStream) async* {
    await for (final chunk in parseChatChunks(byteStream)) {
      if (chunk.kind == OllamaChatChunkKind.content) {
        yield chunk.text;
      }
    }
  }

  static Stream<OllamaChatChunk> parseChatChunks(
    Stream<List<int>> byteStream,
  ) async* {
    final lines = byteStream
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    await for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        continue;
      }

      final Map<String, dynamic> payload;
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('Expected a JSON object.');
        }
        payload = decoded;
      } on FormatException catch (error) {
        throw OllamaStreamParseException(error);
      } on TypeError catch (error) {
        throw OllamaStreamParseException(error);
      }

      final message = payload['message'];
      if (message is Map<String, dynamic>) {
        final thinking = message['thinking'];
        if (thinking is String && thinking.isNotEmpty) {
          yield OllamaChatChunk(
            kind: OllamaChatChunkKind.thinking,
            text: thinking,
          );
        }

        final content = message['content'];
        if (content is String && content.isNotEmpty) {
          yield OllamaChatChunk(kind: OllamaChatChunkKind.content, text: content);
        }
      }

      if (payload['done'] == true) {
        break;
      }
    }
  }
}
