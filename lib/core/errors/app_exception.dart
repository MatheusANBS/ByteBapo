sealed class AppFailure {
  const AppFailure(this.message);

  final String message;
}

class NetworkFailure extends AppFailure {
  const NetworkFailure([
    super.message =
        'Nao consegui conectar. Verifique se o Ollama esta aberto e a porta esta correta.',
  ]);
}

class TimeoutFailure extends AppFailure {
  const TimeoutFailure([
    super.message =
        'Tempo esgotado. Confirme se PC e celular estao na mesma rede.',
  ]);
}

class InvalidServerFailure extends AppFailure {
  const InvalidServerFailure([
    super.message = 'Servidor invalido. Confira host, porta e protocolo.',
  ]);
}

class CleartextBlockedFailure extends AppFailure {
  const CleartextBlockedFailure([
    super.message =
        'O Android bloqueou HTTP sem criptografia. Use rede local liberada ou HTTPS.',
  ]);
}

class OllamaApiFailure extends AppFailure {
  const OllamaApiFailure([
    super.message = 'O servidor Ollama retornou uma resposta inesperada.',
  ]);
}

class StreamParseFailure extends AppFailure {
  const StreamParseFailure([
    super.message =
        'Nao consegui interpretar a resposta em streaming do Ollama.',
  ]);
}

abstract class AppException implements Exception {
  const AppException(this.failure, [this.cause]);

  final AppFailure failure;
  final Object? cause;

  String get message => failure.message;

  @override
  String toString() => '$runtimeType: $message';
}

class InvalidServerException extends AppException {
  InvalidServerException([String? message, Object? cause])
    : super(InvalidServerFailure(message ?? 'Servidor invalido.'), cause);
}

class OllamaStreamParseException extends AppException {
  const OllamaStreamParseException([Object? cause])
    : super(const StreamParseFailure(), cause);
}

class OllamaApiException extends AppException {
  const OllamaApiException(super.failure, [super.cause]);
}
