import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/providers.dart';
import '../domain/entities/chat_character.dart';
import '../domain/entities/generation_options.dart';
import 'chat_controller.dart';
import 'widgets/chat_composer.dart';
import 'widgets/chat_message_list.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, this.conversationId});
  final String? conversationId;
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  ThinkingMode _thinkingMode = ThinkingMode.modelDefault;
  bool _didJumpToInitialHistory = false;
  bool _hasLocalCharacterSelection = false;
  String? _localCharacterId;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final server = ref.watch(activeServerProvider);
    final model = ref.watch(selectedModelProvider);
    final characters = ref.watch(charactersProvider).value ?? const [];
    final activeCharacter = ref.watch(activeCharacterProvider).value;
    final globalInstructions = ref.watch(globalInstructionsProvider).value;
    final controller = ref.watch(chatControllerProvider(widget.conversationId));
    final _ = [
      server.value?.name,
      model.value,
      activeCharacter?.name,
    ].whereType<String>().join(' · ');
    return Scaffold(
      appBar: AppBar(
        title: const Text('BytePapo'),
        actions: [
          IconButton(
            tooltip: 'Novo chat',
            onPressed: () {
              controller?.startNew();
              setState(() {
                _hasLocalCharacterSelection = false;
                _localCharacterId = null;
              });
              context.go('/chat');
            },
            icon: const Icon(Icons.add_comment_outlined),
          ),
          IconButton(
            tooltip: 'Historico',
            onPressed: () => context.go('/history'),
            icon: const Icon(Icons.history_outlined),
          ),
          IconButton(
            tooltip: 'Configuracoes',
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: controller == null
          ? _MissingSetup(
              onServers: () => context.go('/servers'),
              onModels: () => context.go('/models'),
            )
          : ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                final selectedCharacter = _selectedCharacter(
                  controller: controller,
                  characters: characters,
                  activeCharacter: activeCharacter,
                );
                if (widget.conversationId != null &&
                    controller.messages.isNotEmpty &&
                    !_didJumpToInitialHistory) {
                  _didJumpToInitialHistory = true;
                  _jumpToEnd();
                }
                return Column(
                  children: [
                    if (controller.errorMessage != null)
                      _ChatErrorBanner(
                        message: controller.errorMessage!,
                        onDismiss: controller.clearError,
                      ),
                    Expanded(
                      child: controller.messages.isEmpty
                          ? _EmptyChat(
                              onModels: () => context.go('/models'),
                              onSettings: () => context.push('/settings'),
                            )
                          : Stack(
                              children: [
                                ChatMessageList(
                                  controller: _scrollController,
                                  messages: controller.messages,
                                  character: selectedCharacter,
                                  onDeleteMessage: controller.removeMessage,
                                ),
                                Positioned(
                                  right: 14,
                                  bottom: 14,
                                  child: FloatingActionButton.small(
                                    heroTag: 'jump-to-chat-bottom',
                                    tooltip: 'Ir para o fim',
                                    onPressed: _jumpToEnd,
                                    child: const Icon(
                                      Icons.keyboard_arrow_down,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                    ChatComposer(
                      controller: controller,
                      messageController: _messageController,
                      characters: characters,
                      activeCharacter: selectedCharacter,
                      onCharacterChanged: (characterId) {
                        setState(() {
                          _hasLocalCharacterSelection = true;
                          _localCharacterId = characterId;
                        });
                      },
                      thinkingMode: _thinkingMode,
                      onThinkingChanged: (value) =>
                          setState(() => _thinkingMode = value),
                      onSubmitted: () async {
                        final text = _messageController.text;
                        _messageController.clear();
                        await controller.send(
                          text,
                          thinking: _thinkingMode,
                          character: selectedCharacter,
                          globalInstructions: globalInstructions,
                        );
                        _scrollToEnd();
                      },
                    ),
                  ],
                );
              },
            ),
    );
  }

  void _scrollToEnd() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  });
  @override
  void didUpdateWidget(covariant ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.conversationId != widget.conversationId) {
      _didJumpToInitialHistory = false;
      _hasLocalCharacterSelection = false;
      _localCharacterId = null;
      _jumpToEnd();
    }
  }

  void _jumpToEnd() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  });

  ChatCharacter? _selectedCharacter({
    required ChatController controller,
    required List<ChatCharacter> characters,
    required ChatCharacter? activeCharacter,
  }) {
    if (_hasLocalCharacterSelection) {
      return _characterById(characters, _localCharacterId);
    }
    final conversationCharacterId = controller.conversation?.characterId;
    if (widget.conversationId != null && conversationCharacterId != null) {
      return _characterById(characters, conversationCharacterId);
    }
    if (widget.conversationId != null && controller.conversation != null) {
      return null;
    }
    return activeCharacter;
  }
}

class _MissingSetup extends StatelessWidget {
  const _MissingSetup({required this.onServers, required this.onModels});
  final VoidCallback onServers;
  final VoidCallback onModels;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Configure um servidor e selecione um modelo antes de conversar.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onServers, child: const Text('Servidor')),
          TextButton(onPressed: onModels, child: const Text('Modelos')),
        ],
      ),
    ),
  );
}

class _ChatErrorBanner extends StatelessWidget {
  const _ChatErrorBanner({required this.message, required this.onDismiss});

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.errorContainer,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.error_outline,
                  size: 20,
                  color: colors.onErrorContainer,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.onErrorContainer),
                ),
              ),
              IconButton(
                tooltip: 'Fechar erro',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 36,
                  height: 36,
                ),
                onPressed: onDismiss,
                icon: Icon(
                  Icons.close,
                  size: 18,
                  color: colors.onErrorContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat({required this.onModels, required this.onSettings});
  final VoidCallback onModels;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 36,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  'Nova conversa',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Escolha o modelo, ajuste thinking e envie sua primeira mensagem.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: onModels,
                      icon: const Icon(Icons.memory_outlined),
                      label: const Text('Modelo'),
                    ),
                    OutlinedButton.icon(
                      onPressed: onSettings,
                      icon: const Icon(Icons.tune),
                      label: const Text('Instructions'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

ChatCharacter? _characterById(List<ChatCharacter> characters, String? id) {
  if (id == null) return null;
  for (final character in characters) {
    if (character.id == id) return character;
  }
  return null;
}
