import 'package:flutter/material.dart';

import '../../domain/entities/server_profile.dart';

class ServerForm extends StatelessWidget {
  const ServerForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.hostController,
    required this.portController,
    required this.basePathController,
    required this.headerNameController,
    required this.headerValueController,
    required this.apiKeyController,
    required this.protocol,
    required this.provider,
    required this.isTesting,
    required this.onProtocolChanged,
    required this.onSave,
    required this.onTest,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController hostController;
  final TextEditingController portController;
  final TextEditingController basePathController;
  final TextEditingController headerNameController;
  final TextEditingController headerValueController;
  final TextEditingController apiKeyController;
  final String protocol;
  final ApiProvider provider;
  final bool isTesting;
  final ValueChanged<String> onProtocolChanged;
  final VoidCallback onSave;
  final VoidCallback onTest;

  @override
  Widget build(BuildContext context) {
    final isNvidia = provider == ApiProvider.nvidia;
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: isNvidia ? 'Nome da configuração' : 'Nome amigavel',
              hintText: isNvidia ? 'ex: NVIDIA API' : 'ex: Ollama LAN',
            ),
          ),
          const SizedBox(height: 10),
          if (!isNvidia) ...[
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'http', label: Text('HTTP')),
                ButtonSegment(value: 'https', label: Text('HTTPS')),
              ],
              selected: {protocol},
              onSelectionChanged: (values) => onProtocolChanged(values.first),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: hostController,
              decoration: const InputDecoration(labelText: 'Host ou IP'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Informe o host.'
                  : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: portController,
              decoration: const InputDecoration(labelText: 'Porta'),
              keyboardType: TextInputType.number,
              validator: (value) {
                final port = int.tryParse(value ?? '');
                if (port == null || port < 1 || port > 65535) {
                  return 'Informe uma porta entre 1 e 65535.';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: basePathController,
              decoration: const InputDecoration(
                labelText: 'Base path opcional',
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: headerNameController,
              decoration: const InputDecoration(labelText: 'Header opcional'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: headerValueController,
              decoration: const InputDecoration(
                labelText: 'Token/valor opcional',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 10),
          ],
          if (isNvidia) ...[
            const _NvidiaInfoStrip(),
            const SizedBox(height: 10),
            TextFormField(
              controller: apiKeyController,
              decoration: const InputDecoration(
                labelText: 'NVIDIA API Key',
                hintText: 'nvapi-...',
                helperText: 'Obtenha em https://build.nvidia.com/',
              ),
              obscureText: true,
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Informe a API Key NVIDIA.'
                  : null,
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isTesting ? null : onTest,
                  icon: isTesting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.wifi_tethering),
                  label: Text(isNvidia ? 'Testar NVIDIA' : 'Testar Ollama'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onSave,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Salvar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NvidiaInfoStrip extends StatelessWidget {
  const _NvidiaInfoStrip();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'API NVIDIA',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                Text(
                  'A URL base será configurada automaticamente '
                  '(https://integrate.api.nvidia.com/v1).',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
