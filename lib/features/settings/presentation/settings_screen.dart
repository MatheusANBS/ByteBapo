import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/providers.dart';
import '../../chat/domain/entities/chat_character.dart';
import '../../chat/presentation/character_avatar.dart';
import 'character_editor_screen.dart';
import 'character_management_screen.dart';
import 'widgets/global_prompt_editor.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCharacter = ref.watch(activeCharacterProvider).value;
    final instructions = ref.watch(globalInstructionsProvider).value ?? '';
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Voltar',
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/chat');
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Configurações'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
        children: [
          Text('Prompt global', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _PromptCard(
            prompt: instructions,
            onEdit: () => _editGlobalPrompt(context, ref, instructions),
          ),
          const SizedBox(height: 18),
          Text('Personagens', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _SettingsGroup(
            children: [
              _ActiveCharacterTile(character: activeCharacter),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.group_outlined),
                title: const Text('Gerenciar personagens'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const _CharactersRoute(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SettingsGroup(
            children: const [
              _DisabledSettingsTile(
                icon: Icons.palette_outlined,
                title: 'Aparência',
              ),
              Divider(height: 1),
              _DisabledSettingsTile(
                icon: Icons.info_outline,
                title: 'Sobre o BytePapo',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _editGlobalPrompt(
    BuildContext context,
    WidgetRef ref,
    String instructions,
  ) async {
    final controller = TextEditingController(text: instructions);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Prompt global'),
        content: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: GlobalPromptEditor(
              controller: controller,
              onSave: (value) async {
                await ref
                    .read(instructionsRepositoryProvider)
                    .saveGlobalInstructions(value);
                ref.invalidate(globalInstructionsProvider);
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              },
              onClear: () async {
                controller.clear();
                await ref
                    .read(instructionsRepositoryProvider)
                    .saveGlobalInstructions(null);
                ref.invalidate(globalInstructionsProvider);
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              },
            ),
          ),
        ),
      ),
    );
    controller.dispose();
  }
}

class _PromptCard extends StatelessWidget {
  const _PromptCard({required this.prompt, required this.onEdit});

  final String prompt;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              prompt.isEmpty
                  ? 'Defina instruções para todas as conversas.'
                  : prompt,
              maxLines: 8,
              overflow: TextOverflow.ellipsis,
            ),
            const Divider(height: 24),
            TextButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Editar prompt'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    borderRadius: BorderRadius.circular(10),
    clipBehavior: Clip.antiAlias,
    child: Column(children: children),
  );
}

class _ActiveCharacterTile extends StatelessWidget {
  const _ActiveCharacterTile({required this.character});
  final ChatCharacter? character;
  @override
  Widget build(BuildContext context) => ListTile(
    title: const Text('Personagem ativo'),
    subtitle: Text(character?.name ?? 'Nenhum personagem selecionado'),
    leading: CharacterAvatar(character: character, radius: 28),
    trailing: character == null
        ? null
        : const Icon(Icons.check_circle, color: Colors.cyan),
  );
}

class _DisabledSettingsTile extends StatelessWidget {
  const _DisabledSettingsTile({required this.icon, required this.title});
  final IconData icon;
  final String title;
  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon),
    title: Text(title),
    trailing: const Icon(Icons.chevron_right),
    enabled: false,
  );
}

class _CharactersRoute extends ConsumerWidget {
  const _CharactersRoute();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characters = ref.watch(charactersProvider);
    final active = ref.watch(activeCharacterProvider).value;
    return characters.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => const Scaffold(
        body: Center(child: Text('Não consegui carregar personagens.')),
      ),
      data: (items) => CharacterManagementScreen(
        characters: items,
        activeCharacter: active,
        onSelect: (id) async {
          await ref.read(characterRepositoryProvider).setActiveCharacterId(id);
          ref.invalidate(activeCharacterProvider);
        },
        onEdit: (character) => _edit(context, ref, character),
        onDelete: (character) async {
          await ref.read(characterRepositoryProvider).remove(character.id);
          ref.invalidate(charactersProvider);
          ref.invalidate(activeCharacterProvider);
        },
        onCreate: () => _edit(context, ref, null),
      ),
    );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    ChatCharacter? character,
  ) async {
    final result = await Navigator.of(context).push<ChatCharacter>(
      MaterialPageRoute(
        builder: (_) => CharacterEditorScreen(
          character: character,
          avatarPicker: ref.read(avatarPickerProvider),
        ),
      ),
    );
    if (result == null) return;
    await ref.read(characterRepositoryProvider).save(result);
    if (character == null) {
      await ref
          .read(characterRepositoryProvider)
          .setActiveCharacterId(result.id);
    }
    ref.invalidate(charactersProvider);
    ref.invalidate(activeCharacterProvider);
  }
}
