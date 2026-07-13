import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../shared/providers.dart';
import '../domain/entities/chat_character.dart';
import '../domain/entities/chat_message.dart';
import '../domain/entities/conversation.dart';
import 'character_avatar.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _query = '';
  int _offset = 0;

  ConversationHistoryPage get _page => ConversationHistoryPage(
    query: _query.isEmpty ? null : _query,
    offset: _offset,
  );

  @override
  Widget build(BuildContext context) {
    final conversations = ref.watch(conversationHistoryPageProvider(_page));
    final characters = ref.watch(charactersProvider).value ?? const [];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historico'),
        actions: [
          IconButton(
            tooltip: 'Nova conversa',
            onPressed: () => context.go('/chat'),
            icon: const Icon(Icons.add_comment_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              onChanged: (value) => setState(() {
                _query = value.trim();
                _offset = 0;
              }),
              decoration: const InputDecoration(
                labelText: 'Buscar no historico',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: conversations.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) =>
                  const Center(child: Text('Nao consegui carregar historico.')),
              data: (items) => _HistoryList(
                items: items,
                characters: characters,
                onAction: _onAction,
              ),
            ),
          ),
          conversations.maybeWhen(
            data: (items) => _HistoryPagination(
              offset: _offset,
              canGoNext: items.length == ConversationHistoryPage.pageSize,
              onPrevious: _offset == 0
                  ? null
                  : () => setState(
                      () => _offset -= ConversationHistoryPage.pageSize,
                    ),
              onNext: items.length != ConversationHistoryPage.pageSize
                  ? null
                  : () => setState(
                      () => _offset += ConversationHistoryPage.pageSize,
                    ),
            ),
            orElse: SizedBox.shrink,
          ),
        ],
      ),
    );
  }

  Future<void> _onAction(
    _HistoryAction action,
    Conversation conversation,
  ) async {
    switch (action) {
      case _HistoryAction.open:
        context.go('/chat?conversation=${conversation.id}');
      case _HistoryAction.copyMarkdown:
        final messages = await ref
            .read(conversationRepositoryProvider)
            .listMessages(conversation.id);
        await Clipboard.setData(
          ClipboardData(
            text: _conversationMarkdown(
              title: conversation.title,
              model: conversation.model,
              date: conversation.createdAt,
              messages: messages,
            ),
          ),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Conversa copiada em Markdown.')),
          );
        }
      case _HistoryAction.delete:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Excluir conversa?'),
            content: Text(
              '"${conversation.title}" e suas mensagens serao removidas.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Excluir'),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          await ref
              .read(conversationRepositoryProvider)
              .removeConversation(conversation.id);
          ref.invalidate(conversationHistoryPageProvider(_page));
          ref.invalidate(conversationsProvider);
        }
    }
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({
    required this.items,
    required this.characters,
    required this.onAction,
  });

  final List<Conversation> items;
  final List<ChatCharacter> characters;
  final Future<void> Function(_HistoryAction, Conversation) onAction;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Conversas salvas aparecem aqui depois do primeiro envio.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 16),
      itemBuilder: (context, index) {
        final conversation = items[index];
        return _ConversationTile(
          conversation: conversation,
          character: _characterForConversation(
            characters,
            conversation.characterId,
          ),
          onAction: onAction,
        );
      },
      separatorBuilder: (_, _) => const SizedBox(height: 7),
      itemCount: items.length,
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.conversation,
    required this.character,
    required this.onAction,
  });

  final Conversation conversation;
  final ChatCharacter? character;
  final Future<void> Function(_HistoryAction, Conversation) onAction;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.14),
        ),
      ),
      child: ListTile(
        leading: CharacterAvatar(character: character, radius: 24),
        title: Text(conversation.title),
        subtitle: Text(
          '${conversation.model} · ${DateFormat.yMd('pt_BR').add_Hm().format(conversation.updatedAt.toLocal())}',
        ),
        trailing: PopupMenuButton<_HistoryAction>(
          tooltip: 'Acoes',
          onSelected: (action) => onAction(action, conversation),
          itemBuilder: (context) => const [
            PopupMenuItem(value: _HistoryAction.open, child: Text('Abrir')),
            PopupMenuItem(
              value: _HistoryAction.copyMarkdown,
              child: Text('Copiar Markdown'),
            ),
            PopupMenuItem(value: _HistoryAction.delete, child: Text('Excluir')),
          ],
        ),
        onTap: () => onAction(_HistoryAction.open, conversation),
      ),
    );
  }
}

class _HistoryPagination extends StatelessWidget {
  const _HistoryPagination({
    required this.offset,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
  });

  final int offset;
  final bool canGoNext;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Pagina ${offset ~/ ConversationHistoryPage.pageSize + 1}'),
            Row(
              children: [
                IconButton(
                  tooltip: 'Pagina anterior',
                  onPressed: onPrevious,
                  icon: const Icon(Icons.chevron_left),
                ),
                IconButton(
                  tooltip: 'Proxima pagina',
                  onPressed: canGoNext ? onNext : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _HistoryAction { open, copyMarkdown, delete }

ChatCharacter? _characterForConversation(
  List<ChatCharacter> characters,
  String? characterId,
) {
  if (characterId == null) return null;
  for (final character in characters) {
    if (character.id == characterId) return character;
  }
  return null;
}

String _conversationMarkdown({
  required String title,
  required String model,
  required DateTime date,
  required List<ChatMessage> messages,
}) {
  final buffer = StringBuffer()
    ..writeln('# $title')
    ..writeln()
    ..writeln('Modelo: $model')
    ..writeln(
      'Data: ${DateFormat.yMd('pt_BR').add_Hm().format(date.toLocal())}',
    )
    ..writeln();
  for (final message in messages) {
    buffer
      ..writeln('## ${_roleLabel(message.role)}')
      ..writeln();
    if (message.thinking.trim().isNotEmpty) {
      buffer
        ..writeln('> Thinking')
        ..writeln()
        ..writeln(message.thinking.trim())
        ..writeln();
    }
    buffer
      ..writeln(message.content)
      ..writeln();
  }
  return buffer.toString().trimRight();
}

String _roleLabel(ChatRole role) => switch (role) {
  ChatRole.system => 'System',
  ChatRole.user => 'User',
  ChatRole.assistant => 'Assistant',
  ChatRole.tool => 'Tool',
};
