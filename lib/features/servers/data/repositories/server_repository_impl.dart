import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/server_profile.dart';
import '../../domain/repositories/server_repository.dart';

class ServerRepositoryImpl implements ServerRepository {
  const ServerRepositoryImpl({required this.preferences});

  static const _profilesKey = 'servers.profiles.v1';
  static const _activeServerKey = 'servers.active_id.v1';

  final SharedPreferences preferences;

  @override
  Future<List<ServerProfile>> list() async {
    final rawProfiles = preferences.getStringList(_profilesKey) ?? const [];
    return rawProfiles
        .map(
          (raw) =>
              ServerProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>),
        )
        .toList(growable: false);
  }

  @override
  Future<void> save(ServerProfile profile, {String? apiKey}) async {
    final profiles = await list();
    final index = profiles.indexWhere((item) => item.id == profile.id);
    final updated = profile.copyWith(updatedAt: DateTime.now().toUtc());

    final nextProfiles = [...profiles];
    if (index == -1) {
      nextProfiles.add(updated);
    } else {
      nextProfiles[index] = updated;
    }

    await _writeProfiles(nextProfiles);
  }

  @override
  Future<void> remove(String id) async {
    final profiles = await list();
    await _writeProfiles(
      profiles.where((profile) => profile.id != id).toList(growable: false),
    );

    if (await getActiveServerId() == id) {
      await setActiveServerId(null);
    }
  }

  @override
  Future<String?> getActiveServerId() async {
    return preferences.getString(_activeServerKey);
  }

  @override
  Future<void> setActiveServerId(String? id) async {
    if (id == null || id.isEmpty) {
      await preferences.remove(_activeServerKey);
      return;
    }
    await preferences.setString(_activeServerKey, id);
  }

  Future<void> _writeProfiles(List<ServerProfile> profiles) async {
    await preferences.setStringList(
      _profilesKey,
      profiles.map((profile) => jsonEncode(profile.toJson())).toList(),
    );
  }
}
