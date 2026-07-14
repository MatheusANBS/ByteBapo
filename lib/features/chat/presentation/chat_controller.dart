import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/app_exception.dart';
import '../domain/chat_context_builder.dart';
import '../domain/entities/chat_character.dart';
import '../domain/entities/chat_message.dart';
import '../domain/entities/conversation.dart';
import '../domain/entities/generation_options.dart';
import '../domain/repositories/conversation_repository.dart';
import '../../servers/domain/entities/server_profile.dart';
import '../../providers/domain/chat_completion_gateway.dart';

class ChatController extends ChangeNotifier {
  ChatController({
    required this.chatGateway,
    required this.conversationRepository,
    required this.server,
    required this.model,
    this.onConversationChanged,
  });

  final ChatCompletionGateway chatGateway;
  final ConversationRepository conversationRepository;
  final ServerProfile server;
  final String model;
  final VoidCallback? onConversationChanged;
  final _uuid = const Uuid();

  StreamSubscription<ChatChunk>? _subscription;
  Conversation? conversation;
  List<ChatMessage> messages = const [];
  bool isStreaming = false;
  String? errorMessage;

  Future<void> load(String? conversationId) async {
    if (conversationId == null) {
      conversation = null;
      messages = const [];
      notifyListeners();
      return;
    }
    final conversations = await conversationRepository.listConversations();
    conversation = _firstWhereOrNull(
      conversations,
      (item) => item.id == conversationId,
    );
    messages = conversation == null
        ? const []
        : await conversationRepository.listMessages(conversationId);
    notifyListeners();
  }

  Future<void> send(
    String content, {
    ThinkingMode thinking = ThinkingMode.modelDefault,
    ChatCharacter? character,
    String? globalInstructions,
  }) async {
    final text = content.trim();
    if (text.isEmpty || isStreaming) {
      return;
    }
    errorMessage = null;
    final now = DateTime.now().toUtc();
    final conversationId = conversation?.id ?? _uuid.v4();
    final systemPrompt = composeSystemPrompt(
      globalInstructions: globalInstructions,
      characterInstructions: character?.instructions,
    );
    conversation ??= Conversation(
      id: conversationId,
      title: _titleFrom(text),
      serverProfileId: server.id,
      serverNameSnapshot: server.name,
      providerSnapshot: server.provider.name,
      model: model,
      characterId: character?.id,
      characterNameSnapshot: character?.name,
      systemPrompt: systemPrompt,
      createdAt: now,
      updatedAt: now,
    );
    conversation = _withCurrentContext(
      conversation!,
      character: character,
      systemPrompt: systemPrompt,
      updatedAt: now,
    );

    final userMessage = ChatMessage(
      id: _uuid.v4(),
      conversationId: conversationId,
      role: ChatRole.user,
      content: text,
      model: model,
      createdAt: now,
      updatedAt: now,
    );
    final assistantId = _uuid.v4();
    final assistantStartedAt = DateTime.now().toUtc();
    var assistantMessage = ChatMessage(
      id: assistantId,
      conversationId: conversationId,
      role: ChatRole.assistant,
      content: '',
      model: model,
      status: ChatMessageStatus.streaming,
      characterIdSnapshot: character?.id,
      characterNameSnapshot: character?.name,
      characterAvatarPathSnapshot: character?.imagePath,
      createdAt: assistantStartedAt,
      updatedAt: assistantStartedAt,
    );

    messages = [...messages, userMessage, assistantMessage];
    isStreaming = true;
    notifyListeners();
    final toolCallDeltas = <int, _ToolCallAccumulator>{};
    var streamFailed = false;

    await conversationRepository.saveConversation(conversation!);
    await conversationRepository.saveMessage(userMessage);
    onConversationChanged?.call();

    _subscription = chatGateway
        .streamChat(
          server: server,
          model: model,
          messages: buildChatContext(
            systemPrompt: conversation?.systemPrompt,
            messages: messages
                .where(
                  (item) =>
                      item.role != ChatRole.assistant ||
                      item.content.isNotEmpty,
                )
                .toList(),
          ),
          options: GenerationOptions(stream: true, thinking: thinking),
        )
        .listen(
          (chunk) {
            if (chunk.kind == ChatChunkKind.toolCall &&
                chunk.toolCall != null) {
              final delta = chunk.toolCall!;
              toolCallDeltas[delta.index] =
                  (toolCallDeltas[delta.index] ?? const _ToolCallAccumulator())
                      .merge(delta);
            }
            final nextThinking = chunk.kind == ChatChunkKind.thinking
                ? assistantMessage.thinking + chunk.text
                : assistantMessage.thinking;
            final nextContent = chunk.kind == ChatChunkKind.content
                ? assistantMessage.content + chunk.text
                : assistantMessage.content;
            assistantMessage = _replaceAssistant(
              assistantMessage,
              content: nextContent,
              thinking: nextThinking,
              status: ChatMessageStatus.streaming,
              toolCalls: _completedToolCalls(toolCallDeltas),
            );
          },
          onError: (Object error) async {
            streamFailed = true;
            final message = error is AppException
                ? error.message
                : 'Nao consegui concluir a resposta. Tente reenviar.';
            errorMessage = '$message A mensagem do usuario foi preservada.';
            assistantMessage = _replaceAssistant(
              assistantMessage,
              content: assistantMessage.content,
              thinking: assistantMessage.thinking,
              status: ChatMessageStatus.failed,
            );
            isStreaming = false;
            await conversationRepository.saveMessage(assistantMessage);
            onConversationChanged?.call();
            notifyListeners();
          },
          onDone: () async {
            if (streamFailed) {
              return;
            }
            assistantMessage = _replaceAssistant(
              assistantMessage,
              content: assistantMessage.content,
              thinking: assistantMessage.thinking,
              status: ChatMessageStatus.completed,
            );
            final updated = Conversation(
              id: conversation!.id,
              title: conversation!.title,
              serverProfileId: conversation!.serverProfileId,
              serverNameSnapshot: conversation!.serverNameSnapshot,
              providerSnapshot: conversation!.providerSnapshot,
              model: conversation!.model,
              characterId: conversation!.characterId,
              characterNameSnapshot: conversation!.characterNameSnapshot,
              systemPrompt: conversation!.systemPrompt,
              createdAt: conversation!.createdAt,
              updatedAt: DateTime.now().toUtc(),
              archivedAt: conversation!.archivedAt,
            );
            conversation = updated;
            isStreaming = false;
            await conversationRepository.saveConversation(updated);
            await conversationRepository.saveMessage(assistantMessage);
            onConversationChanged?.call();
            notifyListeners();
          },
          cancelOnError: false,
        );
  }

  Future<void> cancel() async {
    if (!isStreaming) {
      return;
    }
    await _subscription?.cancel();
    _subscription = null;
    final current = messages.lastOrNull;
    if (current != null &&
        current.role == ChatRole.assistant &&
        current.status == ChatMessageStatus.streaming) {
      final cancelled = ChatMessage(
        id: current.id,
        conversationId: current.conversationId,
        role: current.role,
        content: current.content,
        thinking: current.thinking,
        model: current.model,
        status: ChatMessageStatus.cancelled,
        characterIdSnapshot: current.characterIdSnapshot,
        characterNameSnapshot: current.characterNameSnapshot,
        characterAvatarPathSnapshot: current.characterAvatarPathSnapshot,
        createdAt: current.createdAt,
        updatedAt: DateTime.now().toUtc(),
      );
      messages = [...messages.take(messages.length - 1), cancelled];
      await conversationRepository.saveMessage(cancelled);
      onConversationChanged?.call();
    }
    isStreaming = false;
    errorMessage = 'Geracao cancelada.';
    notifyListeners();
  }

  Future<void> clear() async {
    if (conversation != null) {
      await conversationRepository.removeConversation(conversation!.id);
      onConversationChanged?.call();
    }
    conversation = null;
    messages = const [];
    errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  Future<void> removeMessage(ChatMessage message) async {
    await conversationRepository.removeMessage(message.id);
    messages = [
      for (final item in messages)
        if (item.id != message.id) item,
    ];
    onConversationChanged?.call();
    notifyListeners();
  }

  void startNew() {
    conversation = null;
    messages = const [];
    errorMessage = null;
    notifyListeners();
  }

  Conversation _withCurrentContext(
    Conversation current, {
    required ChatCharacter? character,
    required String? systemPrompt,
    required DateTime updatedAt,
  }) {
    return Conversation(
      id: current.id,
      title: current.title,
      serverProfileId: current.serverProfileId,
      serverNameSnapshot: current.serverNameSnapshot,
      providerSnapshot: current.providerSnapshot,
      model: current.model,
      characterId: character?.id,
      characterNameSnapshot: character?.name,
      systemPrompt: systemPrompt,
      createdAt: current.createdAt,
      updatedAt: updatedAt,
      archivedAt: current.archivedAt,
    );
  }

  ChatMessage _replaceAssistant(
    ChatMessage previous, {
    required String content,
    required String thinking,
    required ChatMessageStatus status,
    List<ToolCall>? toolCalls,
  }) {
    final next = ChatMessage(
      id: previous.id,
      conversationId: previous.conversationId,
      role: previous.role,
      content: content,
      thinking: thinking,
      model: previous.model,
      status: status,
      toolCalls: toolCalls ?? previous.toolCalls,
      characterIdSnapshot: previous.characterIdSnapshot,
      characterNameSnapshot: previous.characterNameSnapshot,
      characterAvatarPathSnapshot: previous.characterAvatarPathSnapshot,
      createdAt: previous.createdAt,
      updatedAt: DateTime.now().toUtc(),
    );
    messages = [
      for (final message in messages)
        if (message.id == next.id) next else message,
    ];
    notifyListeners();
    return next;
  }

  String _titleFrom(String text) {
    final compact = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (compact.isEmpty) {
      return 'Nova conversa';
    }
    return compact.length <= 40 ? compact : '${compact.substring(0, 40)}...';
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

List<ToolCall> _completedToolCalls(
  Map<int, _ToolCallAccumulator> accumulators,
) {
  final entries =
      accumulators.entries.where((entry) => entry.value.isComplete).toList()
        ..sort((left, right) => left.key.compareTo(right.key));
  return entries.map((entry) => entry.value.toToolCall()).toList();
}

class _ToolCallAccumulator {
  const _ToolCallAccumulator({this.id, this.name, this.arguments = ''});

  final String? id;
  final String? name;
  final String arguments;

  bool get isComplete => id != null && name != null;

  _ToolCallAccumulator merge(ToolCallDelta delta) {
    return _ToolCallAccumulator(
      id: delta.id ?? id,
      name: delta.name ?? name,
      arguments: arguments + (delta.arguments ?? ''),
    );
  }

  ToolCall toToolCall() => ToolCall(id: id!, name: name!, arguments: arguments);
}

extension _LastOrNull<T> on List<T> {
  T? get lastOrNull => isEmpty ? null : last;
}

T? _firstWhereOrNull<T>(Iterable<T> items, bool Function(T item) test) {
  for (final item in items) {
    if (test(item)) {
      return item;
    }
  }
  return null;
}
