import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/api_client.dart';
import '../features/chat/data/repositories/character_repository_impl.dart';
import '../features/chat/data/repositories/conversation_repository_impl.dart';
import '../features/chat/data/repositories/instructions_repository_impl.dart';
import '../features/chat/domain/entities/chat_character.dart';
import '../features/chat/domain/entities/conversation.dart';
import '../features/chat/domain/repositories/character_repository.dart';
import '../features/chat/domain/repositories/conversation_repository.dart';
import '../features/chat/domain/repositories/instructions_repository.dart';
import '../features/models/data/repositories/model_selection_repository_impl.dart';
import '../features/models/domain/entities/nvidia_model.dart';
import '../features/models/domain/entities/ollama_model.dart';
import '../features/models/domain/repositories/model_selection_repository.dart';
import '../features/servers/data/repositories/server_repository_impl.dart';
import '../features/servers/domain/entities/server_profile.dart';
import '../features/servers/domain/repositories/server_repository.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.');
});

final serverRepositoryProvider = Provider<ServerRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ServerRepositoryImpl(preferences: prefs);
});

final modelSelectionRepositoryProvider = Provider<ModelSelectionRepository>((
  ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ModelSelectionRepositoryImpl(preferences: prefs);
});

final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ConversationRepositoryImpl(preferences: prefs);
});

final characterRepositoryProvider = Provider<CharacterRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return CharacterRepositoryImpl(preferences: prefs);
});

final instructionsRepositoryProvider = Provider<InstructionsRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return InstructionsRepositoryImpl(preferences: prefs);
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final serverProfilesProvider = FutureProvider<List<ServerProfile>>((ref) {
  return ref.watch(serverRepositoryProvider).list();
});

final activeServerProvider = FutureProvider<ServerProfile?>((ref) async {
  final repository = ref.watch(serverRepositoryProvider);
  final profiles = await repository.list();
  final activeId = await repository.getActiveServerId();
  if (profiles.isEmpty) {
    return null;
  }
  return profiles.firstWhere(
    (profile) => profile.id == activeId,
    orElse: () => profiles.first,
  );
});

final selectedModelProvider = FutureProvider<String?>((ref) async {
  final server = await ref.watch(activeServerProvider.future);
  if (server == null) {
    return null;
  }
  return ref
      .watch(modelSelectionRepositoryProvider)
      .getSelectedModel(serverProfileId: server.id);
});

final modelsProvider = FutureProvider<List<dynamic>>((ref) async {
  final server = await ref.watch(activeServerProvider.future);
  if (server == null) {
    return const [];
  }
  final apiClient = ref.watch(apiClientProvider);
  if (server.provider == ApiProvider.nvidia) {
    return apiClient.listNvidiaModels(server);
  }
  return apiClient.listOllamaModels(server);
});

final conversationsProvider = FutureProvider<List<Conversation>>((ref) {
  return ref.watch(conversationRepositoryProvider).listConversations();
});

final charactersProvider = FutureProvider<List<ChatCharacter>>((ref) {
  return ref.watch(characterRepositoryProvider).list();
});

final activeCharacterProvider = FutureProvider<ChatCharacter?>((ref) async {
  final repository = ref.watch(characterRepositoryProvider);
  final characters = await repository.list();
  if (characters.isEmpty) {
    return null;
  }
  final activeId = await repository.getActiveCharacterId();
  if (activeId == null) {
    return null;
  }
  return characters.firstWhere(
    (character) => character.id == activeId,
    orElse: () => characters.first,
  );
});

final globalInstructionsProvider = FutureProvider<String?>((ref) {
  return ref.watch(instructionsRepositoryProvider).loadGlobalInstructions();
});