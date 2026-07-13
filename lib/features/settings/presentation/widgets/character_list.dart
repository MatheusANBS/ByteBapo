import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../characters/domain/avatar_picker.dart';
import '../../../chat/domain/entities/chat_character.dart';
import '../../../chat/presentation/character_avatar.dart';

class CharacterList extends StatefulWidget {
  const CharacterList({
    super.key,
    required this.characters,
    required this.activeCharacter,
    required this.onCreate,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  final List<ChatCharacter> characters;
  final ChatCharacter? activeCharacter;
  final VoidCallback onCreate;
  final Future<void> Function(String id) onSelect;
  final void Function(ChatCharacter character) onEdit;
  final void Function(ChatCharacter character) onDelete;

  @override
  State<CharacterList> createState() => _CharacterListState();
}

class _CharacterListState extends State<CharacterList> {
  String _query = '';

  Future<void> _confirmDelete(ChatCharacter character) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir personagem?'),
        content: Text('"${character.name}" sera removido permanentemente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      widget.onDelete(character);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.characters.isEmpty) {
      return _EmptyCharacters(onCreate: widget.onCreate);
    }
    final normalizedQuery = _query.trim().toLowerCase();
    final filteredCharacters = widget.characters.where((character) {
      if (normalizedQuery.isEmpty) return true;
      return character.name.toLowerCase().contains(normalizedQuery);
    });
    return Column(
      children: [
        TextField(
          onChanged: (value) => setState(() => _query = value),
          decoration: const InputDecoration(
            hintText: 'Pesquisar personagens',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 8),
        for (final character in filteredCharacters)
          Padding(
            padding: const EdgeInsets.only(bottom: 1),
            child: _CharacterRow(
              character: character,
              isActive: character.id == widget.activeCharacter?.id,
              onSelect: () => widget.onSelect(character.id),
              onEdit: () => widget.onEdit(character),
              onDelete: () => _confirmDelete(character),
            ),
          ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: widget.onCreate,
            icon: const Icon(Icons.add),
            label: const Text('Adicionar personagem'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
          ),
        ),
      ],
    );
  }
}

class _CharacterRow extends StatelessWidget {
  const _CharacterRow({
    required this.character,
    required this.isActive,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  final ChatCharacter character;
  final bool isActive;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surface,
      child: InkWell(
        onTap: onSelect,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              CharacterAvatar(character: character, radius: 34),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      character.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      character.instructions.isEmpty
                          ? 'Sem instruções específicas.'
                          : character.instructions,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (isActive)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(Icons.check_circle, color: Colors.cyan),
                ),
              _RowAction(
                tooltip: 'Editar ${character.name}',
                icon: Icons.edit_outlined,
                label: 'Editar',
                onPressed: onEdit,
              ),
              _RowAction(
                tooltip: 'Excluir ${character.name}',
                icon: Icons.delete_outline,
                label: 'Excluir',
                destructive: true,
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RowAction extends StatelessWidget {
  const _RowAction({
    required this.tooltip,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.destructive = false,
  });

  final String tooltip;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? Theme.of(context).colorScheme.error : null;
    return SizedBox(
      width: 58,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: tooltip,
            onPressed: onPressed,
            icon: Icon(icon, color: color),
          ),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class CharacterEditorDialog extends StatefulWidget {
  const CharacterEditorDialog({
    super.key,
    required this.avatarPicker,
    this.character,
  });

  final AvatarPicker avatarPicker;
  final ChatCharacter? character;

  @override
  State<CharacterEditorDialog> createState() => _CharacterEditorDialogState();
}

class _CharacterEditorDialogState extends State<CharacterEditorDialog> {
  final _nameController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _uuid = const Uuid();
  String? _imagePath;
  String? _error;

  @override
  void initState() {
    super.initState();
    final character = widget.character;
    if (character != null) {
      _nameController.text = character.name;
      _instructionsController.text = character.instructions;
      _imagePath = character.imagePath;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preview = widget.character == null
        ? ChatCharacter.create(
            id: 'preview',
            name: _nameController.text.isEmpty ? 'AI' : _nameController.text,
            instructions: '',
            imagePath: _imagePath,
          )
        : widget.character!.copyWith(
            name: _nameController.text.isEmpty
                ? widget.character!.name
                : _nameController.text,
            instructions: _instructionsController.text,
            imagePath: _imagePath ?? '',
          );
    return AlertDialog(
      title: Text(widget.character == null ? 'Novo personagem' : 'Editar'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CharacterAvatar(character: preview, radius: 34),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image_outlined),
              label: const Text('Escolher foto'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _instructionsController,
              onChanged: (_) => setState(() {}),
              minLines: 5,
              maxLines: 9,
              decoration: const InputDecoration(
                alignLabelWithHint: true,
                labelText: 'Instructions',
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Salvar')),
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      final path = await widget.avatarPicker.pickImagePath();
      if (path == null || path.trim().isEmpty) {
        return;
      }
      setState(() => _imagePath = path);
    } on Exception {
      if (mounted) {
        setState(() => _error = 'Nao consegui abrir a galeria.');
      }
    }
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Informe o nome do personagem.');
      return;
    }
    final current = widget.character;
    final character = current == null
        ? ChatCharacter.create(
            id: _uuid.v4(),
            name: name,
            instructions: _instructionsController.text,
            imagePath: _imagePath,
          )
        : current.copyWith(
            name: name,
            instructions: _instructionsController.text,
            imagePath: _imagePath ?? '',
          );
    Navigator.of(context).pop(character);
  }
}

class _EmptyCharacters extends StatelessWidget {
  const _EmptyCharacters({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.person_outline),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Crie um personagem para salvar instructions e foto.',
              ),
            ),
            IconButton.filled(
              tooltip: 'Criar',
              onPressed: onCreate,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
