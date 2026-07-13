import 'package:byte_papo/features/providers/domain/provider_gateway_resolver.dart';
import 'package:byte_papo/features/providers/domain/model_catalog_gateway.dart';
import 'package:byte_papo/features/providers/domain/chat_completion_gateway.dart';
import 'package:byte_papo/features/chat/domain/entities/chat_message.dart';
import 'package:byte_papo/features/chat/domain/entities/generation_options.dart';
import 'package:byte_papo/features/providers/domain/entities/available_model.dart';
import 'package:byte_papo/features/servers/domain/entities/server_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('resolves the gateway registered for each provider', () {
    final nvidiaCatalog = _Catalog();
    final nvidiaChat = _Chat();
    final ollamaCatalog = _Catalog();
    final ollamaChat = _Chat();
    final nvidia = ProviderGatewayBundle(nvidiaCatalog, nvidiaChat);
    final ollama = ProviderGatewayBundle(ollamaCatalog, ollamaChat);
    final resolver = ProviderGatewayResolver(nvidia: nvidia, ollama: ollama);

    expect(resolver.forProvider(ApiProvider.nvidia), same(nvidia));
    expect(resolver.forProvider(ApiProvider.ollama), same(ollama));
    expect(
      resolver.forProvider(ApiProvider.nvidia).catalog,
      same(nvidiaCatalog),
    );
    expect(resolver.forProvider(ApiProvider.ollama).chat, same(ollamaChat));
  });
}

class _Catalog implements ModelCatalogGateway {
  @override
  Future<List<AvailableModel>> listModels(ServerProfile server) =>
      throw UnimplementedError();
}

class _Chat implements ChatCompletionGateway {
  @override
  Stream<ChatChunk> streamChat({
    required ServerProfile server,
    required String model,
    required List<ChatMessage> messages,
    GenerationOptions options = const GenerationOptions(),
  }) => throw UnimplementedError();
}
