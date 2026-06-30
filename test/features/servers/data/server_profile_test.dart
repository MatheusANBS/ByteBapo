import 'package:flutter_test/flutter_test.dart';
import 'package:ollama_mobile_client/core/errors/app_exception.dart';
import 'package:ollama_mobile_client/features/servers/domain/entities/server_profile.dart';

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
  });
}
