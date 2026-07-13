import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/core_providers.dart';
import '../../servers/presentation/providers.dart';
import '../data/character_photo_store.dart';
import '../data/repositories/drift_character_repository.dart';
import '../data/repositories/drift_conversation_repository.dart';
import '../data/repositories/drift_instructions_repository.dart';
import '../domain/entities/chat_character.dart';
import '../domain/entities/conversation.dart';
import '../domain/repositories/character_repository.dart';
import '../domain/repositories/conversation_repository.dart';
import '../domain/repositories/instructions_repository.dart';
import 'chat_controller.dart';

final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  return DriftConversationRepository(database: ref.watch(appDatabaseProvider));
});

final characterRepositoryProvider = Provider<CharacterRepository>((ref) {
  return DriftCharacterRepository(
    database: ref.watch(appDatabaseProvider),
    photoStore: FileCharacterPhotoStore(),
  );
});

final instructionsRepositoryProvider = Provider<InstructionsRepository>((ref) {
  return DriftInstructionsRepository(database: ref.watch(appDatabaseProvider));
});

final conversationsProvider = FutureProvider<List<Conversation>>((ref) {
  return ref.watch(conversationRepositoryProvider).listConversations();
});

class ConversationHistoryPage {
  const ConversationHistoryPage({this.query, this.offset = 0});

  static const pageSize = 10;

  final String? query;
  final int offset;

  @override
  bool operator ==(Object other) {
    return other is ConversationHistoryPage &&
        other.query == query &&
        other.offset == offset;
  }

  @override
  int get hashCode => Object.hash(query, offset);
}

final conversationHistoryPageProvider =
    FutureProvider.family<List<Conversation>, ConversationHistoryPage>((
      ref,
      page,
    ) {
      return ref
          .watch(conversationRepositoryProvider)
          .listConversationsPage(
            query: page.query,
            limit: ConversationHistoryPage.pageSize,
            offset: page.offset,
          );
    });

final charactersProvider = FutureProvider<List<ChatCharacter>>((ref) {
  return ref.watch(characterRepositoryProvider).list();
});

final activeCharacterProvider = FutureProvider<ChatCharacter?>((ref) async {
  final repository = ref.watch(characterRepositoryProvider);
  final characters = await repository.list();
  if (characters.isEmpty) return null;
  final activeId = await repository.getActiveCharacterId();
  if (activeId == null) return null;
  for (final character in characters) {
    if (character.id == activeId) return character;
  }
  return null;
});

final globalInstructionsProvider = FutureProvider<String?>((ref) {
  return ref.watch(instructionsRepositoryProvider).loadGlobalInstructions();
});

final chatControllerProvider = Provider.autoDispose
    .family<ChatController?, String?>((ref, conversationId) {
      final server = ref.watch(activeServerProvider).value;
      final model = ref.watch(selectedModelProvider).value;
      final character = ref.watch(activeCharacterProvider).value;
      final instructions = ref.watch(globalInstructionsProvider).value;
      if (server == null || model == null) return null;
      final controller = ChatController(
        chatGateway: ref
            .watch(providerGatewayResolverProvider)
            .forProvider(server.provider)
            .chat,
        conversationRepository: ref.watch(conversationRepositoryProvider),
        server: server,
        model: model,
        character: character,
        globalInstructions: instructions,
        onConversationChanged: () => ref.invalidate(conversationsProvider),
      );
      controller.load(conversationId);
      ref.onDispose(controller.dispose);
      return controller;
    });
