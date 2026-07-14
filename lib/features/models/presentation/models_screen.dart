import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/providers.dart';
import '../../providers/domain/entities/available_model.dart';
import '../../servers/domain/entities/server_profile.dart';
import '../domain/model_catalog_service.dart';

class ModelsScreen extends ConsumerStatefulWidget {
  const ModelsScreen({super.key});

  @override
  ConsumerState<ModelsScreen> createState() => _ModelsScreenState();
}

class _ModelsScreenState extends ConsumerState<ModelsScreen> {
  String _query = '';
  ApiProvider? _provider;
  int _page = 1;

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(modelCatalogProvider);
    final activeServer = ref.watch(activeServerProvider).value;
    final servers = ref.watch(serverProfilesProvider).value ?? const [];
    final selectedModel = ref.watch(selectedModelProvider).value;
    return Scaffold(
      appBar: AppBar(
        title: const Text('BytePapo'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: () => ref.invalidate(modelCatalogProvider),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Configurações',
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: catalog.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => _EmptyModels(
            message: 'Não consegui carregar o catálogo de modelos.',
            actionLabel: 'Tentar novamente',
            onAction: () => ref.invalidate(modelCatalogProvider),
          ),
          data: (result) => _CatalogBody(
            result: result,
            servers: servers,
            activeServer: activeServer,
            selectedModel: selectedModel,
            query: _query,
            provider: _provider,
            page: _page,
            onQueryChanged: (value) => setState(() {
              _query = value;
              _page = 1;
            }),
            onProviderChanged: (value) => setState(() {
              _provider = value;
              _page = 1;
            }),
            onPageChanged: (value) => setState(() => _page = value),
          ),
        ),
      ),
    );
  }
}

class _CatalogBody extends ConsumerWidget {
  const _CatalogBody({
    required this.result,
    required this.servers,
    required this.activeServer,
    required this.selectedModel,
    required this.query,
    required this.provider,
    required this.page,
    required this.onQueryChanged,
    required this.onProviderChanged,
    required this.onPageChanged,
  });

  final ModelCatalogResult result;
  final List<ServerProfile> servers;
  final ServerProfile? activeServer;
  final String? selectedModel;
  final String query;
  final ApiProvider? provider;
  final int page;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<ApiProvider?> onProviderChanged;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modelPage = ModelCatalogService.page(
      result.models,
      query: query,
      provider: provider,
      page: page,
    );
    if (result.models.isEmpty && result.failures.isEmpty) {
      return const _EmptyModels(
        message: 'Cadastre um servidor para listar modelos.',
        actionLabel: 'Servidores',
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Escolher modelo',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 14),
              TextField(
                onChanged: onQueryChanged,
                decoration: const InputDecoration(
                  hintText: 'Pesquisar modelos',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 10),
              _ProviderFilter(value: provider, onChanged: onProviderChanged),
            ],
          ),
        ),
        if (result.failures.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Alguns servidores não responderam (${result.failures.length}).',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        Expanded(
          child: modelPage.items.isEmpty
              ? const Center(child: Text('Nenhum modelo encontrado.'))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  itemCount: modelPage.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 7),
                  itemBuilder: (context, index) {
                    final model = modelPage.items[index];
                    return _ModelTile(
                      model: model,
                      server: _serverForModel(model),
                      selected:
                          activeServer?.id == model.serverId &&
                          selectedModel == model.id,
                    );
                  },
                ),
        ),
        _Pagination(page: modelPage, onPageChanged: onPageChanged),
      ],
    );
  }

  ServerProfile? _serverForModel(AvailableModel model) {
    for (final server in servers) {
      if (server.id == model.serverId) return server;
    }
    return null;
  }
}

class _ProviderFilter extends StatelessWidget {
  const _ProviderFilter({required this.value, required this.onChanged});
  final ApiProvider? value;
  final ValueChanged<ApiProvider?> onChanged;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Text('Fornecedor'),
          const Spacer(),
          DropdownButtonHideUnderline(
            child: DropdownButton<ApiProvider?>(
              value: value,
              hint: const Text('Todos'),
              items: const [
                DropdownMenuItem(value: null, child: Text('Todos')),
                DropdownMenuItem(
                  value: ApiProvider.nvidia,
                  child: Text('NVIDIA'),
                ),
                DropdownMenuItem(
                  value: ApiProvider.ollama,
                  child: Text('Ollama'),
                ),
              ],
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    ),
  );
}

class _ModelTile extends ConsumerWidget {
  const _ModelTile({
    required this.model,
    required this.server,
    required this.selected,
  });
  final AvailableModel model;
  final ServerProfile? server;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Material(
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: selected
          ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5)
          : BorderSide.none,
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () async {
        await ref
            .read(modelSelectionRepositoryProvider)
            .selectModelAndActivateServer(
              model: model.id,
              serverProfileId: model.serverId,
            );
        ref.invalidate(activeServerProvider);
        ref.invalidate(selectedModelProvider);
        if (context.mounted) context.go('/chat');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            _ProviderMark(provider: model.provider, server: server),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.displayName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    server?.name ??
                        (model.provider == ApiProvider.nvidia
                            ? 'NVIDIA'
                            : 'Ollama'),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (model.sizeBytes != null)
              Text(_size(model), style: Theme.of(context).textTheme.bodySmall),
            if (selected) ...[
              const SizedBox(width: 12),
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ],
        ),
      ),
    ),
  );

  String _size(AvailableModel model) {
    final bytes = model.sizeBytes;
    if (bytes == null) return '';
    final megabytes = bytes / 1024 / 1024;
    return '${megabytes.toStringAsFixed(megabytes >= 1024 ? 0 : 1)} MB';
  }
}

class _ProviderMark extends StatelessWidget {
  const _ProviderMark({required this.provider, required this.server});
  final ApiProvider provider;
  final ServerProfile? server;

  @override
  Widget build(BuildContext context) {
    final avatarPath = server?.avatarPath;
    final hasAvatar = avatarPath != null && File(avatarPath).existsSync();
    if (hasAvatar) {
      return CircleAvatar(
        radius: 19,
        backgroundImage: FileImage(File(avatarPath)),
      );
    }
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: provider == ApiProvider.nvidia
            ? Colors.lightGreenAccent.shade400.withValues(alpha: 0.15)
            : Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Icon(
        provider == ApiProvider.nvidia
            ? Icons.cloud_outlined
            : Icons.all_inclusive,
        color: provider == ApiProvider.nvidia
            ? Colors.lightGreenAccent.shade400
            : Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _Pagination extends StatelessWidget {
  const _Pagination({required this.page, required this.onPageChanged});
  final ModelPage page;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton.icon(
          onPressed: page.hasPrevious
              ? () => onPageChanged(page.page - 1)
              : null,
          icon: const Icon(Icons.chevron_left),
          label: const Text('Anterior'),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Página ${page.page} de ${page.pageCount}'),
            const SizedBox(height: 3),
            Text('${page.start}-${page.end} de ${page.total}'),
          ],
        ),
        OutlinedButton.icon(
          onPressed: page.hasNext ? () => onPageChanged(page.page + 1) : null,
          icon: const Icon(Icons.chevron_right),
          label: const Text('Próxima'),
        ),
      ],
    ),
  );
}

class _EmptyModels extends StatelessWidget {
  const _EmptyModels({
    required this.message,
    required this.actionLabel,
    this.onAction,
  });
  final String message;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.memory_outlined, size: 34),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: onAction ?? () => context.go('/servers'),
          child: Text(actionLabel),
        ),
      ],
    ),
  );
}
