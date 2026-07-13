import 'dart:io';

import 'package:path_provider/path_provider.dart';

abstract interface class ServerAvatarStore {
  Future<String> copyFrom(String sourcePath);

  Future<void> delete(String path);
}

class FileServerAvatarStore implements ServerAvatarStore {
  FileServerAvatarStore({Future<Directory> Function()? directoryProvider})
    : _directoryProvider = directoryProvider ?? _defaultDirectory;

  final Future<Directory> Function() _directoryProvider;

  static Future<Directory> _defaultDirectory() async {
    final documents = await getApplicationDocumentsDirectory();
    return Directory(
      '${documents.path}${Platform.pathSeparator}server_avatars',
    );
  }

  @override
  Future<String> copyFrom(String sourcePath) async {
    final directory = await _directoryProvider();
    await directory.create(recursive: true);
    final source = File(sourcePath);
    final target = File(
      '${directory.path}${Platform.pathSeparator}'
      '${DateTime.now().microsecondsSinceEpoch}_${source.uri.pathSegments.last}',
    );
    await source.copy(target.path);
    return target.path;
  }

  @override
  Future<void> delete(String path) async {
    final directory = await _directoryProvider();
    final normalizedDirectory = directory.absolute.path.replaceAll('\\', '/');
    final normalizedFile = File(path).absolute.path.replaceAll('\\', '/');
    if (!normalizedFile.startsWith('$normalizedDirectory/')) return;
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}
