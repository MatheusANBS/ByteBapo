import 'package:flutter/material.dart';

import '../../chat/domain/entities/chat_character.dart';
import 'widgets/character_list.dart';

/// The dedicated management view keeps the settings hub intentionally quiet.
class CharacterManagementScreen extends StatelessWidget {
  const CharacterManagementScreen({
    super.key,
    required this.characters,
    required this.activeCharacter,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
    required this.onCreate,
  });

  final List<ChatCharacter> characters;
  final ChatCharacter? activeCharacter;
  final Future<void> Function(String id) onSelect;
  final void Function(ChatCharacter character) onEdit;
  final void Function(ChatCharacter character) onDelete;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personagens')),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: CharacterList(
            characters: characters,
            activeCharacter: activeCharacter,
            onCreate: onCreate,
            onSelect: onSelect,
            onEdit: onEdit,
            onDelete: onDelete,
          ),
        ),
      ),
    );
  }
}
