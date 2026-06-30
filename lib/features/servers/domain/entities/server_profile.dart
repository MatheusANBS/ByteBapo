import 'dart:convert';

import '../../../../core/errors/app_exception.dart';

class ServerProfile {
  const ServerProfile({
    required this.id,
    required this.name,
    required this.protocol,
    required this.host,
    required this.port,
    required this.createdAt,
    required this.updatedAt,
    this.basePath,
    this.headers = const {},
    this.lastConnectedAt,
  });

  factory ServerProfile.create({
    required String id,
    required String name,
    required String input,
    int? port,
    String? basePath,
    Map<String, String> headers = const {},
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastConnectedAt,
  }) {
    final parsed = _parseInput(input.trim(), fallbackPort: port);
    final now = DateTime.now().toUtc();
    return ServerProfile(
      id: id,
      name: name.trim().isEmpty ? 'Ollama' : name.trim(),
      protocol: parsed.protocol,
      host: parsed.host,
      port: parsed.port,
      basePath: _normalizeBasePath(basePath ?? parsed.basePath),
      headers: Map.unmodifiable(headers),
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      lastConnectedAt: lastConnectedAt,
    );
  }

  factory ServerProfile.fromJson(Map<String, dynamic> json) {
    return ServerProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      protocol: json['protocol'] as String,
      host: json['host'] as String,
      port: json['port'] as int,
      basePath: json['basePath'] as String?,
      headers: (json['headers'] as Map<String, dynamic>? ?? {}).map(
        (key, value) => MapEntry(key, value.toString()),
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastConnectedAt: json['lastConnectedAt'] == null
          ? null
          : DateTime.parse(json['lastConnectedAt'] as String),
    );
  }

  final String id;
  final String name;
  final String protocol;
  final String host;
  final int port;
  final String? basePath;
  final Map<String, String> headers;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastConnectedAt;

  String get baseUrl => resolve('').toString().replaceAll(RegExp(r'/$'), '');

  Uri resolve(String endpoint) {
    final path = [
      if (basePath != null && basePath!.isNotEmpty) basePath!,
      endpoint,
    ].join('/');
    return Uri(
      scheme: protocol,
      host: host,
      port: port,
      path: path.replaceAll(RegExp(r'/+'), '/'),
    );
  }

  ServerProfile copyWith({
    String? id,
    String? name,
    String? protocol,
    String? host,
    int? port,
    String? basePath,
    Map<String, String>? headers,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastConnectedAt,
  }) {
    return ServerProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      protocol: protocol ?? this.protocol,
      host: host ?? this.host,
      port: port ?? this.port,
      basePath: basePath ?? this.basePath,
      headers: headers ?? this.headers,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastConnectedAt: lastConnectedAt ?? this.lastConnectedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'protocol': protocol,
      'host': host,
      'port': port,
      'basePath': basePath,
      'headers': headers,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastConnectedAt': lastConnectedAt?.toIso8601String(),
    };
  }

  String encode() => jsonEncode(toJson());

  static _ParsedServerInput _parseInput(String input, {int? fallbackPort}) {
    if (input.isEmpty) {
      throw InvalidServerException('Informe o host do servidor.');
    }

    final withScheme = input.contains('://') ? input : 'http://$input';
    final uri = Uri.tryParse(withScheme);
    if (uri == null || uri.host.trim().isEmpty) {
      throw InvalidServerException('Host do servidor invalido.');
    }

    final protocol = uri.scheme.isEmpty ? 'http' : uri.scheme;
    if (protocol != 'http' && protocol != 'https') {
      throw InvalidServerException('Use protocolo HTTP ou HTTPS.');
    }

    final port = uri.hasPort
        ? uri.port
        : (fallbackPort ?? _defaultPort(protocol));
    _validatePort(port);

    return _ParsedServerInput(
      protocol: protocol,
      host: uri.host,
      port: port,
      basePath: _normalizeBasePath(uri.path),
    );
  }

  static int _defaultPort(String protocol) => protocol == 'https' ? 443 : 11434;

  static void _validatePort(int port) {
    if (port < 1 || port > 65535) {
      throw InvalidServerException('Porta deve estar entre 1 e 65535.');
    }
  }

  static String? _normalizeBasePath(String? path) {
    final trimmed = path?.trim();
    if (trimmed == null || trimmed.isEmpty || trimmed == '/') {
      return null;
    }
    final withoutTrailing = trimmed.replaceAll(RegExp(r'/+$'), '');
    return withoutTrailing.startsWith('/')
        ? withoutTrailing
        : '/$withoutTrailing';
  }
}

class _ParsedServerInput {
  const _ParsedServerInput({
    required this.protocol,
    required this.host,
    required this.port,
    this.basePath,
  });

  final String protocol;
  final String host;
  final int port;
  final String? basePath;
}
