import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../characters/domain/avatar_picker.dart';
import '../../chat/domain/entities/chat_character.dart';
import '../../chat/presentation/character_avatar.dart';

class CharacterEditorScreen extends StatefulWidget {
  const CharacterEditorScreen({
    super.key,
    required this.avatarPicker,
    this.character,
  });

  final AvatarPicker avatarPicker;
  final ChatCharacter? character;

  @override
  State<CharacterEditorScreen> createState() => _CharacterEditorScreenState();
}

class _CharacterEditorScreenState extends State<CharacterEditorScreen> {
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
    final character = widget.character;
    final preview = character == null
        ? ChatCharacter.create(
            id: 'preview',
            name: _nameController.text.isEmpty ? 'AI' : _nameController.text,
            instructions: '',
            imagePath: _imagePath,
          )
        : character.copyWith(
            name: _nameController.text.isEmpty
                ? character.name
                : _nameController.text,
            instructions: _instructionsController.text,
            imagePath: _imagePath ?? '',
          );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          character == null ? 'Novo personagem' : 'Editar personagem',
        ),
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              24,
              18,
              24,
              MediaQuery.viewInsetsOf(context).bottom + 20,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 38,
              ),
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CharacterAvatar(character: preview, radius: 72),
                      Positioned(
                        bottom: -4,
                        right: -4,
                        child: IconButton.filledTonal(
                          tooltip: 'Alterar foto',
                          onPressed: _pickImage,
                          icon: const Icon(Icons.camera_alt_outlined),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _pickImage,
                    child: const Text('Alterar foto'),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Nome',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _nameController,
                    onChanged: (_) => setState(() {}),
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'Nome do personagem',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Prompt do personagem',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _instructionsController,
                    onChanged: (_) => setState(() {}),
                    minLines: 6,
                    maxLines: 10,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(
                      alignLabelWithHint: true,
                      hintText: 'Defina como este personagem deve responder.',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Este prompt será combinado com o prompt global.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: _submit,
                        child: const Text('Salvar personagem'),
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

  Future<void> _pickImage() async {
    try {
      final path = await widget.avatarPicker.pickImagePath();
      if (path != null && path.trim().isNotEmpty && mounted) {
        setState(() => _imagePath = path);
      }
    } on Exception {
      if (mounted) setState(() => _error = 'Não consegui abrir a galeria.');
    }
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Informe o nome do personagem.');
      return;
    }
    final existing = widget.character;
    final result = existing == null
        ? ChatCharacter.create(
            id: _uuid.v4(),
            name: name,
            instructions: _instructionsController.text,
            imagePath: _imagePath,
          )
        : existing.copyWith(
            name: name,
            instructions: _instructionsController.text,
            imagePath: _imagePath ?? '',
          );
    Navigator.of(context).pop(result);
  }
}
