import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/database/app_database.dart'
    hide ChatCharacter, Conversation, ServerProfile;
import '../core/secure_storage/server_secret_store.dart';
import '../features/characters/data/platform_avatar_picker.dart';
import '../features/characters/domain/avatar_picker.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('AppDatabase must be overridden in main.');
});

final serverSecretStoreProvider = Provider<ServerSecretStore>((ref) {
  return FlutterServerSecretStore();
});

final avatarPickerProvider = Provider<AvatarPicker>((ref) {
  return PlatformAvatarPicker();
});
