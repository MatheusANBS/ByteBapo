import 'package:byte_papo/core/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('clears the active setting when its server is deleted', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await database
        .into(database.serverProfiles)
        .insert(
          ServerProfilesCompanion.insert(
            id: 'server-1',
            name: 'NVIDIA',
            provider: 'nvidia',
            protocol: 'https',
            host: 'integrate.api.nvidia.com',
            port: 443,
            createdAt: DateTime.utc(2026),
            updatedAt: DateTime.utc(2026),
          ),
        );
    await database.writeSetting(AppSettingKey.activeServerId, 'server-1');

    await database.deleteServer('server-1');

    expect(await database.readSetting(AppSettingKey.activeServerId), isNull);
  });
}
