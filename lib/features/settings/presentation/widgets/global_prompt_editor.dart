import 'package:flutter/material.dart';

class GlobalPromptEditor extends StatelessWidget {
  const GlobalPromptEditor({
    super.key,
    required this.controller,
    required this.onSave,
    required this.onClear,
  });

  final TextEditingController controller;
  final Future<void> Function(String value) onSave;
  final Future<void> Function() onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
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
                onPressed: () => onClear(),
                icon: const Icon(Icons.clear),
                label: const Text('Limpar'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => onSave(controller.text),
                icon: const Icon(Icons.save_outlined),
                label: const Text('Salvar'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
