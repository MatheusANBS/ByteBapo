import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../domain/entities/chat_character.dart';
import '../../domain/entities/chat_message.dart';
import '../character_avatar.dart';
import 'message_markdown.dart';

class ChatMessageList extends StatelessWidget {
  const ChatMessageList({
    super.key,
    required this.controller,
    required this.messages,
    required this.character,
    this.onDeleteMessage,
  });

  final ScrollController controller;
  final List<ChatMessage> messages;
  final ChatCharacter? character;
  final ValueChanged<ChatMessage>? onDeleteMessage;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 72),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final showColdStartLoader =
            message.role == ChatRole.assistant &&
            !messages
                .take(index)
                .any((item) => item.role == ChatRole.assistant);
        final messageCharacter = _characterForMessage(message) ?? character;
        return _ChatBubble(
          message: message,
          character: messageCharacter,
          showColdStartLoader: showColdStartLoader,
          onDelete: onDeleteMessage == null
              ? null
              : () => onDeleteMessage!(message),
        );
      },
    );
  }
}

ChatCharacter? _characterForMessage(ChatMessage message) {
  if (message.role != ChatRole.assistant ||
      message.characterNameSnapshot == null) {
    return null;
  }
  final now = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  return ChatCharacter(
    id: message.characterIdSnapshot ?? 'message-character-${message.id}',
    name: message.characterNameSnapshot!,
    instructions: '',
    imagePath: message.characterAvatarPathSnapshot,
    createdAt: now,
    updatedAt: now,
  );
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.message,
    required this.character,
    required this.showColdStartLoader,
    required this.onDelete,
  });
  final ChatMessage message;
  final ChatCharacter? character;
  final bool showColdStartLoader;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    final color = isUser
        ? Theme.of(context).colorScheme.primaryContainer
        : Theme.of(context).colorScheme.surfaceContainerHighest;
    final textColor = isUser
        ? Theme.of(context).colorScheme.onPrimaryContainer
        : Theme.of(context).colorScheme.onSurface;
    final awaiting =
        message.isStreaming &&
        message.content.isEmpty &&
        message.thinking.isEmpty;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * (isUser ? .84 : .92),
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
                ).colorScheme.outline.withValues(alpha: .10),
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
                          (!awaiting || !showColdStartLoader)) ...[
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
                      IconButton(
                        tooltip: 'Excluir mensagem',
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(
                          width: 30,
                          height: 30,
                        ),
                        onPressed: message.isStreaming ? null : onDelete,
                        icon: const Icon(Icons.delete_outline, size: 18),
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
                            color: textColor.withValues(alpha: .78),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 220),
                            child: SingleChildScrollView(
                              child: MessageMarkdown(
                                data: message.thinking,
                                styleSheet: _markdownStyle(
                                  context,
                                  textColor.withValues(alpha: .74),
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
                  if (awaiting && showColdStartLoader)
                    _PersonaLoadingIndicator(
                      character: character,
                      textColor: textColor,
                    )
                  else if (message.content.isNotEmpty || message.isStreaming)
                    MessageMarkdown(
                      data: message.content.isEmpty
                          ? ''
                          : '${message.content}${message.isStreaming ? ' |' : ''}',
                      styleSheet: _markdownStyle(context, textColor),
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
            (_controller.value <= .5
                    ? _controller.value
                    : 1 - _controller.value) *
                .10;
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
                        ).colorScheme.primary.withValues(alpha: .18),
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
                  color: widget.textColor.withValues(alpha: .78),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              for (var i = 0; i < 3; i++)
                _LoadingDot(
                  opacity: _opacity(_controller.value, i),
                  color: widget.textColor,
                ),
            ],
          ),
        );
      },
    );
  }

  double _opacity(double value, int index) {
    final shifted = (value + index * .18) % 1;
    return shifted < .5 ? .32 + shifted * 1.2 : .92 - (shifted - .5) * 1.2;
  }
}

class _LoadingDot extends StatelessWidget {
  const _LoadingDot({required this.opacity, required this.color});
  final double opacity;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    width: 5,
    height: 5,
    margin: const EdgeInsets.only(right: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: opacity.clamp(.25, .95)),
      shape: BoxShape.circle,
    ),
  );
}

MarkdownStyleSheet _markdownStyle(
  BuildContext context,
  Color textColor, {
  bool italic = false,
}) {
  final theme = Theme.of(context);
  final body = theme.textTheme.bodyMedium?.copyWith(
    color: textColor,
    height: 1.38,
    fontStyle: italic ? FontStyle.italic : null,
  );
  return MarkdownStyleSheet.fromTheme(theme).copyWith(
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
      color: theme.colorScheme.surface.withValues(alpha: .78),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: theme.colorScheme.outline.withValues(alpha: .16),
      ),
    ),
    blockquoteDecoration: BoxDecoration(
      border: Border(
        left: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: .46),
          width: 3,
        ),
      ),
    ),
    blockSpacing: 8,
    listIndent: 18,
    listBullet: body,
  );
}
