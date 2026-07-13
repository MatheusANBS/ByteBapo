import '../../servers/domain/entities/server_profile.dart';

abstract interface class ProviderGateway {}

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
