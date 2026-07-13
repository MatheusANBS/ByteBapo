import 'dart:io';

import 'package:path_provider/path_provider.dart';

abstract interface class CharacterPhotoStore {
  Future<String> copyFrom(String sourcePath);

  Future<void> delete(String path);
}

class FileCharacterPhotoStore implements CharacterPhotoStore {
  FileCharacterPhotoStore({Future<Directory> Function()? directoryProvider})
    : _directoryProvider = directoryProvider ?? _defaultDirectory;

  final Future<Directory> Function() _directoryProvider;

  static Future<Directory> _defaultDirectory() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    return Directory(
      '${documentsDirectory.path}${Platform.pathSeparator}character_photos',
    );
  }

  @override
  Future<String> copyFrom(String sourcePath) async {
    final directory = await _directoryProvider();
    await directory.create(recursive: true);

    final source = File(sourcePath);
    final fileName = source.uri.pathSegments.last;
    final destination = File(
      '${directory.path}${Platform.pathSeparator}'
      '${DateTime.now().microsecondsSinceEpoch}_$fileName',
    );
    await source.copy(destination.path);
    return destination.path;
  }

  @override
  Future<void> delete(String path) async {
    final directory = await _directoryProvider();
    final directoryPath = _normalizePath(
      directory.absolute.path,
    ).replaceFirst(RegExp(r'[\\/]+$'), '');
    final filePath = _normalizePath(File(path).absolute.path);
    final prefix = '$directoryPath${Platform.pathSeparator}';
    if (!filePath.startsWith(prefix)) {
      return;
    }
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  String _normalizePath(String path) {
    return path.replaceAll(RegExp(r'[\\/]'), Platform.pathSeparator);
  }
}
