import 'dart:io';

import 'package:byte_papo/features/chat/data/character_photo_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory temporaryDirectory;
  late Directory managedDirectory;
  late CharacterPhotoStore store;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp('byte_papo_');
    managedDirectory = Directory('${temporaryDirectory.path}/characters');
    store = FileCharacterPhotoStore(
      directoryProvider: () async => managedDirectory,
    );
  });

  tearDown(() => temporaryDirectory.delete(recursive: true));

  test('copies an external photo to its managed directory', () async {
    final source = File('${temporaryDirectory.path}/source.png');
    await source.writeAsBytes([1, 2, 3]);

    final storedPath = await store.copyFrom(source.path);

    expect(storedPath, isNot(source.path));
    expect(File(storedPath).existsSync(), isTrue);
    expect(await File(storedPath).readAsBytes(), [1, 2, 3]);
    expect(managedDirectory.path, contains('characters'));
  });

  test('deletes a managed photo', () async {
    final photo = File('${managedDirectory.path}/photo.png');
    await photo.parent.create(recursive: true);
    await photo.writeAsBytes([1]);

    await store.delete(photo.path);

    expect(photo.existsSync(), isFalse);
  });

  test('does not fail deleting an absent managed photo', () async {
    await expectLater(
      store.delete('${managedDirectory.path}/missing.png'),
      completes,
    );
  });
}
