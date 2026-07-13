import '../../servers/domain/entities/server_profile.dart';
import 'chat_completion_gateway.dart';
import 'model_catalog_gateway.dart';

abstract interface class ProviderGateway {
  ModelCatalogGateway get catalog;

  ChatCompletionGateway get chat;
}

class ProviderGatewayBundle implements ProviderGateway {
  const ProviderGatewayBundle(this.catalog, this.chat);

  @override
  final ModelCatalogGateway catalog;

  @override
  final ChatCompletionGateway chat;
}

class ProviderGatewayResolver {
  const ProviderGatewayResolver({required this.nvidia, required this.ollama});

  final ProviderGateway nvidia;
  final ProviderGateway ollama;

  ProviderGateway forProvider(ApiProvider provider) {
    return switch (provider) {
      ApiProvider.nvidia => nvidia,
      ApiProvider.ollama => ollama,
    };
  }
}
