import 'package:flutter/material.dart';

import '../../domain/entities/chat_character.dart';
import '../../domain/entities/generation_options.dart';
import '../chat_controller.dart';
import 'chat_character_selector.dart';

class ChatComposer extends StatelessWidget {
  const ChatComposer({
    super.key,
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
            color: Theme.of(context).dividerColor.withValues(alpha: .24),
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
                    child: ChatCharacterSelector(
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
          color: Theme.of(context).colorScheme.outline.withValues(alpha: .18),
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
