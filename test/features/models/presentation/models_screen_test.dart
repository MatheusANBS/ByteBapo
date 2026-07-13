import 'package:byte_papo/core/database/app_database.dart'
    hide ChatCharacter, Conversation, ServerProfile;
import 'package:byte_papo/features/models/domain/model_catalog_service.dart';
import 'package:byte_papo/features/models/presentation/models_screen.dart';
import 'package:byte_papo/features/providers/domain/entities/available_model.dart';
import 'package:byte_papo/features/servers/domain/entities/server_profile.dart';
import 'package:byte_papo/shared/providers.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('tapping a model persists it and opens chat', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final server = ServerProfile.create(
      id: 'server-1',
      name: 'Notebook',
      input: 'http://192.168.0.2:11434',
    );
    final now = DateTime.utc(2026);
    await database
        .into(database.serverProfiles)
        .insert(
          ServerProfilesCompanion.insert(
            id: server.id,
            name: server.name,
            provider: server.provider.name,
            protocol: server.protocol,
            host: server.host,
            port: server.port,
            createdAt: now,
            updatedAt: now,
          ),
        );
    final router = GoRouter(
      initialLocation: '/models',
      routes: [
        GoRoute(path: '/models', builder: (_, _) => const ModelsScreen()),
        GoRoute(
          path: '/chat',
          builder: (_, _) => const Scaffold(body: Text('Chat pronto')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          modelCatalogProvider.overrideWithValue(
            const AsyncValue.data(
              ModelCatalogResult(
                models: [
                  AvailableModel(
                    id: 'qwen3:latest',
                    displayName: 'Qwen 3',
                    serverId: 'server-1',
                    provider: ApiProvider.ollama,
                  ),
                ],
                failures: [],
              ),
            ),
          ),
          activeServerProvider.overrideWithValue(AsyncValue.data(server)),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Qwen 3'));
    await tester.pumpAndSettle();

    expect(find.text('Chat pronto'), findsOneWidget);
    expect(
      (await database.select(database.selectedModels).getSingle()).modelId,
      'qwen3:latest',
    );
    expect(
      await database.readSetting(AppSettingKey.activeServerId),
      'server-1',
    );
  });
}
