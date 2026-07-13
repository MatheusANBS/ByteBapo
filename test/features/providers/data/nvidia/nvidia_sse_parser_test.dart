import 'dart:convert';

import 'package:byte_papo/features/providers/data/nvidia/nvidia_sse_parser.dart';
import 'package:byte_papo/features/providers/domain/chat_completion_gateway.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('emits content from split SSE events and stops at DONE', () async {
    final bytes = utf8.encode(
      'data:{"choices":[{"delta":{"content":"Ol"}}]}\n\n'
      'data: {"choices":[{"delta":{"content":"á"}}]}\n\n'
      'data: [DONE]\n\n'
      'data: {"choices":[{"delta":{"content":" ignorado"}}]}\n',
    );

    final chunks = await NvidiaSseParser.parse(
      Stream.fromIterable([bytes.take(17).toList(), bytes.skip(17).toList()]),
    ).toList();

    expect(chunks.map((chunk) => chunk.text), ['Ol', 'á']);
    expect(
      chunks.every((chunk) => chunk.kind == ChatChunkKind.content),
      isTrue,
    );
  });

  test('emits tool call deltas from OpenAI-compatible events', () async {
    final chunks = await NvidiaSseParser.parse(
      Stream.value(
        utf8.encode(
          'data: {"choices":[{"delta":{"tool_calls":[{"index":0,"id":"call-1","function":{"name":"weather","arguments":"{\\"city\\":\\"Sao Paulo\\"}"}}]}}]}\n',
        ),
      ),
    ).toList();

    expect(chunks, hasLength(1));
    expect(chunks.single.kind, ChatChunkKind.toolCall);
    expect(chunks.single.toolCall?.id, 'call-1');
    expect(chunks.single.toolCall?.name, 'weather');
    expect(chunks.single.toolCall?.arguments, '{"city":"Sao Paulo"}');
  });
}
