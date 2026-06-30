import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:byte_papo/core/errors/app_exception.dart';
import 'package:byte_papo/core/network/ollama_stream_parser.dart';

void main() {
  group('OllamaStreamParser', () {
    test('emits a token from one NDJSON line', () async {
      final stream = _byteStream([
        '{"message":{"role":"assistant","content":"Ola"},"done":false}\n',
      ]);

      await expectLater(
        OllamaStreamParser.parseChatTokens(stream),
        emitsInOrder(['Ola', emitsDone]),
      );
    });

    test('emits tokens from multiple lines and ignores empty lines', () async {
      final stream = _byteStream([
        '\n',
        '{"message":{"role":"assistant","content":"Ola"},"done":false}\n',
        '\r\n',
        '{"message":{"role":"assistant","content":" mundo"},"done":false}\n',
        '{"done":true}\n',
      ]);

      final tokens = await OllamaStreamParser.parseChatTokens(stream).toList();

      expect(tokens.join(), 'Ola mundo');
    });

    test('reassembles JSON split across byte chunks', () async {
      final stream = _byteStream([
        '{"message":{"role":"assistant","con',
        'tent":"Ola"},"done":false}\n{"done":true}\n',
      ]);

      await expectLater(
        OllamaStreamParser.parseChatTokens(stream),
        emitsInOrder(['Ola', emitsDone]),
      );
    });

    test('stops when done true appears', () async {
      final stream = _byteStream([
        '{"message":{"role":"assistant","content":"Fim"},"done":true}\n',
        '{"message":{"role":"assistant","content":"ignorado"},"done":false}\n',
      ]);

      final tokens = await OllamaStreamParser.parseChatTokens(stream).toList();

      expect(tokens, ['Fim']);
    });

    test('ignores missing content', () async {
      final stream = _byteStream([
        '{"message":{"role":"assistant"},"done":false}\n',
        '{"done":true}\n',
      ]);

      final tokens = await OllamaStreamParser.parseChatTokens(stream).toList();

      expect(tokens, isEmpty);
    });

    test('wraps invalid JSON in a controlled exception', () async {
      final stream = _byteStream(['{"message":\n']);

      expect(
        () => OllamaStreamParser.parseChatTokens(stream).drain<void>(),
        throwsA(isA<OllamaStreamParseException>()),
      );
    });

    test('decodes UTF-8 content', () async {
      final stream = _byteStream([
        '{"message":{"role":"assistant","content":"Olá mundo"},"done":false}\n',
      ]);

      final tokens = await OllamaStreamParser.parseChatTokens(stream).toList();

      expect(tokens.single, 'Olá mundo');
    });
    test('emits thinking chunks before content chunks', () async {
      final stream = _byteStream([
        '{"message":{"role":"assistant","thinking":"Vou calcular"},"done":false}\n',
        '{"message":{"role":"assistant","thinking":" passo a passo."},"done":false}\n',
        '{"message":{"role":"assistant","content":"A resposta e 42."},"done":false}\n',
        '{"done":true}\n',
      ]);

      final chunks = await OllamaStreamParser.parseChatChunks(stream).toList();

      expect(chunks, hasLength(3));
      expect(chunks[0].kind, OllamaChatChunkKind.thinking);
      expect(chunks[0].text, 'Vou calcular');
      expect(chunks[1].kind, OllamaChatChunkKind.thinking);
      expect(chunks[1].text, ' passo a passo.');
      expect(chunks[2].kind, OllamaChatChunkKind.content);
      expect(chunks[2].text, 'A resposta e 42.');
    });

    test('legacy token parser ignores thinking chunks', () async {
      final stream = _byteStream([
        '{"message":{"role":"assistant","thinking":"Rascunho"},"done":false}\n',
        '{"message":{"role":"assistant","content":"Final"},"done":false}\n',
        '{"done":true}\n',
      ]);

      final tokens = await OllamaStreamParser.parseChatTokens(stream).toList();

      expect(tokens, ['Final']);
    });
  });
}

Stream<List<int>> _byteStream(List<String> chunks) {
  return Stream.fromIterable(chunks.map(utf8.encode));
}
