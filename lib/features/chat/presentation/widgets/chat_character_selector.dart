import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/chat_character.dart';
import '../character_avatar.dart';

class ChatCharacterSelector extends StatelessWidget {
  const ChatCharacterSelector({
    super.key,
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
            color: Theme.of(context).colorScheme.outline.withValues(alpha: .18),
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
      builder: (context) => SafeArea(
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
      ),
    );
  }
}
