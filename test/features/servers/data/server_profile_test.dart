import 'package:flutter_test/flutter_test.dart';
import 'package:byte_papo/core/errors/app_exception.dart';
import 'package:byte_papo/features/servers/domain/entities/server_profile.dart';

void main() {
  group('ServerProfile', () {
    test('normalizes host and port into default HTTP Ollama base URL', () {
      final profile = ServerProfile.create(
        id: 'server-1',
        name: 'Notebook',
        input: '192.168.0.10',
        port: 11434,
      );

      expect(profile.baseUrl, 'http://192.168.0.10:11434');
      expect(profile.protocol, 'http');
      expect(profile.host, '192.168.0.10');
      expect(profile.port, 11434);
    });

    test('accepts a complete URL with port', () {
      final profile = ServerProfile.create(
        id: 'server-1',
        name: 'Notebook',
        input: 'http://host:11434',
      );

      expect(profile.baseUrl, 'http://host:11434');
      expect(profile.host, 'host');
      expect(profile.port, 11434);
    });

    test('rejects empty host', () {
      expect(
        () => ServerProfile.create(
          id: 'server-1',
          name: 'Notebook',
          input: '',
          port: 11434,
        ),
        throwsA(isA<InvalidServerException>()),
      );
    });

    test('rejects invalid ports', () {
      expect(
        () => ServerProfile.create(
          id: 'server-1',
          name: 'Notebook',
          input: '192.168.0.10',
          port: 0,
        ),
        throwsA(isA<InvalidServerException>()),
      );
      expect(
        () => ServerProfile.create(
          id: 'server-1',
          name: 'Notebook',
          input: '192.168.0.10',
          port: 70000,
        ),
        throwsA(isA<InvalidServerException>()),
      );
    });

    test('normalizes NVIDIA profiles to the v1 base path', () {
      final profile = ServerProfile.create(
        id: 'nvidia-1',
        name: 'NVIDIA',
        input: 'https://integrate.api.nvidia.com:443',
        provider: ApiProvider.nvidia,
        apiKey: 'nvapi-test',
      );

      expect(profile.basePath, '/v1');
      expect(
        profile.resolve('models').toString(),
        'https://integrate.api.nvidia.com/v1/models',
      );
      expect(profile.headers['Authorization'], 'Bearer nvapi-test');
    });

    test('never serializes a NVIDIA API key', () {
      final profile = ServerProfile.create(
        id: 'nvidia-1',
        name: 'NVIDIA',
        input: 'https://integrate.api.nvidia.com',
        provider: ApiProvider.nvidia,
        apiKey: 'nvapi-secret',
      );

      expect(profile.toJson(), isNot(containsPair('apiKey', anything)));
      expect(profile.toJson().toString(), isNot(contains('nvapi-secret')));
    });

    test('repairs a persisted NVIDIA profile without v1', () {
      final profile = ServerProfile.fromJson({
        'id': 'nvidia-1',
        'name': 'NVIDIA',
        'protocol': 'https',
        'host': 'integrate.api.nvidia.com',
        'port': 443,
        'basePath': null,
        'headers': <String, String>{},
        'createdAt': '2026-07-13T00:00:00.000Z',
        'updatedAt': '2026-07-13T00:00:00.000Z',
        'lastConnectedAt': null,
        'provider': 'nvidia',
        'apiKey': 'nvapi-restored',
        'defaultModel': null,
      });

      expect(profile.basePath, '/v1');
      expect(profile.headers['Authorization'], 'Bearer nvapi-restored');
      expect(
        profile.resolve('chat/completions').toString(),
        'https://integrate.api.nvidia.com/v1/chat/completions',
      );
    });

    test('keeps an Ollama persisted base path unchanged', () {
      final profile = ServerProfile.fromJson({
        'id': 'ollama-1',
        'name': 'Ollama',
        'protocol': 'https',
        'host': 'ollama.example.com',
        'port': 443,
        'basePath': '/ollama',
        'headers': <String, String>{},
        'createdAt': '2026-07-13T00:00:00.000Z',
        'updatedAt': '2026-07-13T00:00:00.000Z',
        'lastConnectedAt': null,
        'provider': 'ollama',
        'apiKey': null,
        'defaultModel': null,
      });

      expect(profile.basePath, '/ollama');
      expect(profile.resolve('api/tags').path, '/ollama/api/tags');
    });
  });
}
