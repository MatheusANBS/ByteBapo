import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../shared/providers.dart';
import '../../providers/domain/entities/available_model.dart';
import '../domain/entities/nvidia_model.dart';
import '../domain/entities/ollama_model.dart';
import '../../servers/domain/entities/server_profile.dart';

class ModelsScreen extends ConsumerWidget {
  const ModelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final server = ref.watch(activeServerProvider);
    final models = ref.watch(modelsProvider);
    final selected = ref.watch(selectedModelProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modelos'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: () => ref.invalidate(modelsProvider),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Chat',
            onPressed: () => context.go('/chat'),
            icon: const Icon(Icons.chat_bubble_outline),
          ),
          IconButton(
            tooltip: 'Configuracoes',
            onPressed: () => context.go('/settings'),
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: server.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            const Center(child: Text('Nao consegui carregar servidor.')),
        data: (activeServer) {
          if (activeServer == null) {
            return _EmptyModels(
              message: activeServer?.provider == ApiProvider.nvidia
                  ? 'Configure a API NVIDIA antes de listar modelos.'
                  : 'Cadastre um servidor Ollama antes de listar modelos.',
              actionLabel: 'Configurar servidor',
              onAction: () => context.go('/servers'),
            );
          }
          return models.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _EmptyModels(
              message: activeServer.provider == ApiProvider.nvidia
                  ? 'Nao consegui listar modelos NVIDIA.\nVerifique a API Key e a URL base.'
                  : 'Nao consegui listar modelos.\nConfirme se o Ollama esta aberto e acessivel.',
              actionLabel: 'Tentar novamente',
              onAction: () => ref.invalidate(modelsProvider),
            ),
            data: (items) {
              if (items.isEmpty) {
                return _EmptyModels(
                  message: activeServer.provider == ApiProvider.nvidia
                      ? 'Nenhum modelo disponível na API NVIDIA.\nVerifique sua conta e permissões.'
                      : 'Nenhum modelo instalado nesse servidor.\nInstale no PC com: ollama pull llama3.2',
                  actionLabel: 'Atualizar',
                  onAction: () => ref.invalidate(modelsProvider),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 16),
                itemBuilder: (context, index) {
                  final model = items[index];
                  final modelId = model.id;
                  final isSelected = selected == modelId;
                  return Material(
                    color: isSelected
                        ? Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withValues(alpha: 0.34)
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(
                                context,
                              ).colorScheme.outline.withValues(alpha: 0.14),
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(
                        isSelected ? Icons.check_circle : Icons.memory_outlined,
                        size: 22,
                      ),
                      title: Text(modelId),
                      subtitle: Text(_subtitle(model, activeServer.provider)),
                      trailing: isSelected
                          ? const Icon(Icons.arrow_forward_ios, size: 16)
                          : FilledButton(
                              onPressed: () async {
                                await ref
                                    .read(modelSelectionRepositoryProvider)
                                    .setSelectedModel(
                                      modelId,
                                      serverProfileId: activeServer.id,
                                    );
                                ref.invalidate(selectedModelProvider);
                                if (context.mounted) {
                                  context.go('/chat');
                                }
                              },
                              child: const Text('Usar'),
                            ),
                    ),
                  );
                },
                separatorBuilder: (_, _) => const SizedBox(height: 7),
                itemCount: items.length,
              );
            },
          );
        },
      ),
    );
  }

  String _subtitle(dynamic model, ApiProvider provider) {
    if (model is AvailableModel) {
      if (model.sizeBytes != null) {
        return _formatBytes(model.sizeBytes!);
      }
      return model.provider == ApiProvider.nvidia
          ? 'Modelo NVIDIA'
          : 'Modelo Ollama';
    }
    if (model is OllamaModel) {
      final parts = <String>[];
      if (model.size != null) {
        parts.add(_formatBytes(model.size!));
      }
      if (model.modifiedAt != null) {
        parts.add(
          'atualizado em ${DateFormat.yMd('pt_BR').format(model.modifiedAt!.toLocal())}',
        );
      }
      return parts.isEmpty ? 'Sem detalhes adicionais' : parts.join(' · ');
    }
    if (model is NvidiaModel) {
      final parts = <String>[];
      if (model.created != 0) {
        final date = DateTime.fromMillisecondsSinceEpoch(
          model.created * 1000,
          isUtc: true,
        );
        parts.add(
          'criado em ${DateFormat.yMd('pt_BR').format(date.toLocal())}',
        );
      }
      if (model.ownedBy.isNotEmpty) {
        parts.add('por ${model.ownedBy}');
      }
      return parts.isEmpty ? 'Modelo NVIDIA' : parts.join(' · ');
    }
    return '';
  }

  String _formatBytes(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var value = bytes.toDouble();
    var unit = 0;
    while (value >= 1024 && unit < units.length - 1) {
      value /= 1024;
      unit += 1;
    }
    return '${value.toStringAsFixed(value >= 10 ? 0 : 1)} ${units[unit]}';
  }
}

class _EmptyModels extends StatelessWidget {
  const _EmptyModels({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.memory_outlined,
              size: 34,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
