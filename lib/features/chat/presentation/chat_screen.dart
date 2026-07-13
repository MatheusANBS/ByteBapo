import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/providers.dart';
import '../domain/entities/generation_options.dart';
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
            tooltip: 'Historico',
            onPressed: () => context.go('/history'),
            icon: const Icon(Icons.history_outlined),
          ),
          PopupMenuButton<_ChatMenuAction>(
            tooltip: 'Mais',
            onSelected: (action) {
              switch (action) {
                case _ChatMenuAction.history:
                  context.go('/history');
                case _ChatMenuAction.settings:
                  context.go('/settings');
                case _ChatMenuAction.clear:
                  controller?.clear();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: _ChatMenuAction.history,
                child: ListTile(
                  leading: Icon(Icons.history),
                  title: Text('Historico'),
                ),
              ),
              PopupMenuItem(
                value: _ChatMenuAction.settings,
                child: ListTile(
                  leading: Icon(Icons.tune),
                  title: Text('Configuracoes'),
                ),
              ),
              PopupMenuItem(
                value: _ChatMenuAction.clear,
                child: ListTile(
                  leading: Icon(Icons.delete_outline),
                  title: Text('Limpar conversa'),
                ),
              ),
            ],
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
                if (widget.conversationId != null &&
                    controller.messages.isNotEmpty &&
                    !_didJumpToInitialHistory) {
                  _didJumpToInitialHistory = true;
                  _jumpToEnd();
                }
                return Column(
                  children: [
                    if (controller.errorMessage != null)
                      MaterialBanner(
                        content: Text(controller.errorMessage!),
                        actions: [
                          TextButton(onPressed: () {}, child: const Text('OK')),
                        ],
                      ),
                    Expanded(
                      child: controller.messages.isEmpty
                          ? _EmptyChat(
                              onModels: () => context.go('/models'),
                              onSettings: () => context.go('/settings'),
                            )
                          : ChatMessageList(
                              controller: _scrollController,
                              messages: controller.messages,
                              character: activeCharacter,
                            ),
                    ),
                    ChatComposer(
                      controller: controller,
                      messageController: _messageController,
                      characters: characters,
                      activeCharacter: activeCharacter,
                      onCharacterChanged: (characterId) async {
                        await ref
                            .read(characterRepositoryProvider)
                            .setActiveCharacterId(characterId);
                        ref.invalidate(activeCharacterProvider);
                      },
                      thinkingMode: _thinkingMode,
                      onThinkingChanged: (value) =>
                          setState(() => _thinkingMode = value),
                      onSubmitted: () async {
                        final text = _messageController.text;
                        _messageController.clear();
                        await controller.send(text, thinking: _thinkingMode);
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
      _jumpToEnd();
    }
  }

  void _jumpToEnd() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  });
}

enum _ChatMenuAction { history, settings, clear }

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

class _EmptyChat extends StatelessWidget {
  const _EmptyChat({required this.onModels, required this.onSettings});
  final VoidCallback onModels;
  final VoidCallback onSettings;
  @override
  Widget build(BuildContext context) => Center(
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
          Text('Nova conversa', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            'Escolha o modelo, ajuste thinking e envie sua primeira mensagem.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
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
  );
}
