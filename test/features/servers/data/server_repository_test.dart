import 'package:flutter_test/flutter_test.dart';
import 'package:byte_papo/features/servers/data/repositories/server_repository_impl.dart';
import 'package:byte_papo/features/servers/domain/entities/server_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ServerRepositoryImpl', () {
    late ServerRepositoryImpl repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      repository = ServerRepositoryImpl(
        preferences: await SharedPreferences.getInstance(),
      );
    });

    test('saves and lists a server profile', () async {
      final profile = _profile(id: 'server-1', name: 'Notebook');

      await repository.save(profile);

      final profiles = await repository.list();
      expect(profiles, hasLength(1));
      expect(profiles.single.id, 'server-1');
      expect(profiles.single.baseUrl, 'http://192.168.0.10:11434');
    });

    test('updates a server profile by id', () async {
      await repository.save(_profile(id: 'server-1', name: 'Old'));

      await repository.save(_profile(id: 'server-1', name: 'New'));

      final profiles = await repository.list();
      expect(profiles, hasLength(1));
      expect(profiles.single.name, 'New');
    });

    test('removes a server profile and clears active selection', () async {
      await repository.save(_profile(id: 'server-1', name: 'Notebook'));
      await repository.setActiveServerId('server-1');

      await repository.remove('server-1');

      expect(await repository.list(), isEmpty);
      expect(await repository.getActiveServerId(), isNull);
    });

    test('stores selected active server id', () async {
      await repository.save(_profile(id: 'server-1', name: 'Notebook'));

      await repository.setActiveServerId('server-1');

      expect(await repository.getActiveServerId(), 'server-1');
    });
  });
}

ServerProfile _profile({required String id, required String name}) {
  return ServerProfile.create(
    id: id,
    name: name,
    input: '192.168.0.10',
    port: 11434,
  );
}
