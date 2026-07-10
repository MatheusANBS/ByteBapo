import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../shared/providers.dart';
import '../domain/entities/server_profile.dart';

class ServerScreen extends ConsumerStatefulWidget {
  const ServerScreen({super.key});

  @override
  ConsumerState<ServerScreen> createState() => _ServerScreenState();
}

class _ServerScreenState extends ConsumerState<ServerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Ollama LAN');
  final _hostController = TextEditingController();
  final _portController = TextEditingController(text: '11434');
  final _basePathController = TextEditingController();
  final _headerNameController = TextEditingController();
  final _headerValueController = TextEditingController();
  final _apiKeyController = TextEditingController();
  ApiProvider _provider = ApiProvider.ollama;
  String _protocol = 'http';
  bool _isTesting = false;
  String? _feedback;

  @override
  void dispose() {
    _nameController.dispose();
    _hostController.dispose();
    _portController.dispose();
    _basePathController.dispose();
    _headerNameController.dispose();
    _headerValueController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profiles = ref.watch(serverProfilesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servidor'),
        actions: [
          IconButton(
            tooltip: 'Modelos',
            onPressed: () => context.go('/models'),
            icon: const Icon(Icons.view_list_outlined),
          ),
          IconButton(
            tooltip: 'Historico',
            onPressed: () => context.go('/history'),
            icon: const Icon(Icons.history),
          ),
          IconButton(
            tooltip: 'Configuracoes',
            onPressed: () => context.go('/settings'),
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        children: [
          _InfoStrip(
            icon: Icons.lan_outlined,
            title: 'Servidor',
            message:
                'Configure um servidor Ollama (LAN) ou use a API NVIDIA (build.nvidia.com).',
          ),
          const SizedBox(height: 12),
          _ProviderSelector(
            provider: _provider,
            onChanged: (value) => setState(() => _provider = value),
          ),
          const SizedBox(height: 12),
          _ServerForm(
            formKey: _formKey,
            nameController: _nameController,
            hostController: _hostController,
            portController: _portController,
            basePathController: _basePathController,
            headerNameController: _headerNameController,
            headerValueController: _headerValueController,
            apiKeyController: _apiKeyController,
            protocol: _protocol,
            provider: _provider,
            isTesting: _isTesting,
            onProtocolChanged: (value) => setState(() => _protocol = value),
            onSave: _save,
            onTest: _testConnection,
          ),
          if (_feedback != null) ...[
            const SizedBox(height: 10),
            _FeedbackStrip(message: _feedback!),
          ],
          const SizedBox(height: 18),
          Text('Servidores salvos', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          profiles.when(
            data: (items) {
              if (items.isEmpty) {
                return const Text('Nenhum servidor cadastrado ainda.');
              }
              return Column(
                children: [
                  for (final profile in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color:
                            Theme.of(context).colorScheme.surfaceContainerHighest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outline
                                .withValues(alpha: 0.14),
                          ),
                        ),
                        child: ListTile(
                        title: Text(profile.name),
                        subtitle: Text(profile.baseUrl),
                        leading: const Icon(Icons.dns_outlined),
                        trailing: IconButton(
                          tooltip: 'Selecionar',
                          icon: const Icon(Icons.check_circle_outline),
                          onPressed: () => _select(profile),
                        ),
                        onTap: () {
                          _nameController.text = profile.name;
                          _hostController.text = profile.host;
                          _portController.text = profile.port.toString();
                          _basePathController.text = profile.basePath ?? '';
                          setState(() => _protocol = profile.protocol);
                        },
                      ),
                      ),
                    ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => const Text('Nao consegui carregar servidores.'),
          ),
        ],
      ),
    );
  }

  ServerProfile _buildProfile() {
    final headerName = _headerNameController.text.trim();
    final headerValue = _headerValueController.text.trim();
    final isNvidia = _provider == ApiProvider.nvidia;
    final apiKey = isNvidia ? _apiKeyController.text.trim() : null;
    final protocol = isNvidia ? 'https' : _protocol;
    final host = isNvidia ? 'integrate.api.nvidia.com' : _hostController.text.trim();
    final port = isNvidia ? 443 : int.tryParse(_portController.text.trim()) ?? 11434;
    final basePath = isNvidia ? '/v1' : _basePathController.text.trim();
    final headers = headerName.isEmpty || headerValue.isEmpty
        ? <String, String>{}
        : {headerName: headerValue};

    return ServerProfile.create(
      id: const Uuid().v4(),
      name: _nameController.text,
      input: '$protocol://$host:$port',
      basePath: basePath,
      headers: headers,
      provider: _provider,
      apiKey: apiKey,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    try {
      final profile = _buildProfile();
      final repository = ref.read(serverRepositoryProvider);
      await repository.save(profile);
      await repository.setActiveServerId(profile.id);
      ref.invalidate(serverProfilesProvider);
      ref.invalidate(activeServerProvider);
      setState(() => _feedback = 'Servidor salvo e selecionado.');
      if (mounted) {
        context.go('/models');
      }
    } on AppException catch (error) {
      setState(() => _feedback = error.message);
    }
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isTesting = true;
      _feedback = null;
    });
    try {
      final profile = _buildProfile();
      final apiClient = ref.read(apiClientProvider);
      if (profile.provider == ApiProvider.nvidia) {
        final models = await apiClient.listNvidiaModels(profile);
        setState(
          () => _feedback =
              'Conexão NVIDIA OK. ${models.length} modelo(s) disponível(is).',
        );
      } else {
        final models = await apiClient.listOllamaModels(profile);
        setState(
          () => _feedback =
              'Servidor Ollama encontrado. ${models.length} modelo(s) carregado(s).',
        );
      }
    } on AppException catch (error) {
      setState(() => _feedback = '${error.message}\nVerifique IP, porta, Wi-Fi e firewall.');
    } finally {
      if (mounted) {
        setState(() => _isTesting = false);
      }
    }
  }

  Future<void> _select(ServerProfile profile) async {
    await ref.read(serverRepositoryProvider).setActiveServerId(profile.id);
    ref.invalidate(activeServerProvider);
    ref.invalidate(modelsProvider);
    if (mounted) {
      context.go('/models');
    }
  }
}

class _ServerForm extends StatelessWidget {
  const _ServerForm({
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
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Informe o host.' : null,
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
              decoration: const InputDecoration(labelText: 'Base path opcional'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: headerNameController,
              decoration: const InputDecoration(labelText: 'Header opcional'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: headerValueController,
              decoration: const InputDecoration(labelText: 'Token/valor opcional'),
              obscureText: true,
            ),
            const SizedBox(height: 10),
          ],
          if (isNvidia) ...[
            _InfoStrip(
              icon: Icons.info_outline,
              title: 'API NVIDIA',
              message:
                  'A URL base será configurada automaticamente (https://integrate.api.nvidia.com/v1).',
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: apiKeyController,
              decoration: const InputDecoration(
                labelText: 'NVIDIA API Key',
                hintText: 'nvapi-...',
                helperText: 'Obtenha em https://build.nvidia.com/',
              ),
              obscureText: true,
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Informe a API Key NVIDIA.' : null,
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

class _ProviderSelector extends StatelessWidget {
  const _ProviderSelector({
    required this.provider,
    required this.onChanged,
  });

  final ApiProvider provider;
  final ValueChanged<ApiProvider> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Provedor', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<ApiProvider>(
              segments: const [
                ButtonSegment(
                  value: ApiProvider.ollama,
                  label: Text('Ollama (Local/LAN)'),
                  icon: Icon(Icons.dns_outlined),
                ),
                ButtonSegment(
                  value: ApiProvider.nvidia,
                  label: Text('NVIDIA API (build.nvidia.com)'),
                  icon: Icon(Icons.cloud_outlined),
                ),
              ],
              selected: {provider},
              onSelectionChanged: (values) => onChanged(values.first),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoStrip extends StatelessWidget {
  const _InfoStrip({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.labelLarge),
                  Text(message, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackStrip extends StatelessWidget {
  const _FeedbackStrip({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(message, style: Theme.of(context).textTheme.bodySmall),
      ),
    );
  }
}
