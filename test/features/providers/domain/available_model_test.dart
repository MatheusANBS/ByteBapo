import 'package:byte_papo/features/providers/domain/entities/available_model.dart';
import 'package:byte_papo/features/servers/domain/entities/server_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keeps the same model ID distinct across servers', () {
    const first = AvailableModel(
      id: 'llama-3.1',
      displayName: 'Llama 3.1',
      serverId: 'server-a',
      provider: ApiProvider.ollama,
    );
    const second = AvailableModel(
      id: 'llama-3.1',
      displayName: 'Llama 3.1',
      serverId: 'server-b',
      provider: ApiProvider.ollama,
    );

    expect(first.identity, 'server-a:llama-3.1');
    expect(second.identity, 'server-b:llama-3.1');
  });
}
