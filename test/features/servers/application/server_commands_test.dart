import 'package:byte_papo/features/providers/domain/entities/available_model.dart';
import 'package:byte_papo/features/providers/domain/model_catalog_gateway.dart';
import 'package:byte_papo/features/servers/application/server_commands.dart';
import 'package:byte_papo/features/servers/domain/entities/server_profile.dart';
import 'package:byte_papo/features/servers/domain/repositories/server_repository.dart';
import 'package:byte_papo/features/servers/domain/server_connection_tester.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('testConnection returns the NVIDIA-specific success message', () async {
    final commands = ServerCommands(
      repository: _ServerRepository(),
      connectionTester: CatalogServerConnectionTester(
        nvidiaCatalog: _Catalog(['meta/llama-3.1-8b-instruct']),
        ollamaCatalog: _Catalog([]),
      ),
    );

    final result = await commands.testConnection(_nvidiaServer());

    expect(
      result.successMessage,
      'Conexão NVIDIA OK. 1 modelo(s) disponível(is).',
    );
  });

  test('saveAndActivate persists and selects the profile', () async {
    final repository = _ServerRepository();
    final commands = ServerCommands(
      repository: repository,
      connectionTester: CatalogServerConnectionTester(
        nvidiaCatalog: _Catalog([]),
        ollamaCatalog: _Catalog([]),
      ),
    );
    final profile = _nvidiaServer();

    await commands.saveAndActivate(profile, apiKey: 'nvapi-test');

    expect(repository.savedProfile, profile);
    expect(repository.savedApiKey, 'nvapi-test');
    expect(repository.activeServerId, profile.id);
  });

  test('select only changes the active profile', () async {
    final repository = _ServerRepository();
    final commands = ServerCommands(
      repository: repository,
      connectionTester: CatalogServerConnectionTester(
        nvidiaCatalog: _Catalog([]),
        ollamaCatalog: _Catalog([]),
      ),
    );

    await commands.select(_nvidiaServer());

    expect(repository.savedProfile, isNull);
    expect(repository.activeServerId, 'nvidia');
  });

  test(
    'testAndRecordConnection stores successful connection metadata',
    () async {
      final repository = _ServerRepository();
      final commands = ServerCommands(
        repository: repository,
        connectionTester: CatalogServerConnectionTester(
          nvidiaCatalog: _Catalog(['meta/llama']),
          ollamaCatalog: _Catalog([]),
        ),
      );

      await commands.testAndRecordConnection(_nvidiaServer());

      expect(repository.connectionStatus, ServerConnectionStatus.connected);
      expect(repository.connectionCheckedAt, isNotNull);
    },
  );
}

ServerProfile _nvidiaServer() => ServerProfile.create(
  id: 'nvidia',
  name: 'NVIDIA',
  input: 'https://integrate.api.nvidia.com:443',
  provider: ApiProvider.nvidia,
  apiKey: 'nvapi-test',
);

class _Catalog implements ModelCatalogGateway {
  _Catalog(this.modelIds);

  final List<String> modelIds;

  @override
  Future<List<AvailableModel>> listModels(ServerProfile server) async => [
    for (final id in modelIds)
      AvailableModel(
        id: id,
        displayName: id,
        serverId: server.id,
        provider: server.provider,
      ),
  ];
}

class _ServerRepository implements ServerRepository {
  ServerProfile? savedProfile;
  String? savedApiKey;
  String? activeServerId;
  ServerConnectionStatus? connectionStatus;
  DateTime? connectionCheckedAt;

  @override
  Future<String?> getActiveServerId() async => activeServerId;

  @override
  Future<List<ServerProfile>> list() async => const [];

  @override
  Future<void> remove(String id) async {}

  @override
  Future<void> save(ServerProfile profile, {String? apiKey}) async {
    savedProfile = profile;
    savedApiKey = apiKey;
  }

  @override
  Future<void> setActiveServerId(String? id) async => activeServerId = id;

  @override
  Future<void> recordConnection(
    String id, {
    required ServerConnectionStatus status,
    required DateTime checkedAt,
  }) async {
    connectionStatus = status;
    connectionCheckedAt = checkedAt;
  }
}
