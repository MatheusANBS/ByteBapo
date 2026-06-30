import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../shared/providers.dart';
import '../domain/entities/chat_character.dart';
import '../domain/entities/chat_message.dart';
import 'character_avatar.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversations = ref.watch(conversationsProvider);
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
          IconButton(
            tooltip: 'Configuracoes',
            onPressed: () => context.go('/settings'),
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: conversations.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            const Center(child: Text('Nao consegui carregar historico.')),
        data: (items) {
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
              final character = _characterForConversation(
                characters,
                conversation.characterId,
              );
              return Material(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.14),
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
                    onSelected: (action) async {
                      switch (action) {
                        case _HistoryAction.open:
                          context.go('/chat?conversation=${conversation.id}');
                        case _HistoryAction.copyMarkdown:
                          final messages = await ref
                              .read(conversationRepositoryProvider)
                              .listMessages(conversation.id);
                          final markdown = _conversationMarkdown(
                            title: conversation.title,
                            model: conversation.model,
                            date: conversation.createdAt,
                            messages: messages,
                          );
                          await Clipboard.setData(
                            ClipboardData(text: markdown),
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Conversa copiada em Markdown.'),
                              ),
                            );
                          }
                        case _HistoryAction.delete:
                          await ref
                              .read(conversationRepositoryProvider)
                              .removeConversation(conversation.id);
                          ref.invalidate(conversationsProvider);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: _HistoryAction.open,
                        child: Row(
                          children: [
                            Icon(Icons.open_in_new, size: 18),
                            SizedBox(width: 10),
                            Text('Abrir'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: _HistoryAction.copyMarkdown,
                        child: Row(
                          children: [
                            Icon(Icons.copy, size: 18),
                            SizedBox(width: 10),
                            Text('Copiar Markdown'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: _HistoryAction.delete,
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 18),
                            SizedBox(width: 10),
                            Text('Excluir'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  onTap: () =>
                      context.go('/chat?conversation=${conversation.id}'),
                ),
              );
            },
            separatorBuilder: (_, _) => const SizedBox(height: 7),
            itemCount: items.length,
          );
        },
      ),
    );
  }
}

enum _HistoryAction { open, copyMarkdown, delete }

ChatCharacter? _characterForConversation(
  List<ChatCharacter> characters,
  String? characterId,
) {
  if (characterId == null) {
    return null;
  }
  for (final character in characters) {
    if (character.id == characterId) {
      return character;
    }
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

String _roleLabel(ChatRole role) {
  return switch (role) {
    ChatRole.system => 'System',
    ChatRole.user => 'User',
    ChatRole.assistant => 'Assistant',
    ChatRole.tool => 'Tool',
  };
}
