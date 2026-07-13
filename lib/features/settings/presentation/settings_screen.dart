import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../shared/providers.dart';
import '../../chat/domain/entities/chat_character.dart';
import '../../chat/presentation/character_avatar.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _instructionsController = TextEditingController();
  bool _loaded = false;
  String? _feedback;

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final instructions = ref.watch(globalInstructionsProvider);
    final characters = ref.watch(charactersProvider);
    final activeCharacter = ref.watch(activeCharacterProvider).value;
    if (!_loaded && instructions.hasValue) {
      _loaded = true;
      _instructionsController.text = instructions.value ?? '';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personagens'),
        actions: [
          IconButton(
            tooltip: 'Chat',
            onPressed: () => context.go('/chat'),
            icon: const Icon(Icons.chat_bubble_outline),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Novo personagem',
        onPressed: () => _editCharacter(),
        child: const Icon(Icons.person_add_alt_1),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
        children: [
          _SectionHeader(
            icon: Icons.groups_2_outlined,
            title: 'Personagens',
            subtitle: 'Cada um envia suas instructions como system no chat.',
          ),
          const SizedBox(height: 10),
          characters.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => const Text('Nao consegui carregar personagens.'),
            data: (items) {
              if (items.isEmpty) {
                return _EmptyCharacters(onCreate: () => _editCharacter());
              }
              return Column(
                children: [
                  for (final character in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withValues(alpha: 0.14),
                          ),
                        ),
                        child: ListTile(
                          leading: CharacterAvatar(
                            character: character,
                            radius: 22,
                          ),
                          title: Text(character.name),
                          subtitle: Text(
                            character.instructions.isEmpty
                                ? 'Sem instructions especificas.'
                                : character.instructions,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          selected: character.id == activeCharacter?.id,
                          trailing: PopupMenuButton<_CharacterAction>(
                            tooltip: 'Acoes',
                            onSelected: (action) =>
                                _handleCharacterAction(action, character),
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: _CharacterAction.select,
                                child: Text('Usar no chat'),
                              ),
                              PopupMenuItem(
                                value: _CharacterAction.edit,
                                child: Text('Editar'),
                              ),
                              PopupMenuItem(
                                value: _CharacterAction.delete,
                                child: Text('Excluir'),
                              ),
                            ],
                          ),
                          onTap: () => _selectCharacter(character.id),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          _SectionHeader(
            icon: Icons.rule_outlined,
            title: 'Instructions globais',
            subtitle: 'Fallback usado quando nenhum personagem esta ativo.',
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _instructionsController,
            minLines: 4,
            maxLines: 8,
            decoration: const InputDecoration(
              alignLabelWithHint: true,
              labelText: 'Instructions globais',
              hintText:
                  'Ex.: Responda sempre em portugues do Brasil. Seja direto.',
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _clearGlobalInstructions,
                  icon: const Icon(Icons.clear),
                  label: const Text('Limpar'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _saveGlobalInstructions,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Salvar'),
                ),
              ),
            ],
          ),
          if (_feedback != null) ...[
            const SizedBox(height: 10),
            Text(_feedback!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }

  Future<void> _handleCharacterAction(
    _CharacterAction action,
    ChatCharacter character,
  ) async {
    switch (action) {
      case _CharacterAction.select:
        await _selectCharacter(character.id);
      case _CharacterAction.edit:
        await _editCharacter(character);
      case _CharacterAction.delete:
        await ref.read(characterRepositoryProvider).remove(character.id);
        ref.invalidate(charactersProvider);
        ref.invalidate(activeCharacterProvider);
    }
  }

  Future<void> _selectCharacter(String id) async {
    await ref.read(characterRepositoryProvider).setActiveCharacterId(id);
    ref.invalidate(activeCharacterProvider);
    setState(() => _feedback = 'Personagem selecionado para novos chats.');
  }

  Future<void> _editCharacter([ChatCharacter? character]) async {
    final result = await showDialog<ChatCharacter>(
      context: context,
      builder: (context) => _CharacterDialog(character: character),
    );
    if (result == null) {
      return;
    }
    await ref.read(characterRepositoryProvider).save(result);
    if (character == null) {
      await ref
          .read(characterRepositoryProvider)
          .setActiveCharacterId(result.id);
    }
    ref.invalidate(charactersProvider);
    ref.invalidate(activeCharacterProvider);
    setState(() => _feedback = 'Personagem salvo.');
  }

  Future<void> _saveGlobalInstructions() async {
    await ref
        .read(instructionsRepositoryProvider)
        .saveGlobalInstructions(_instructionsController.text);
    ref.invalidate(globalInstructionsProvider);
    setState(() => _feedback = 'Instructions globais salvas.');
  }

  Future<void> _clearGlobalInstructions() async {
    _instructionsController.clear();
    await ref.read(instructionsRepositoryProvider).saveGlobalInstructions(null);
    ref.invalidate(globalInstructionsProvider);
    setState(() => _feedback = 'Instructions globais removidas.');
  }
}

enum _CharacterAction { select, edit, delete }

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.labelLarge),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

class _CharacterDialog extends StatefulWidget {
  const _CharacterDialog({this.character});

  final ChatCharacter? character;

  @override
  State<_CharacterDialog> createState() => _CharacterDialogState();
}

class _CharacterDialogState extends State<_CharacterDialog> {
  static const _avatarPickerChannel = MethodChannel('byte_papo/avatar_picker');

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
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _instructionsController,
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
      final path = await _avatarPickerChannel.invokeMethod<String>(
        'pickAvatar',
      );
      if (path == null || path.trim().isEmpty) {
        return;
      }
      setState(() => _imagePath = path);
    } on PlatformException {
      setState(() => _error = 'Nao consegui abrir a galeria.');
    } on MissingPluginException {
      setState(() => _error = 'Escolha de foto disponivel no Android.');
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
