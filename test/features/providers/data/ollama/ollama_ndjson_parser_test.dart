import 'dart:convert';

import 'package:byte_papo/features/providers/data/ollama/ollama_ndjson_parser.dart';
import 'package:byte_papo/features/providers/domain/chat_completion_gateway.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'emits thinking and content from split NDJSON and stops when done',
    () async {
      final bytes = utf8.encode(
        '{"message":{"thinking":"raciocínio"},"done":false}\n'
        '{"message":{"content":"resposta"},"done":false}\n'
        '{"done":true}\n'
        '{"message":{"content":"ignorado"},"done":false}\n',
      );

      final chunks = await OllamaNdjsonParser.parse(
        Stream.fromIterable([bytes.take(23).toList(), bytes.skip(23).toList()]),
      ).toList();

      expect(chunks.map((chunk) => chunk.kind), [
        ChatChunkKind.thinking,
        ChatChunkKind.content,
      ]);
      expect(chunks.map((chunk) => chunk.text), ['raciocínio', 'resposta']);
    },
  );

  test('emits tool calls from Ollama message chunks', () async {
    final chunks = await OllamaNdjsonParser.parse(
      Stream.value(
        utf8.encode(
          '{"message":{"tool_calls":[{"function":{"name":"weather","arguments":{"city":"Sao Paulo"}}}]}}\n',
        ),
      ),
    ).toList();

    expect(chunks.single.kind, ChatChunkKind.toolCall);
    expect(chunks.single.toolCall?.name, 'weather');
    expect(chunks.single.toolCall?.arguments, '{"city":"Sao Paulo"}');
  });
}
