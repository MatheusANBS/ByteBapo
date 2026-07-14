import 'package:byte_papo/core/database/app_database.dart';
import 'package:byte_papo/core/secure_storage/server_secret_store.dart';
import 'package:byte_papo/features/settings/presentation/settings_screen.dart';
import 'package:byte_papo/shared/providers.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('uses the standard app bar back button when pushed', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          serverSecretStoreProvider.overrideWithValue(_MemorySecretStore()),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).push<void>(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                  child: const Text('Abrir config'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir config'));
    await tester.pumpAndSettle();

    expect(find.byType(BackButton), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Abrir config'), findsOneWidget);
  });

  testWidgets('saves global prompt and closes editor without Flutter errors', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          serverSecretStoreProvider.overrideWithValue(_MemorySecretStore()),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Editar prompt'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Prompt visual salvo');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Prompt global'), findsOneWidget);
    expect(find.text('Prompt visual salvo'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _MemorySecretStore implements ServerSecretStore {
  final _values = <String, String>{};

  @override
  Future<void> delete(String alias) async => _values.remove(alias);

  @override
  Future<String?> read(String alias) async => _values[alias];

  @override
  Future<void> write(String alias, String value) async {
    _values[alias] = value;
  }
}
