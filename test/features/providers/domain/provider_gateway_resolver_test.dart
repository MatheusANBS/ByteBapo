import 'package:byte_papo/features/providers/domain/provider_gateway_resolver.dart';
import 'package:byte_papo/features/servers/domain/entities/server_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('resolves the gateway registered for each provider', () {
    final nvidia = _Gateway();
    final ollama = _Gateway();
    final resolver = ProviderGatewayResolver(nvidia: nvidia, ollama: ollama);

    expect(resolver.forProvider(ApiProvider.nvidia), same(nvidia));
    expect(resolver.forProvider(ApiProvider.ollama), same(ollama));
  });
}

class _Gateway implements ProviderGateway {}
