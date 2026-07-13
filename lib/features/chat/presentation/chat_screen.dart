import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/providers.dart';
import '../domain/entities/chat_character.dart';
import '../domain/entities/chat_message.dart';
import '../domain/entities/generation_options.dart';
import 'character_avatar.dart';
import 'chat_controller.dart';

final chatControllerProvider = Provider.autoDispose
    .family<ChatController?, String?>((ref, conversationId) {
      final server = ref.watch(activeServerProvider).value;
      final model = ref.watch(selectedModelProvider).value;
      final character = ref.watch(activeCharacterProvider).value;
      final instructions = ref.watch(globalInstructionsProvider).value;
      ref.watch(sharedPreferencesProvider);
      if (server == null || model == null) {
        return null;
      }
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
        onConversationChanged: () {
          ref.invalidate(conversationsProvider);
        },
      );
      controller.load(conversationId);
      ref.onDispose(controller.dispose);
      return controller;
    });

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

    final subtitle = [
      server.value?.name,
      model.value,
      activeCharacter?.name,
    ].whereType<String>().join(' · ');

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chat', style: TextStyle(fontSize: 18)),
            if (subtitle.isNotEmpty)
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Modelos',
            onPressed: () => context.go('/models'),
            icon: const Icon(Icons.memory_outlined),
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
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
                              itemCount: controller.messages.length,
                              itemBuilder: (context, index) {
                                final message = controller.messages[index];
                                final isFirstAssistantTurn =
                                    message.role == ChatRole.assistant &&
                                    !controller.messages
                                        .take(index)
                                        .any(
                                          (item) =>
                                              item.role == ChatRole.assistant,
                                        );
                                return _ChatBubble(
                                  message: message,
                                  character: activeCharacter,
                                  showColdStartLoader: isFirstAssistantTurn,
                                );
                              },
                            ),
                    ),
                    _ChatComposer(
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
                      onThinkingChanged: (value) {
                        setState(() => _thinkingMode = value);
                      },
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

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void didUpdateWidget(covariant ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.conversationId != widget.conversationId) {
      _didJumpToInitialHistory = false;
      _jumpToEnd();
    }
  }

  void _jumpToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }
}

class _MissingSetup extends StatelessWidget {
  const _MissingSetup({required this.onServers, required this.onModels});

  final VoidCallback onServers;
  final VoidCallback onModels;

  @override
  Widget build(BuildContext context) {
    return Center(
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
}

enum _ChatMenuAction { history, settings, clear }

class _CharacterSelector extends StatelessWidget {
  const _CharacterSelector({
    required this.characters,
    required this.activeCharacter,
    required this.enabled,
    required this.onChanged,
  });

  final List<ChatCharacter> characters;
  final ChatCharacter? activeCharacter;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: enabled ? () => _showPicker(context) : null,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.outline.withValues(alpha: 0.18),
          ),
        ),
        child: Row(
          children: [
            CharacterAvatar(character: activeCharacter, radius: 12),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                activeCharacter?.name ?? 'Sem personagem',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const Icon(Icons.expand_more, size: 18),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            children: [
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.block)),
                title: const Text('Sem personagem'),
                onTap: () {
                  onChanged(null);
                  Navigator.of(context).pop();
                },
              ),
              for (final character in characters)
                ListTile(
                  leading: CharacterAvatar(character: character, radius: 20),
                  title: Text(character.name),
                  subtitle: Text(
                    character.instructions.isEmpty
                        ? 'Sem instructions especificas.'
                        : character.instructions,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  selected: character.id == activeCharacter?.id,
                  onTap: () {
                    onChanged(character.id);
                    Navigator.of(context).pop();
                  },
                ),
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person_add_alt)),
                title: const Text('Gerenciar personagens'),
                onTap: () {
                  Navigator.of(context).pop();
                  context.go('/settings');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChatComposer extends StatelessWidget {
  const _ChatComposer({
    required this.controller,
    required this.messageController,
    required this.characters,
    required this.activeCharacter,
    required this.onCharacterChanged,
    required this.thinkingMode,
    required this.onThinkingChanged,
    required this.onSubmitted,
  });

  final ChatController controller;
  final TextEditingController messageController;
  final List<ChatCharacter> characters;
  final ChatCharacter? activeCharacter;
  final ValueChanged<String?> onCharacterChanged;
  final ThinkingMode thinkingMode;
  final ValueChanged<ThinkingMode> onThinkingChanged;
  final Future<void> Function() onSubmitted;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.24),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _CharacterSelector(
                      characters: characters,
                      activeCharacter: activeCharacter,
                      enabled: !controller.isStreaming,
                      onChanged: onCharacterChanged,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _CompactDropdown<ThinkingMode>(
                      icon: Icons.psychology_outlined,
                      value: thinkingMode,
                      enabled: !controller.isStreaming,
                      items: ThinkingMode.values,
                      labelBuilder: (mode) => 'Thinking ${mode.label}',
                      onChanged: onThinkingChanged,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (controller.isStreaming)
                    TextButton.icon(
                      onPressed: controller.cancel,
                      icon: const Icon(Icons.stop, size: 18),
                      label: const Text('Parar'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      minLines: 1,
                      maxLines: 4,
                      enabled: !controller.isStreaming,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(hintText: 'Mensagem'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: controller.isStreaming ? 'Parar' : 'Enviar',
                    onPressed: controller.isStreaming
                        ? controller.cancel
                        : () => onSubmitted(),
                    icon: Icon(
                      controller.isStreaming ? Icons.stop : Icons.send,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactDropdown<T> extends StatelessWidget {
  const _CompactDropdown({
    required this.icon,
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
    this.enabled = true,
  });

  final IconData icon;
  final T value;
  final List<T> items;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              icon: const Icon(Icons.expand_more, size: 18),
              style: Theme.of(context).textTheme.bodySmall,
              items: [
                for (final item in items)
                  DropdownMenuItem(
                    value: item,
                    child: Text(labelBuilder(item)),
                  ),
              ],
              onChanged: enabled
                  ? (value) {
                      if (value != null) onChanged(value);
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat({required this.onModels, required this.onSettings});

  final VoidCallback onModels;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Center(
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
}

class _PersonaLoadingIndicator extends StatefulWidget {
  const _PersonaLoadingIndicator({
    required this.character,
    required this.textColor,
  });

  final ChatCharacter? character;
  final Color textColor;

  @override
  State<_PersonaLoadingIndicator> createState() =>
      _PersonaLoadingIndicatorState();
}

class _PersonaLoadingIndicatorState extends State<_PersonaLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.character == null
        ? 'Carregando modelo'
        : 'Carregando ${widget.character!.name}';
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final pulse =
            1 +
            (_controller.value <= 0.5
                    ? _controller.value
                    : 1 - _controller.value) *
                0.10;
        return Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(
                scale: pulse,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.18),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: CharacterAvatar(
                    character: widget.character,
                    radius: 15,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: widget.textColor.withValues(alpha: 0.78),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              for (var index = 0; index < 3; index++)
                _LoadingDot(
                  opacity: _dotOpacity(_controller.value, index),
                  color: widget.textColor,
                ),
            ],
          ),
        );
      },
    );
  }

  double _dotOpacity(double value, int index) {
    final shifted = (value + index * 0.18) % 1;
    return shifted < 0.5 ? 0.32 + shifted * 1.2 : 0.92 - (shifted - 0.5) * 1.2;
  }
}

class _LoadingDot extends StatelessWidget {
  const _LoadingDot({required this.opacity, required this.color});

  final double opacity;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 5,
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: opacity.clamp(0.25, 0.95)),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.message,
    required this.character,
    required this.showColdStartLoader,
  });

  final ChatMessage message;
  final ChatCharacter? character;
  final bool showColdStartLoader;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final color = isUser
        ? Theme.of(context).colorScheme.primaryContainer
        : Theme.of(context).colorScheme.surfaceContainerHighest;
    final textColor = isUser
        ? Theme.of(context).colorScheme.onPrimaryContainer
        : Theme.of(context).colorScheme.onSurface;
    final isAwaitingFirstChunk =
        message.isStreaming &&
        message.content.isEmpty &&
        message.thinking.isEmpty;

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * (isUser ? 0.84 : 0.92),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Material(
            color: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.10),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isUser) ...[
                        CharacterAvatar(character: character, radius: 12),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        isUser ? 'Voce' : character?.name ?? 'Ollama',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (message.isStreaming &&
                          (!isAwaitingFirstChunk || !showColdStartLoader)) ...[
                        const SizedBox(width: 8),
                        const SizedBox.square(
                          dimension: 12,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ],
                      const Spacer(),
                      IconButton(
                        tooltip: 'Copiar',
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(
                          width: 30,
                          height: 30,
                        ),
                        onPressed: message.content.isEmpty
                            ? null
                            : () => Clipboard.setData(
                                ClipboardData(text: message.content),
                              ),
                        icon: const Icon(Icons.copy, size: 18),
                      ),
                    ],
                  ),
                  if (message.thinking.isNotEmpty) ...[
                    Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        dense: true,
                        tilePadding: EdgeInsets.zero,
                        childrenPadding: EdgeInsets.zero,
                        initiallyExpanded: false,
                        title: Text(
                          message.isStreaming && message.content.isEmpty
                              ? 'Pensando...'
                              : 'Thinking',
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.78),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 220),
                            child: SingleChildScrollView(
                              child: MarkdownBody(
                                data: message.thinking,
                                selectable: true,
                                softLineBreak: true,
                                styleSheet: _chatMarkdownStyle(
                                  context,
                                  textColor.withValues(alpha: 0.74),
                                  italic: true,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (isAwaitingFirstChunk && showColdStartLoader)
                    _PersonaLoadingIndicator(
                      character: character,
                      textColor: textColor,
                    )
                  else if (message.content.isNotEmpty || message.isStreaming)
                    MarkdownBody(
                      data: message.content.isEmpty
                          ? ''
                          : '${message.content}${message.isStreaming ? ' |' : ''}',
                      selectable: true,
                      softLineBreak: true,
                      styleSheet: _chatMarkdownStyle(context, textColor),
                    ),
                  if (message.status == ChatMessageStatus.cancelled)
                    const Text('Cancelada.'),
                  if (message.status == ChatMessageStatus.failed)
                    const Text('Falhou. Voce pode reenviar sua mensagem.'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

MarkdownStyleSheet _chatMarkdownStyle(
  BuildContext context,
  Color textColor, {
  bool italic = false,
}) {
  final theme = Theme.of(context);
  final base = MarkdownStyleSheet.fromTheme(theme);
  final body = theme.textTheme.bodyMedium?.copyWith(
    color: textColor,
    height: 1.38,
    fontStyle: italic ? FontStyle.italic : null,
  );
  final codeColor = theme.colorScheme.surface;
  final outline = theme.colorScheme.outline.withValues(alpha: 0.16);
  return base.copyWith(
    p: body,
    strong: body?.copyWith(fontWeight: FontWeight.w700),
    em: body?.copyWith(fontStyle: FontStyle.italic),
    a: body?.copyWith(
      color: theme.colorScheme.primary,
      decoration: TextDecoration.underline,
    ),
    h1: theme.textTheme.titleLarge?.copyWith(
      color: textColor,
      fontWeight: FontWeight.w800,
    ),
    h2: theme.textTheme.titleMedium?.copyWith(
      color: textColor,
      fontWeight: FontWeight.w800,
    ),
    h3: theme.textTheme.titleSmall?.copyWith(
      color: textColor,
      fontWeight: FontWeight.w700,
    ),
    code: theme.textTheme.bodySmall?.copyWith(
      color: textColor,
      fontFamily: 'monospace',
      height: 1.30,
    ),
    codeblockDecoration: BoxDecoration(
      color: codeColor.withValues(alpha: 0.78),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: outline),
    ),
    blockquoteDecoration: BoxDecoration(
      border: Border(
        left: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.46),
          width: 3,
        ),
      ),
    ),
    blockSpacing: 8,
    listIndent: 18,
    listBullet: body,
  );
}
