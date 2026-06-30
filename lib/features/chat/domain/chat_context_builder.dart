import 'entities/chat_message.dart';

String? composeSystemPrompt({
  required String? globalInstructions,
  required String? characterInstructions,
}) {
  final global = globalInstructions?.trim();
  final character = characterInstructions?.trim();
  final hasGlobal = global != null && global.isNotEmpty;
  final hasCharacter = character != null && character.isNotEmpty;

  if (hasGlobal && hasCharacter) {
    return '[Politicas globais]\n$global\n\n[Personagem]\n$character';
  }
  if (hasGlobal) {
    return global;
  }
  if (hasCharacter) {
    return character;
  }
  return null;
}

List<ChatMessage> buildChatContext({
  required List<ChatMessage> messages,
  required String? systemPrompt,
}) {
  final trimmedInstructions = systemPrompt?.trim();
  if (trimmedInstructions == null || trimmedInstructions.isEmpty) {
    return messages;
  }

  final now = DateTime.now().toUtc();
  return [
    ChatMessage(
      id: 'global-instructions',
      conversationId: 'global',
      role: ChatRole.system,
      content: trimmedInstructions,
      createdAt: now,
      updatedAt: now,
    ),
    ...messages,
  ];
}
