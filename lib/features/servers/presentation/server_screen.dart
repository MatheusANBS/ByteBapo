import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../shared/providers.dart';
import '../domain/entities/server_profile.dart';
import 'widgets/server_form.dart';

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
  ServerProfile? _editingProfile;
  String? _avatarPath;
  String _search = '';

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
        title: const Text('BytePapo'),
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
      body: profiles.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            const Center(child: Text('Não consegui carregar servidores.')),
        data: (items) => _ServersCatalog(
          profiles: items,
          search: _search,
          onSearchChanged: (value) => setState(() => _search = value),
          onAdd: _startCreate,
          onSelect: _select,
          onEdit: _edit,
          onDelete: _confirmRemove,
          connectionLabel: _connectionLabel,
        ),
      ),
    );
  }

  void _startCreate() {
    _nameController.text = 'Ollama LAN';
    _hostController.clear();
    _portController.text = '11434';
    _basePathController.clear();
    _headerNameController.clear();
    _headerValueController.clear();
    _apiKeyController.clear();
    setState(() {
      _editingProfile = null;
      _avatarPath = null;
      _provider = ApiProvider.ollama;
      _protocol = 'http';
      _feedback = null;
    });
    _showEditor();
  }

  Future<void> _showEditor() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (sheetContext) => SizedBox(
        key: const Key('server-editor'),
        height: MediaQuery.sizeOf(sheetContext).height,
        child: StatefulBuilder(
          builder: (context, setSheetState) => SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Fechar',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                      Expanded(
                        child: Text(
                          _editingProfile == null
                              ? 'Adicionar servidor'
                              : 'Editar servidor',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(
                      20,
                      12,
                      20,
                      MediaQuery.viewInsetsOf(context).bottom + 28,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ProviderSelector(
                          provider: _provider,
                          onChanged: (value) {
                            setState(() => _provider = value);
                            setSheetState(() {});
                          },
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () async {
                            await _pickAvatar();
                            setSheetState(() {});
                          },
                          icon: const Icon(Icons.add_a_photo_outlined),
                          label: Text(
                            _avatarPath == null
                                ? 'Escolher avatar'
                                : 'Trocar avatar',
                          ),
                        ),
                        if (_avatarPath != null) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundImage: FileImage(File(_avatarPath!)),
                              ),
                              const SizedBox(width: 10),
                              const Text('Avatar selecionado'),
                            ],
                          ),
                        ],
                        const SizedBox(height: 12),
                        ServerForm(
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
                          onProtocolChanged: (value) {
                            setState(() => _protocol = value);
                            setSheetState(() {});
                          },
                          onSave: _save,
                          onTest: () async {
                            await _testConnection();
                            setSheetState(() {});
                          },
                        ),
                        if (_feedback != null) ...[
                          const SizedBox(height: 12),
                          _FeedbackStrip(message: _feedback!),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ServerProfile _buildProfile({bool includeApiKey = true}) {
    final headerName = _headerNameController.text.trim();
    final headerValue = _headerValueController.text.trim();
    final isNvidia = _provider == ApiProvider.nvidia;
    final apiKey = includeApiKey && isNvidia
        ? _apiKeyController.text.trim()
        : null;
    final protocol = isNvidia ? 'https' : _protocol;
    final host = isNvidia
        ? 'integrate.api.nvidia.com'
        : _hostController.text.trim();
    final port = isNvidia
        ? 443
        : int.tryParse(_portController.text.trim()) ?? 11434;
    final basePath = isNvidia ? '/v1' : _basePathController.text.trim();
    final headers = headerName.isEmpty || headerValue.isEmpty
        ? <String, String>{}
        : {headerName: headerValue};

    return ServerProfile.create(
      id: _editingProfile?.id ?? const Uuid().v4(),
      name: _nameController.text,
      input: '$protocol://$host:$port',
      basePath: basePath,
      headers: headers,
      provider: _provider,
      apiKey: apiKey,
      createdAt: _editingProfile?.createdAt,
      avatarPath: _avatarPath,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    try {
      final profile = _buildProfile(includeApiKey: false);
      await ref
          .read(serverCommandsProvider)
          .saveAndActivate(
            profile,
            apiKey: _provider == ApiProvider.nvidia
                ? _apiKeyController.text.trim()
                : null,
          );
      ref.invalidate(serverProfilesProvider);
      ref.invalidate(activeServerProvider);
      setState(() => _feedback = 'Servidor salvo e selecionado.');
      if (mounted) {
        context.go('/models');
      }
    } on AppException catch (error) {
      setState(() => _feedback = error.message);
    } catch (_) {
      setState(
        () => _feedback =
            'Nao consegui salvar o avatar. Escolha outra imagem e tente novamente.',
      );
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
      final result = _editingProfile == null
          ? await ref.read(serverCommandsProvider).testConnection(profile)
          : await ref
                .read(serverCommandsProvider)
                .testAndRecordConnection(profile);
      ref.invalidate(serverProfilesProvider);
      setState(() => _feedback = result.successMessage);
    } on AppException catch (error) {
      final guidance = _provider == ApiProvider.nvidia
          ? ''
          : '\nVerifique IP, porta, Wi-Fi e firewall.';
      setState(() => _feedback = '${error.message}$guidance');
    } finally {
      if (mounted) {
        setState(() => _isTesting = false);
      }
    }
  }

  Future<void> _select(ServerProfile profile) async {
    await ref.read(serverCommandsProvider).select(profile);
    ref.invalidate(activeServerProvider);
    ref.invalidate(modelsProvider);
    if (mounted) {
      context.go('/models');
    }
  }

  void _edit(ServerProfile profile) {
    _nameController.text = profile.name;
    _hostController.text = profile.host;
    _portController.text = profile.port.toString();
    _basePathController.text = profile.basePath ?? '';
    setState(() {
      _editingProfile = profile;
      _avatarPath = profile.avatarPath;
      _protocol = profile.protocol;
      _provider = profile.provider;
      _feedback = 'Editando ${profile.name}.';
    });
    _showEditor();
  }

  Future<void> _pickAvatar() async {
    try {
      final path = await ref.read(avatarPickerProvider).pickImagePath();
      if (path != null && mounted) {
        setState(() => _avatarPath = path);
      }
    } on PlatformException {
      if (mounted) {
        setState(
          () => _feedback = 'Nao consegui abrir ou copiar a imagem escolhida.',
        );
      }
    }
  }

  Future<void> _confirmRemove(ServerProfile profile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir servidor?'),
        content: Text('Remover ${profile.name} e a chave armazenada?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(serverRepositoryProvider).remove(profile.id);
    if (_editingProfile?.id == profile.id) {
      setState(() => _editingProfile = null);
    }
    ref.invalidate(serverProfilesProvider);
    ref.invalidate(activeServerProvider);
  }

  String _connectionLabel(ServerProfile profile) {
    final checkedAt = profile.lastCheckedAt;
    final status = switch (profile.lastConnectionStatus) {
      ServerConnectionStatus.connected => 'Conectado',
      ServerConnectionStatus.failed => 'Falha na última verificação',
      ServerConnectionStatus.unknown => 'Ainda não verificado',
    };
    return checkedAt == null ? status : '$status · ${checkedAt.toLocal()}';
  }
}

class _ServersCatalog extends StatelessWidget {
  const _ServersCatalog({
    required this.profiles,
    required this.search,
    required this.onSearchChanged,
    required this.onAdd,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
    required this.connectionLabel,
  });

  final List<ServerProfile> profiles;
  final String search;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onAdd;
  final ValueChanged<ServerProfile> onSelect;
  final ValueChanged<ServerProfile> onEdit;
  final ValueChanged<ServerProfile> onDelete;
  final String Function(ServerProfile) connectionLabel;

  @override
  Widget build(BuildContext context) {
    final needle = search.trim().toLowerCase();
    final filtered = profiles
        .where(
          (profile) =>
              needle.isEmpty ||
              profile.name.toLowerCase().contains(needle) ||
              profile.provider.name.contains(needle),
        )
        .toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
          child: Text(
            'Meus servidores',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            onChanged: onSearchChanged,
            decoration: const InputDecoration(
              hintText: 'Pesquisar servidores',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    profiles.isEmpty
                        ? 'Nenhum servidor cadastrado ainda.'
                        : 'Nenhum servidor encontrado.',
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) => _ServerRow(
                    profile: filtered[index],
                    connectionLabel: connectionLabel(filtered[index]),
                    onSelect: () => onSelect(filtered[index]),
                    onEdit: () => onEdit(filtered[index]),
                    onDelete: () => onDelete(filtered[index]),
                  ),
                ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
          child: SizedBox(
            height: 56,
            child: FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar servidor'),
            ),
          ),
        ),
      ],
    );
  }
}

class _ServerRow extends StatelessWidget {
  const _ServerRow({
    required this.profile,
    required this.connectionLabel,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  final ServerProfile profile;
  final String connectionLabel;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final connected =
        profile.lastConnectionStatus == ServerConnectionStatus.connected;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          _ServerAvatar(profile: profile),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: onSelect,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.provider == ApiProvider.nvidia
                          ? 'NVIDIA'
                          : 'Ollama',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 9,
                          color: connected
                              ? Colors.lightGreenAccent.shade400
                              : Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            connectionLabel,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: connected
                                      ? Colors.lightGreenAccent.shade400
                                      : null,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          _ServerAction(
            icon: Icons.edit_outlined,
            label: 'Editar',
            onPressed: onEdit,
          ),
          const SizedBox(width: 4),
          _ServerAction(
            icon: Icons.delete_outline,
            label: 'Excluir',
            color: Theme.of(context).colorScheme.error,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _ServerAvatar extends StatelessWidget {
  const _ServerAvatar({required this.profile});
  final ServerProfile profile;

  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: 34,
    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
    backgroundImage: profile.avatarPath == null
        ? null
        : FileImage(File(profile.avatarPath!)),
    child: profile.avatarPath == null
        ? Icon(
            profile.provider == ApiProvider.nvidia
                ? Icons.cloud_outlined
                : Icons.smart_toy_outlined,
            size: 30,
          )
        : null,
  );
}

class _ServerAction extends StatelessWidget {
  const _ServerAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
  });
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: InkResponse(
      onTap: onPressed,
      child: SizedBox(
        width: 46,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: color),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ProviderSelector extends StatelessWidget {
  const _ProviderSelector({required this.provider, required this.onChanged});

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
            LayoutBuilder(
              builder: (context, constraints) {
                final options = [
                  _ProviderOption(
                    selected: provider == ApiProvider.ollama,
                    icon: Icons.dns_outlined,
                    label: 'Ollama local',
                    onPressed: () => onChanged(ApiProvider.ollama),
                  ),
                  _ProviderOption(
                    selected: provider == ApiProvider.nvidia,
                    icon: Icons.cloud_outlined,
                    label: 'NVIDIA API',
                    onPressed: () => onChanged(ApiProvider.nvidia),
                  ),
                ];
                if (constraints.maxWidth < 320) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      options.first,
                      const SizedBox(height: 8),
                      options.last,
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: options.first),
                    const SizedBox(width: 8),
                    Expanded(child: options.last),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderOption extends StatelessWidget {
  const _ProviderOption({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: selected
            ? colors.primaryContainer.withValues(alpha: 0.65)
            : colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: selected ? colors.primary : colors.outline),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  if (selected) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.check, color: colors.primary, size: 18),
                  ],
                ],
              ),
            ),
          ),
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
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(message, style: Theme.of(context).textTheme.bodySmall),
      ),
    );
  }
}
