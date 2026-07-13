import '../entities/server_profile.dart';

abstract class ServerRepository {
  Future<List<ServerProfile>> list();

  Future<void> save(ServerProfile profile, {String? apiKey});

  Future<void> remove(String id);

  Future<void> recordConnection(
    String id, {
    required ServerConnectionStatus status,
    required DateTime checkedAt,
  });

  Future<String?> getActiveServerId();

  Future<void> setActiveServerId(String? id);
}
