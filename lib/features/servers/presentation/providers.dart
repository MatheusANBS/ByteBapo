import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/data/repositories/drift_model_selection_repository.dart';
import '../../models/domain/repositories/model_selection_repository.dart';
import '../../models/domain/model_catalog_service.dart';
import '../../providers/data/nvidia/nvidia_chat_completion_gateway.dart';
import '../../providers/data/nvidia/nvidia_model_catalog_gateway.dart';
import '../../providers/data/ollama/ollama_chat_completion_gateway.dart';
import '../../providers/data/ollama/ollama_model_catalog_gateway.dart';
import '../../providers/domain/entities/available_model.dart';
import '../../providers/domain/provider_gateway_resolver.dart';
import '../../../../shared/core_providers.dart';
import '../application/server_commands.dart';
import '../data/repositories/drift_server_repository.dart';
import '../data/server_avatar_store.dart';
import '../domain/entities/server_profile.dart';
import '../domain/repositories/server_repository.dart';
import '../domain/server_connection_tester.dart';

final serverRepositoryProvider = Provider<ServerRepository>((ref) {
  return DriftServerRepository(
    database: ref.watch(appDatabaseProvider),
    secrets: ref.watch(serverSecretStoreProvider),
    avatarStore: FileServerAvatarStore(),
  );
});

final modelSelectionRepositoryProvider = Provider<ModelSelectionRepository>((
  ref,
) {
  return DriftModelSelectionRepository(
    database: ref.watch(appDatabaseProvider),
  );
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

final serverCommandsProvider = Provider<ServerCommands>((ref) {
  final resolver = ref.watch(providerGatewayResolverProvider);
  return ServerCommands(
    repository: ref.watch(serverRepositoryProvider),
    connectionTester: CatalogServerConnectionTester(
      nvidiaCatalog: resolver.forProvider(ApiProvider.nvidia).catalog,
      ollamaCatalog: resolver.forProvider(ApiProvider.ollama).catalog,
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
  if (profiles.isEmpty || activeId == null) return null;
  for (final profile in profiles) {
    if (profile.id == activeId) return profile;
  }
  return null;
});

final selectedModelProvider = FutureProvider<String?>((ref) async {
  final server = await ref.watch(activeServerProvider.future);
  if (server == null) return null;
  return ref
      .watch(modelSelectionRepositoryProvider)
      .getSelectedModel(serverProfileId: server.id);
});

final modelCatalogProvider = FutureProvider<ModelCatalogResult>((ref) async {
  final servers = await ref.watch(serverProfilesProvider.future);
  final resolver = ref.watch(providerGatewayResolverProvider);
  return ModelCatalogService(
    gatewayFor: (provider) => resolver.forProvider(provider).catalog,
  ).load(servers);
});

final modelsProvider = FutureProvider<List<AvailableModel>>((ref) async {
  return (await ref.watch(modelCatalogProvider.future)).models;
});
