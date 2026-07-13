import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/database/app_database.dart' hide ServerProfile;
import '../core/secure_storage/server_secret_store.dart';
import '../features/chat/data/repositories/character_repository_impl.dart';
import '../features/chat/data/repositories/conversation_repository_impl.dart';
import '../features/chat/data/repositories/instructions_repository_impl.dart';
import '../features/chat/domain/entities/chat_character.dart';
import '../features/chat/domain/entities/conversation.dart';
import '../features/chat/domain/repositories/character_repository.dart';
import '../features/chat/domain/repositories/conversation_repository.dart';
import '../features/chat/domain/repositories/instructions_repository.dart';
import '../features/models/data/repositories/drift_model_selection_repository.dart';
import '../features/models/domain/repositories/model_selection_repository.dart';
import '../features/providers/data/nvidia/nvidia_chat_completion_gateway.dart';
import '../features/providers/data/nvidia/nvidia_model_catalog_gateway.dart';
import '../features/providers/data/ollama/ollama_chat_completion_gateway.dart';
import '../features/providers/data/ollama/ollama_model_catalog_gateway.dart';
import '../features/providers/domain/entities/available_model.dart';
import '../features/providers/domain/provider_gateway_resolver.dart';
import '../features/servers/data/repositories/drift_server_repository.dart';
import '../features/servers/domain/entities/server_profile.dart';
import '../features/servers/domain/repositories/server_repository.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.');
});

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('AppDatabase must be overridden in main.');
});

final serverSecretStoreProvider = Provider<ServerSecretStore>((ref) {
  return FlutterServerSecretStore();
});

final serverRepositoryProvider = Provider<ServerRepository>((ref) {
  return DriftServerRepository(
    database: ref.watch(appDatabaseProvider),
    secrets: ref.watch(serverSecretStoreProvider),
  );
});

final modelSelectionRepositoryProvider = Provider<ModelSelectionRepository>((
  ref,
) {
  return DriftModelSelectionRepository(
    database: ref.watch(appDatabaseProvider),
  );
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

final providerGatewayResolverProvider = Provider<ProviderGatewayResolver>((
  ref,
) {
  return ProviderGatewayResolver(
    nvidia: ProviderGatewayBundle(
      NvidiaModelCatalogGateway(),
      NvidiaChatCompletionGateway(),
    ),
    ollama: ProviderGatewayBundle(
      OllamaModelCatalogGateway(),
      OllamaChatCompletionGateway(),
    ),
  );
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

final modelsProvider = FutureProvider<List<AvailableModel>>((ref) async {
  final server = await ref.watch(activeServerProvider.future);
  if (server == null) {
    return const [];
  }
  final resolver = ref.watch(providerGatewayResolverProvider);
  return resolver.forProvider(server.provider).catalog.listModels(server);
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
