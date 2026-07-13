import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../../core/errors/app_exception.dart';
import '../../../chat/domain/entities/chat_message.dart';
import '../../../chat/domain/entities/generation_options.dart';
import '../../../servers/domain/entities/server_profile.dart';
import '../../domain/chat_completion_gateway.dart';
import 'nvidia_sse_parser.dart';

class NvidiaChatCompletionGateway implements ChatCompletionGateway {
  NvidiaChatCompletionGateway({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  @override
  Stream<ChatChunk> streamChat({
    required ServerProfile server,
    required String model,
    required List<ChatMessage> messages,
    GenerationOptions options = const GenerationOptions(),
  }) async* {
    final request = http.Request('POST', server.resolve('chat/completions'))
      ..headers.addAll(server.headers)
      ..headers['Content-Type'] = 'application/json'
      ..headers['Accept'] = 'text/event-stream'
      ..body = jsonEncode({
        'model': model,
        'messages': messages.map(_openAiMessageJson).toList(),
        'stream': options.stream,
        if (options.temperature != null) 'temperature': options.temperature,
        if (options.topP != null) 'top_p': options.topP,
        if (options.maxTokens != null) 'max_tokens': options.maxTokens,
        if (options.stopSequences?.isNotEmpty ?? false)
          'stop': options.stopSequences,
        if (options.seed != null) 'seed': options.seed,
      });
    final http.StreamedResponse response;
    try {
      response = await _httpClient.send(request);
    } on TimeoutException catch (error) {
      throw NvidiaApiException(const TimeoutFailure(), error);
    } on SocketException catch (error) {
      throw NvidiaApiException(
        const NetworkFailure('Nao consegui conectar a API NVIDIA.'),
        error,
      );
    } on HandshakeException catch (error) {
      throw NvidiaApiException(
        const NvidiaApiFailure('A conexao TLS com a NVIDIA falhou.'),
        error,
      );
    } on http.ClientException catch (error) {
      throw NvidiaApiException(
        const NetworkFailure('Nao consegui conectar a API NVIDIA.'),
        error,
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw NvidiaApiException(
        NvidiaApiFailure(_nvidiaChatHttpMessage(response.statusCode)),
      );
    }
    yield* NvidiaSseParser.parse(response.stream);
  }
}

Map<String, Object?> _openAiMessageJson(ChatMessage message) {
  final result = <String, Object?>{
    'role': message.role.name,
    'content': message.content,
  };
  if (message.toolCalls?.isNotEmpty ?? false) {
    result['tool_calls'] = message.toolCalls!
        .map((call) => call.toJson())
        .toList();
  }
  if (message.toolCallId != null) {
    result['tool_call_id'] = message.toolCallId;
  }
  return result;
}

String _nvidiaChatHttpMessage(int statusCode) {
  if (statusCode == 401) {
    return 'A chave da API NVIDIA nao foi aceita.';
  }
  if (statusCode == 403) {
    return 'Sua conta NVIDIA nao tem permissao para isso.';
  }
  if (statusCode == 404) {
    return 'O modelo ou endpoint NVIDIA nao foi encontrado.';
  }
  if (statusCode == 429) {
    return 'O limite da API NVIDIA foi atingido.';
  }
  if (statusCode >= 500) {
    return 'A API NVIDIA esta indisponivel no momento.';
  }
  return 'A API NVIDIA retornou um erro.';
}
