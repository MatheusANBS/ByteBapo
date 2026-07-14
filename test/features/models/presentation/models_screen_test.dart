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
import 'dart:io';

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

  testWidgets('shows the configured provider photo for model rows', (
    tester,
  ) async {
    final avatar = File(
      '${Directory.systemTemp.path}/bytepapo-model-avatar-test.png',
    );
    addTearDown(() {
      if (avatar.existsSync()) avatar.deleteSync();
    });
    avatar.writeAsBytesSync(const [
      0x89,
      0x50,
      0x4E,
      0x47,
      0x0D,
      0x0A,
      0x1A,
      0x0A,
      0x00,
      0x00,
      0x00,
      0x0D,
      0x49,
      0x48,
      0x44,
      0x52,
      0x00,
      0x00,
      0x00,
      0x01,
      0x00,
      0x00,
      0x00,
      0x01,
      0x08,
      0x06,
      0x00,
      0x00,
      0x00,
      0x1F,
      0x15,
      0xC4,
      0x89,
      0x00,
      0x00,
      0x00,
      0x0A,
      0x49,
      0x44,
      0x41,
      0x54,
      0x78,
      0x9C,
      0x63,
      0x00,
      0x01,
      0x00,
      0x00,
      0x05,
      0x00,
      0x01,
      0x0D,
      0x0A,
      0x2D,
      0xB4,
      0x00,
      0x00,
      0x00,
      0x00,
      0x49,
      0x45,
      0x4E,
      0x44,
      0xAE,
      0x42,
      0x60,
      0x82,
    ]);
    final server = ServerProfile.create(
      id: 'server-photo',
      name: 'Servidor com foto',
      input: 'http://192.168.0.2:11434',
      avatarPath: avatar.path,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          modelCatalogProvider.overrideWithValue(
            const AsyncValue.data(
              ModelCatalogResult(
                models: [
                  AvailableModel(
                    id: 'qwen3:latest',
                    displayName: 'Qwen 3',
                    serverId: 'server-photo',
                    provider: ApiProvider.ollama,
                  ),
                ],
                failures: [],
              ),
            ),
          ),
          serverProfilesProvider.overrideWithValue(AsyncValue.data([server])),
          activeServerProvider.overrideWithValue(AsyncValue.data(server)),
          selectedModelProvider.overrideWithValue(const AsyncValue.data(null)),
        ],
        child: const MaterialApp(home: ModelsScreen()),
      ),
    );

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is CircleAvatar && widget.backgroundImage is FileImage,
      ),
      findsOneWidget,
    );
  });
}
