import '../domain/entities/server_profile.dart';
import '../domain/repositories/server_repository.dart';
import '../domain/server_connection_tester.dart';

class ServerCommands {
  const ServerCommands({
    required ServerRepository repository,
    required ServerConnectionTester connectionTester,
  }) : _repository = repository,
       _connectionTester = connectionTester;

  final ServerRepository _repository;
  final ServerConnectionTester _connectionTester;

  Future<void> saveAndActivate(ServerProfile profile, {String? apiKey}) async {
    await _repository.save(profile, apiKey: apiKey);
    await _repository.setActiveServerId(profile.id);
  }

  Future<ServerConnectionTestResult> testConnection(ServerProfile profile) =>
      _connectionTester.test(profile);

  Future<ServerConnectionTestResult> testAndRecordConnection(
    ServerProfile profile,
  ) async {
    final checkedAt = DateTime.now().toUtc();
    try {
      final result = await testConnection(profile);
      await _repository.recordConnection(
        profile.id,
        status: ServerConnectionStatus.connected,
        checkedAt: checkedAt,
      );
      return result;
    } catch (_) {
      await _repository.recordConnection(
        profile.id,
        status: ServerConnectionStatus.failed,
        checkedAt: checkedAt,
      );
      rethrow;
    }
  }

  Future<void> select(ServerProfile profile) {
    return _repository.setActiveServerId(profile.id);
  }
}
