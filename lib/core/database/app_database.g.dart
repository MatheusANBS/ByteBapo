// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ServerProfilesTable extends ServerProfiles
    with TableInfo<$ServerProfilesTable, ServerProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServerProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _protocolMeta = const VerificationMeta(
    'protocol',
  );
  @override
  late final GeneratedColumn<String> protocol = GeneratedColumn<String>(
    'protocol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hostMeta = const VerificationMeta('host');
  @override
  late final GeneratedColumn<String> host = GeneratedColumn<String>(
    'host',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _portMeta = const VerificationMeta('port');
  @override
  late final GeneratedColumn<int> port = GeneratedColumn<int>(
    'port',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _basePathMeta = const VerificationMeta(
    'basePath',
  );
  @override
  late final GeneratedColumn<String> basePath = GeneratedColumn<String>(
    'base_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avatarPathMeta = const VerificationMeta(
    'avatarPath',
  );
  @override
  late final GeneratedColumn<String> avatarPath = GeneratedColumn<String>(
    'avatar_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _apiKeyAliasMeta = const VerificationMeta(
    'apiKeyAlias',
  );
  @override
  late final GeneratedColumn<String> apiKeyAlias = GeneratedColumn<String>(
    'api_key_alias',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastConnectionStatusMeta =
      const VerificationMeta('lastConnectionStatus');
  @override
  late final GeneratedColumn<String> lastConnectionStatus =
      GeneratedColumn<String>(
        'last_connection_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('unknown'),
      );
  static const VerificationMeta _lastConnectedAtMeta = const VerificationMeta(
    'lastConnectedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastConnectedAt =
      GeneratedColumn<DateTime>(
        'last_connected_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastCheckedAtMeta = const VerificationMeta(
    'lastCheckedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastCheckedAt =
      GeneratedColumn<DateTime>(
        'last_checked_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    provider,
    protocol,
    host,
    port,
    basePath,
    avatarPath,
    apiKeyAlias,
    lastConnectionStatus,
    lastConnectedAt,
    lastCheckedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'server_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ServerProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    } else if (isInserting) {
      context.missing(_providerMeta);
    }
    if (data.containsKey('protocol')) {
      context.handle(
        _protocolMeta,
        protocol.isAcceptableOrUnknown(data['protocol']!, _protocolMeta),
      );
    } else if (isInserting) {
      context.missing(_protocolMeta);
    }
    if (data.containsKey('host')) {
      context.handle(
        _hostMeta,
        host.isAcceptableOrUnknown(data['host']!, _hostMeta),
      );
    } else if (isInserting) {
      context.missing(_hostMeta);
    }
    if (data.containsKey('port')) {
      context.handle(
        _portMeta,
        port.isAcceptableOrUnknown(data['port']!, _portMeta),
      );
    } else if (isInserting) {
      context.missing(_portMeta);
    }
    if (data.containsKey('base_path')) {
      context.handle(
        _basePathMeta,
        basePath.isAcceptableOrUnknown(data['base_path']!, _basePathMeta),
      );
    }
    if (data.containsKey('avatar_path')) {
      context.handle(
        _avatarPathMeta,
        avatarPath.isAcceptableOrUnknown(data['avatar_path']!, _avatarPathMeta),
      );
    }
    if (data.containsKey('api_key_alias')) {
      context.handle(
        _apiKeyAliasMeta,
        apiKeyAlias.isAcceptableOrUnknown(
          data['api_key_alias']!,
          _apiKeyAliasMeta,
        ),
      );
    }
    if (data.containsKey('last_connection_status')) {
      context.handle(
        _lastConnectionStatusMeta,
        lastConnectionStatus.isAcceptableOrUnknown(
          data['last_connection_status']!,
          _lastConnectionStatusMeta,
        ),
      );
    }
    if (data.containsKey('last_connected_at')) {
      context.handle(
        _lastConnectedAtMeta,
        lastConnectedAt.isAcceptableOrUnknown(
          data['last_connected_at']!,
          _lastConnectedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_checked_at')) {
      context.handle(
        _lastCheckedAtMeta,
        lastCheckedAt.isAcceptableOrUnknown(
          data['last_checked_at']!,
          _lastCheckedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ServerProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ServerProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      )!,
      protocol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}protocol'],
      )!,
      host: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}host'],
      )!,
      port: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}port'],
      )!,
      basePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_path'],
      ),
      avatarPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_path'],
      ),
      apiKeyAlias: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}api_key_alias'],
      ),
      lastConnectionStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_connection_status'],
      )!,
      lastConnectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_connected_at'],
      ),
      lastCheckedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_checked_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ServerProfilesTable createAlias(String alias) {
    return $ServerProfilesTable(attachedDatabase, alias);
  }
}

class ServerProfile extends DataClass implements Insertable<ServerProfile> {
  final String id;
  final String name;
  final String provider;
  final String protocol;
  final String host;
  final int port;
  final String? basePath;
  final String? avatarPath;
  final String? apiKeyAlias;
  final String lastConnectionStatus;
  final DateTime? lastConnectedAt;
  final DateTime? lastCheckedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ServerProfile({
    required this.id,
    required this.name,
    required this.provider,
    required this.protocol,
    required this.host,
    required this.port,
    this.basePath,
    this.avatarPath,
    this.apiKeyAlias,
    required this.lastConnectionStatus,
    this.lastConnectedAt,
    this.lastCheckedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['provider'] = Variable<String>(provider);
    map['protocol'] = Variable<String>(protocol);
    map['host'] = Variable<String>(host);
    map['port'] = Variable<int>(port);
    if (!nullToAbsent || basePath != null) {
      map['base_path'] = Variable<String>(basePath);
    }
    if (!nullToAbsent || avatarPath != null) {
      map['avatar_path'] = Variable<String>(avatarPath);
    }
    if (!nullToAbsent || apiKeyAlias != null) {
      map['api_key_alias'] = Variable<String>(apiKeyAlias);
    }
    map['last_connection_status'] = Variable<String>(lastConnectionStatus);
    if (!nullToAbsent || lastConnectedAt != null) {
      map['last_connected_at'] = Variable<DateTime>(lastConnectedAt);
    }
    if (!nullToAbsent || lastCheckedAt != null) {
      map['last_checked_at'] = Variable<DateTime>(lastCheckedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ServerProfilesCompanion toCompanion(bool nullToAbsent) {
    return ServerProfilesCompanion(
      id: Value(id),
      name: Value(name),
      provider: Value(provider),
      protocol: Value(protocol),
      host: Value(host),
      port: Value(port),
      basePath: basePath == null && nullToAbsent
          ? const Value.absent()
          : Value(basePath),
      avatarPath: avatarPath == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarPath),
      apiKeyAlias: apiKeyAlias == null && nullToAbsent
          ? const Value.absent()
          : Value(apiKeyAlias),
      lastConnectionStatus: Value(lastConnectionStatus),
      lastConnectedAt: lastConnectedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastConnectedAt),
      lastCheckedAt: lastCheckedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCheckedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ServerProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ServerProfile(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      provider: serializer.fromJson<String>(json['provider']),
      protocol: serializer.fromJson<String>(json['protocol']),
      host: serializer.fromJson<String>(json['host']),
      port: serializer.fromJson<int>(json['port']),
      basePath: serializer.fromJson<String?>(json['basePath']),
      avatarPath: serializer.fromJson<String?>(json['avatarPath']),
      apiKeyAlias: serializer.fromJson<String?>(json['apiKeyAlias']),
      lastConnectionStatus: serializer.fromJson<String>(
        json['lastConnectionStatus'],
      ),
      lastConnectedAt: serializer.fromJson<DateTime?>(json['lastConnectedAt']),
      lastCheckedAt: serializer.fromJson<DateTime?>(json['lastCheckedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'provider': serializer.toJson<String>(provider),
      'protocol': serializer.toJson<String>(protocol),
      'host': serializer.toJson<String>(host),
      'port': serializer.toJson<int>(port),
      'basePath': serializer.toJson<String?>(basePath),
      'avatarPath': serializer.toJson<String?>(avatarPath),
      'apiKeyAlias': serializer.toJson<String?>(apiKeyAlias),
      'lastConnectionStatus': serializer.toJson<String>(lastConnectionStatus),
      'lastConnectedAt': serializer.toJson<DateTime?>(lastConnectedAt),
      'lastCheckedAt': serializer.toJson<DateTime?>(lastCheckedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ServerProfile copyWith({
    String? id,
    String? name,
    String? provider,
    String? protocol,
    String? host,
    int? port,
    Value<String?> basePath = const Value.absent(),
    Value<String?> avatarPath = const Value.absent(),
    Value<String?> apiKeyAlias = const Value.absent(),
    String? lastConnectionStatus,
    Value<DateTime?> lastConnectedAt = const Value.absent(),
    Value<DateTime?> lastCheckedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ServerProfile(
    id: id ?? this.id,
    name: name ?? this.name,
    provider: provider ?? this.provider,
    protocol: protocol ?? this.protocol,
    host: host ?? this.host,
    port: port ?? this.port,
    basePath: basePath.present ? basePath.value : this.basePath,
    avatarPath: avatarPath.present ? avatarPath.value : this.avatarPath,
    apiKeyAlias: apiKeyAlias.present ? apiKeyAlias.value : this.apiKeyAlias,
    lastConnectionStatus: lastConnectionStatus ?? this.lastConnectionStatus,
    lastConnectedAt: lastConnectedAt.present
        ? lastConnectedAt.value
        : this.lastConnectedAt,
    lastCheckedAt: lastCheckedAt.present
        ? lastCheckedAt.value
        : this.lastCheckedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ServerProfile copyWithCompanion(ServerProfilesCompanion data) {
    return ServerProfile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      provider: data.provider.present ? data.provider.value : this.provider,
      protocol: data.protocol.present ? data.protocol.value : this.protocol,
      host: data.host.present ? data.host.value : this.host,
      port: data.port.present ? data.port.value : this.port,
      basePath: data.basePath.present ? data.basePath.value : this.basePath,
      avatarPath: data.avatarPath.present
          ? data.avatarPath.value
          : this.avatarPath,
      apiKeyAlias: data.apiKeyAlias.present
          ? data.apiKeyAlias.value
          : this.apiKeyAlias,
      lastConnectionStatus: data.lastConnectionStatus.present
          ? data.lastConnectionStatus.value
          : this.lastConnectionStatus,
      lastConnectedAt: data.lastConnectedAt.present
          ? data.lastConnectedAt.value
          : this.lastConnectedAt,
      lastCheckedAt: data.lastCheckedAt.present
          ? data.lastCheckedAt.value
          : this.lastCheckedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ServerProfile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('provider: $provider, ')
          ..write('protocol: $protocol, ')
          ..write('host: $host, ')
          ..write('port: $port, ')
          ..write('basePath: $basePath, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('apiKeyAlias: $apiKeyAlias, ')
          ..write('lastConnectionStatus: $lastConnectionStatus, ')
          ..write('lastConnectedAt: $lastConnectedAt, ')
          ..write('lastCheckedAt: $lastCheckedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    provider,
    protocol,
    host,
    port,
    basePath,
    avatarPath,
    apiKeyAlias,
    lastConnectionStatus,
    lastConnectedAt,
    lastCheckedAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServerProfile &&
          other.id == this.id &&
          other.name == this.name &&
          other.provider == this.provider &&
          other.protocol == this.protocol &&
          other.host == this.host &&
          other.port == this.port &&
          other.basePath == this.basePath &&
          other.avatarPath == this.avatarPath &&
          other.apiKeyAlias == this.apiKeyAlias &&
          other.lastConnectionStatus == this.lastConnectionStatus &&
          other.lastConnectedAt == this.lastConnectedAt &&
          other.lastCheckedAt == this.lastCheckedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ServerProfilesCompanion extends UpdateCompanion<ServerProfile> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> provider;
  final Value<String> protocol;
  final Value<String> host;
  final Value<int> port;
  final Value<String?> basePath;
  final Value<String?> avatarPath;
  final Value<String?> apiKeyAlias;
  final Value<String> lastConnectionStatus;
  final Value<DateTime?> lastConnectedAt;
  final Value<DateTime?> lastCheckedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ServerProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.provider = const Value.absent(),
    this.protocol = const Value.absent(),
    this.host = const Value.absent(),
    this.port = const Value.absent(),
    this.basePath = const Value.absent(),
    this.avatarPath = const Value.absent(),
    this.apiKeyAlias = const Value.absent(),
    this.lastConnectionStatus = const Value.absent(),
    this.lastConnectedAt = const Value.absent(),
    this.lastCheckedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ServerProfilesCompanion.insert({
    required String id,
    required String name,
    required String provider,
    required String protocol,
    required String host,
    required int port,
    this.basePath = const Value.absent(),
    this.avatarPath = const Value.absent(),
    this.apiKeyAlias = const Value.absent(),
    this.lastConnectionStatus = const Value.absent(),
    this.lastConnectedAt = const Value.absent(),
    this.lastCheckedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       provider = Value(provider),
       protocol = Value(protocol),
       host = Value(host),
       port = Value(port),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ServerProfile> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? provider,
    Expression<String>? protocol,
    Expression<String>? host,
    Expression<int>? port,
    Expression<String>? basePath,
    Expression<String>? avatarPath,
    Expression<String>? apiKeyAlias,
    Expression<String>? lastConnectionStatus,
    Expression<DateTime>? lastConnectedAt,
    Expression<DateTime>? lastCheckedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (provider != null) 'provider': provider,
      if (protocol != null) 'protocol': protocol,
      if (host != null) 'host': host,
      if (port != null) 'port': port,
      if (basePath != null) 'base_path': basePath,
      if (avatarPath != null) 'avatar_path': avatarPath,
      if (apiKeyAlias != null) 'api_key_alias': apiKeyAlias,
      if (lastConnectionStatus != null)
        'last_connection_status': lastConnectionStatus,
      if (lastConnectedAt != null) 'last_connected_at': lastConnectedAt,
      if (lastCheckedAt != null) 'last_checked_at': lastCheckedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ServerProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? provider,
    Value<String>? protocol,
    Value<String>? host,
    Value<int>? port,
    Value<String?>? basePath,
    Value<String?>? avatarPath,
    Value<String?>? apiKeyAlias,
    Value<String>? lastConnectionStatus,
    Value<DateTime?>? lastConnectedAt,
    Value<DateTime?>? lastCheckedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ServerProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      provider: provider ?? this.provider,
      protocol: protocol ?? this.protocol,
      host: host ?? this.host,
      port: port ?? this.port,
      basePath: basePath ?? this.basePath,
      avatarPath: avatarPath ?? this.avatarPath,
      apiKeyAlias: apiKeyAlias ?? this.apiKeyAlias,
      lastConnectionStatus: lastConnectionStatus ?? this.lastConnectionStatus,
      lastConnectedAt: lastConnectedAt ?? this.lastConnectedAt,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (protocol.present) {
      map['protocol'] = Variable<String>(protocol.value);
    }
    if (host.present) {
      map['host'] = Variable<String>(host.value);
    }
    if (port.present) {
      map['port'] = Variable<int>(port.value);
    }
    if (basePath.present) {
      map['base_path'] = Variable<String>(basePath.value);
    }
    if (avatarPath.present) {
      map['avatar_path'] = Variable<String>(avatarPath.value);
    }
    if (apiKeyAlias.present) {
      map['api_key_alias'] = Variable<String>(apiKeyAlias.value);
    }
    if (lastConnectionStatus.present) {
      map['last_connection_status'] = Variable<String>(
        lastConnectionStatus.value,
      );
    }
    if (lastConnectedAt.present) {
      map['last_connected_at'] = Variable<DateTime>(lastConnectedAt.value);
    }
    if (lastCheckedAt.present) {
      map['last_checked_at'] = Variable<DateTime>(lastCheckedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServerProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('provider: $provider, ')
          ..write('protocol: $protocol, ')
          ..write('host: $host, ')
          ..write('port: $port, ')
          ..write('basePath: $basePath, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('apiKeyAlias: $apiKeyAlias, ')
          ..write('lastConnectionStatus: $lastConnectionStatus, ')
          ..write('lastConnectedAt: $lastConnectedAt, ')
          ..write('lastCheckedAt: $lastCheckedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      ),
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String? value;
  const AppSetting({required this.key, this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String?>(value),
    };
  }

  AppSetting copyWith({
    String? key,
    Value<String?> value = const Value.absent(),
  }) => AppSetting(
    key: key ?? this.key,
    value: value.present ? value.value : this.value,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String?> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String?>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SelectedModelsTable extends SelectedModels
    with TableInfo<$SelectedModelsTable, SelectedModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SelectedModelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _serverProfileIdMeta = const VerificationMeta(
    'serverProfileId',
  );
  @override
  late final GeneratedColumn<String> serverProfileId = GeneratedColumn<String>(
    'server_profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES server_profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _modelIdMeta = const VerificationMeta(
    'modelId',
  );
  @override
  late final GeneratedColumn<String> modelId = GeneratedColumn<String>(
    'model_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [serverProfileId, modelId, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'selected_models';
  @override
  VerificationContext validateIntegrity(
    Insertable<SelectedModel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('server_profile_id')) {
      context.handle(
        _serverProfileIdMeta,
        serverProfileId.isAcceptableOrUnknown(
          data['server_profile_id']!,
          _serverProfileIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serverProfileIdMeta);
    }
    if (data.containsKey('model_id')) {
      context.handle(
        _modelIdMeta,
        modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_modelIdMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {serverProfileId};
  @override
  SelectedModel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SelectedModel(
      serverProfileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_profile_id'],
      )!,
      modelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SelectedModelsTable createAlias(String alias) {
    return $SelectedModelsTable(attachedDatabase, alias);
  }
}

class SelectedModel extends DataClass implements Insertable<SelectedModel> {
  final String serverProfileId;
  final String modelId;
  final DateTime updatedAt;
  const SelectedModel({
    required this.serverProfileId,
    required this.modelId,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['server_profile_id'] = Variable<String>(serverProfileId);
    map['model_id'] = Variable<String>(modelId);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SelectedModelsCompanion toCompanion(bool nullToAbsent) {
    return SelectedModelsCompanion(
      serverProfileId: Value(serverProfileId),
      modelId: Value(modelId),
      updatedAt: Value(updatedAt),
    );
  }

  factory SelectedModel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SelectedModel(
      serverProfileId: serializer.fromJson<String>(json['serverProfileId']),
      modelId: serializer.fromJson<String>(json['modelId']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'serverProfileId': serializer.toJson<String>(serverProfileId),
      'modelId': serializer.toJson<String>(modelId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SelectedModel copyWith({
    String? serverProfileId,
    String? modelId,
    DateTime? updatedAt,
  }) => SelectedModel(
    serverProfileId: serverProfileId ?? this.serverProfileId,
    modelId: modelId ?? this.modelId,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SelectedModel copyWithCompanion(SelectedModelsCompanion data) {
    return SelectedModel(
      serverProfileId: data.serverProfileId.present
          ? data.serverProfileId.value
          : this.serverProfileId,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SelectedModel(')
          ..write('serverProfileId: $serverProfileId, ')
          ..write('modelId: $modelId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(serverProfileId, modelId, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SelectedModel &&
          other.serverProfileId == this.serverProfileId &&
          other.modelId == this.modelId &&
          other.updatedAt == this.updatedAt);
}

class SelectedModelsCompanion extends UpdateCompanion<SelectedModel> {
  final Value<String> serverProfileId;
  final Value<String> modelId;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SelectedModelsCompanion({
    this.serverProfileId = const Value.absent(),
    this.modelId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SelectedModelsCompanion.insert({
    required String serverProfileId,
    required String modelId,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : serverProfileId = Value(serverProfileId),
       modelId = Value(modelId),
       updatedAt = Value(updatedAt);
  static Insertable<SelectedModel> custom({
    Expression<String>? serverProfileId,
    Expression<String>? modelId,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (serverProfileId != null) 'server_profile_id': serverProfileId,
      if (modelId != null) 'model_id': modelId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SelectedModelsCompanion copyWith({
    Value<String>? serverProfileId,
    Value<String>? modelId,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SelectedModelsCompanion(
      serverProfileId: serverProfileId ?? this.serverProfileId,
      modelId: modelId ?? this.modelId,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (serverProfileId.present) {
      map['server_profile_id'] = Variable<String>(serverProfileId.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<String>(modelId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SelectedModelsCompanion(')
          ..write('serverProfileId: $serverProfileId, ')
          ..write('modelId: $modelId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatCharactersTable extends ChatCharacters
    with TableInfo<$ChatCharactersTable, ChatCharacter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatCharactersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _instructionsMeta = const VerificationMeta(
    'instructions',
  );
  @override
  late final GeneratedColumn<String> instructions = GeneratedColumn<String>(
    'instructions',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarPathMeta = const VerificationMeta(
    'avatarPath',
  );
  @override
  late final GeneratedColumn<String> avatarPath = GeneratedColumn<String>(
    'avatar_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    instructions,
    avatarPath,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_characters';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatCharacter> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('instructions')) {
      context.handle(
        _instructionsMeta,
        instructions.isAcceptableOrUnknown(
          data['instructions']!,
          _instructionsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instructionsMeta);
    }
    if (data.containsKey('avatar_path')) {
      context.handle(
        _avatarPathMeta,
        avatarPath.isAcceptableOrUnknown(data['avatar_path']!, _avatarPathMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatCharacter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatCharacter(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      instructions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instructions'],
      )!,
      avatarPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ChatCharactersTable createAlias(String alias) {
    return $ChatCharactersTable(attachedDatabase, alias);
  }
}

class ChatCharacter extends DataClass implements Insertable<ChatCharacter> {
  final String id;
  final String name;
  final String instructions;
  final String? avatarPath;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ChatCharacter({
    required this.id,
    required this.name,
    required this.instructions,
    this.avatarPath,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['instructions'] = Variable<String>(instructions);
    if (!nullToAbsent || avatarPath != null) {
      map['avatar_path'] = Variable<String>(avatarPath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ChatCharactersCompanion toCompanion(bool nullToAbsent) {
    return ChatCharactersCompanion(
      id: Value(id),
      name: Value(name),
      instructions: Value(instructions),
      avatarPath: avatarPath == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarPath),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ChatCharacter.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatCharacter(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      instructions: serializer.fromJson<String>(json['instructions']),
      avatarPath: serializer.fromJson<String?>(json['avatarPath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'instructions': serializer.toJson<String>(instructions),
      'avatarPath': serializer.toJson<String?>(avatarPath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ChatCharacter copyWith({
    String? id,
    String? name,
    String? instructions,
    Value<String?> avatarPath = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ChatCharacter(
    id: id ?? this.id,
    name: name ?? this.name,
    instructions: instructions ?? this.instructions,
    avatarPath: avatarPath.present ? avatarPath.value : this.avatarPath,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ChatCharacter copyWithCompanion(ChatCharactersCompanion data) {
    return ChatCharacter(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      instructions: data.instructions.present
          ? data.instructions.value
          : this.instructions,
      avatarPath: data.avatarPath.present
          ? data.avatarPath.value
          : this.avatarPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatCharacter(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('instructions: $instructions, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, instructions, avatarPath, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatCharacter &&
          other.id == this.id &&
          other.name == this.name &&
          other.instructions == this.instructions &&
          other.avatarPath == this.avatarPath &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ChatCharactersCompanion extends UpdateCompanion<ChatCharacter> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> instructions;
  final Value<String?> avatarPath;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ChatCharactersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.instructions = const Value.absent(),
    this.avatarPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatCharactersCompanion.insert({
    required String id,
    required String name,
    required String instructions,
    this.avatarPath = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       instructions = Value(instructions),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ChatCharacter> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? instructions,
    Expression<String>? avatarPath,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (instructions != null) 'instructions': instructions,
      if (avatarPath != null) 'avatar_path': avatarPath,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatCharactersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? instructions,
    Value<String?>? avatarPath,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ChatCharactersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      instructions: instructions ?? this.instructions,
      avatarPath: avatarPath ?? this.avatarPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (instructions.present) {
      map['instructions'] = Variable<String>(instructions.value);
    }
    if (avatarPath.present) {
      map['avatar_path'] = Variable<String>(avatarPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatCharactersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('instructions: $instructions, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConversationsTable extends Conversations
    with TableInfo<$ConversationsTable, Conversation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConversationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverProfileIdMeta = const VerificationMeta(
    'serverProfileId',
  );
  @override
  late final GeneratedColumn<String> serverProfileId = GeneratedColumn<String>(
    'server_profile_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES server_profiles (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _serverNameSnapshotMeta =
      const VerificationMeta('serverNameSnapshot');
  @override
  late final GeneratedColumn<String> serverNameSnapshot =
      GeneratedColumn<String>(
        'server_name_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _providerSnapshotMeta = const VerificationMeta(
    'providerSnapshot',
  );
  @override
  late final GeneratedColumn<String> providerSnapshot = GeneratedColumn<String>(
    'provider_snapshot',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _characterIdMeta = const VerificationMeta(
    'characterId',
  );
  @override
  late final GeneratedColumn<String> characterId = GeneratedColumn<String>(
    'character_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES chat_characters (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _characterNameSnapshotMeta =
      const VerificationMeta('characterNameSnapshot');
  @override
  late final GeneratedColumn<String> characterNameSnapshot =
      GeneratedColumn<String>(
        'character_name_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _systemPromptMeta = const VerificationMeta(
    'systemPrompt',
  );
  @override
  late final GeneratedColumn<String> systemPrompt = GeneratedColumn<String>(
    'system_prompt',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    serverProfileId,
    serverNameSnapshot,
    providerSnapshot,
    characterId,
    characterNameSnapshot,
    model,
    systemPrompt,
    createdAt,
    updatedAt,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conversations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Conversation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('server_profile_id')) {
      context.handle(
        _serverProfileIdMeta,
        serverProfileId.isAcceptableOrUnknown(
          data['server_profile_id']!,
          _serverProfileIdMeta,
        ),
      );
    }
    if (data.containsKey('server_name_snapshot')) {
      context.handle(
        _serverNameSnapshotMeta,
        serverNameSnapshot.isAcceptableOrUnknown(
          data['server_name_snapshot']!,
          _serverNameSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('provider_snapshot')) {
      context.handle(
        _providerSnapshotMeta,
        providerSnapshot.isAcceptableOrUnknown(
          data['provider_snapshot']!,
          _providerSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('character_id')) {
      context.handle(
        _characterIdMeta,
        characterId.isAcceptableOrUnknown(
          data['character_id']!,
          _characterIdMeta,
        ),
      );
    }
    if (data.containsKey('character_name_snapshot')) {
      context.handle(
        _characterNameSnapshotMeta,
        characterNameSnapshot.isAcceptableOrUnknown(
          data['character_name_snapshot']!,
          _characterNameSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('system_prompt')) {
      context.handle(
        _systemPromptMeta,
        systemPrompt.isAcceptableOrUnknown(
          data['system_prompt']!,
          _systemPromptMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Conversation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Conversation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      serverProfileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_profile_id'],
      ),
      serverNameSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_name_snapshot'],
      ),
      providerSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_snapshot'],
      ),
      characterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}character_id'],
      ),
      characterNameSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}character_name_snapshot'],
      ),
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      )!,
      systemPrompt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}system_prompt'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
    );
  }

  @override
  $ConversationsTable createAlias(String alias) {
    return $ConversationsTable(attachedDatabase, alias);
  }
}

class Conversation extends DataClass implements Insertable<Conversation> {
  final String id;
  final String title;
  final String? serverProfileId;
  final String? serverNameSnapshot;
  final String? providerSnapshot;
  final String? characterId;
  final String? characterNameSnapshot;
  final String model;
  final String? systemPrompt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;
  const Conversation({
    required this.id,
    required this.title,
    this.serverProfileId,
    this.serverNameSnapshot,
    this.providerSnapshot,
    this.characterId,
    this.characterNameSnapshot,
    required this.model,
    this.systemPrompt,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || serverProfileId != null) {
      map['server_profile_id'] = Variable<String>(serverProfileId);
    }
    if (!nullToAbsent || serverNameSnapshot != null) {
      map['server_name_snapshot'] = Variable<String>(serverNameSnapshot);
    }
    if (!nullToAbsent || providerSnapshot != null) {
      map['provider_snapshot'] = Variable<String>(providerSnapshot);
    }
    if (!nullToAbsent || characterId != null) {
      map['character_id'] = Variable<String>(characterId);
    }
    if (!nullToAbsent || characterNameSnapshot != null) {
      map['character_name_snapshot'] = Variable<String>(characterNameSnapshot);
    }
    map['model'] = Variable<String>(model);
    if (!nullToAbsent || systemPrompt != null) {
      map['system_prompt'] = Variable<String>(systemPrompt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    return map;
  }

  ConversationsCompanion toCompanion(bool nullToAbsent) {
    return ConversationsCompanion(
      id: Value(id),
      title: Value(title),
      serverProfileId: serverProfileId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverProfileId),
      serverNameSnapshot: serverNameSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(serverNameSnapshot),
      providerSnapshot: providerSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(providerSnapshot),
      characterId: characterId == null && nullToAbsent
          ? const Value.absent()
          : Value(characterId),
      characterNameSnapshot: characterNameSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(characterNameSnapshot),
      model: Value(model),
      systemPrompt: systemPrompt == null && nullToAbsent
          ? const Value.absent()
          : Value(systemPrompt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory Conversation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Conversation(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      serverProfileId: serializer.fromJson<String?>(json['serverProfileId']),
      serverNameSnapshot: serializer.fromJson<String?>(
        json['serverNameSnapshot'],
      ),
      providerSnapshot: serializer.fromJson<String?>(json['providerSnapshot']),
      characterId: serializer.fromJson<String?>(json['characterId']),
      characterNameSnapshot: serializer.fromJson<String?>(
        json['characterNameSnapshot'],
      ),
      model: serializer.fromJson<String>(json['model']),
      systemPrompt: serializer.fromJson<String?>(json['systemPrompt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'serverProfileId': serializer.toJson<String?>(serverProfileId),
      'serverNameSnapshot': serializer.toJson<String?>(serverNameSnapshot),
      'providerSnapshot': serializer.toJson<String?>(providerSnapshot),
      'characterId': serializer.toJson<String?>(characterId),
      'characterNameSnapshot': serializer.toJson<String?>(
        characterNameSnapshot,
      ),
      'model': serializer.toJson<String>(model),
      'systemPrompt': serializer.toJson<String?>(systemPrompt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  Conversation copyWith({
    String? id,
    String? title,
    Value<String?> serverProfileId = const Value.absent(),
    Value<String?> serverNameSnapshot = const Value.absent(),
    Value<String?> providerSnapshot = const Value.absent(),
    Value<String?> characterId = const Value.absent(),
    Value<String?> characterNameSnapshot = const Value.absent(),
    String? model,
    Value<String?> systemPrompt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> archivedAt = const Value.absent(),
  }) => Conversation(
    id: id ?? this.id,
    title: title ?? this.title,
    serverProfileId: serverProfileId.present
        ? serverProfileId.value
        : this.serverProfileId,
    serverNameSnapshot: serverNameSnapshot.present
        ? serverNameSnapshot.value
        : this.serverNameSnapshot,
    providerSnapshot: providerSnapshot.present
        ? providerSnapshot.value
        : this.providerSnapshot,
    characterId: characterId.present ? characterId.value : this.characterId,
    characterNameSnapshot: characterNameSnapshot.present
        ? characterNameSnapshot.value
        : this.characterNameSnapshot,
    model: model ?? this.model,
    systemPrompt: systemPrompt.present ? systemPrompt.value : this.systemPrompt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  Conversation copyWithCompanion(ConversationsCompanion data) {
    return Conversation(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      serverProfileId: data.serverProfileId.present
          ? data.serverProfileId.value
          : this.serverProfileId,
      serverNameSnapshot: data.serverNameSnapshot.present
          ? data.serverNameSnapshot.value
          : this.serverNameSnapshot,
      providerSnapshot: data.providerSnapshot.present
          ? data.providerSnapshot.value
          : this.providerSnapshot,
      characterId: data.characterId.present
          ? data.characterId.value
          : this.characterId,
      characterNameSnapshot: data.characterNameSnapshot.present
          ? data.characterNameSnapshot.value
          : this.characterNameSnapshot,
      model: data.model.present ? data.model.value : this.model,
      systemPrompt: data.systemPrompt.present
          ? data.systemPrompt.value
          : this.systemPrompt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Conversation(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('serverProfileId: $serverProfileId, ')
          ..write('serverNameSnapshot: $serverNameSnapshot, ')
          ..write('providerSnapshot: $providerSnapshot, ')
          ..write('characterId: $characterId, ')
          ..write('characterNameSnapshot: $characterNameSnapshot, ')
          ..write('model: $model, ')
          ..write('systemPrompt: $systemPrompt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    serverProfileId,
    serverNameSnapshot,
    providerSnapshot,
    characterId,
    characterNameSnapshot,
    model,
    systemPrompt,
    createdAt,
    updatedAt,
    archivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Conversation &&
          other.id == this.id &&
          other.title == this.title &&
          other.serverProfileId == this.serverProfileId &&
          other.serverNameSnapshot == this.serverNameSnapshot &&
          other.providerSnapshot == this.providerSnapshot &&
          other.characterId == this.characterId &&
          other.characterNameSnapshot == this.characterNameSnapshot &&
          other.model == this.model &&
          other.systemPrompt == this.systemPrompt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.archivedAt == this.archivedAt);
}

class ConversationsCompanion extends UpdateCompanion<Conversation> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> serverProfileId;
  final Value<String?> serverNameSnapshot;
  final Value<String?> providerSnapshot;
  final Value<String?> characterId;
  final Value<String?> characterNameSnapshot;
  final Value<String> model;
  final Value<String?> systemPrompt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> archivedAt;
  final Value<int> rowid;
  const ConversationsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.serverProfileId = const Value.absent(),
    this.serverNameSnapshot = const Value.absent(),
    this.providerSnapshot = const Value.absent(),
    this.characterId = const Value.absent(),
    this.characterNameSnapshot = const Value.absent(),
    this.model = const Value.absent(),
    this.systemPrompt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConversationsCompanion.insert({
    required String id,
    required String title,
    this.serverProfileId = const Value.absent(),
    this.serverNameSnapshot = const Value.absent(),
    this.providerSnapshot = const Value.absent(),
    this.characterId = const Value.absent(),
    this.characterNameSnapshot = const Value.absent(),
    required String model,
    this.systemPrompt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       model = Value(model),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Conversation> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? serverProfileId,
    Expression<String>? serverNameSnapshot,
    Expression<String>? providerSnapshot,
    Expression<String>? characterId,
    Expression<String>? characterNameSnapshot,
    Expression<String>? model,
    Expression<String>? systemPrompt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (serverProfileId != null) 'server_profile_id': serverProfileId,
      if (serverNameSnapshot != null)
        'server_name_snapshot': serverNameSnapshot,
      if (providerSnapshot != null) 'provider_snapshot': providerSnapshot,
      if (characterId != null) 'character_id': characterId,
      if (characterNameSnapshot != null)
        'character_name_snapshot': characterNameSnapshot,
      if (model != null) 'model': model,
      if (systemPrompt != null) 'system_prompt': systemPrompt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConversationsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? serverProfileId,
    Value<String?>? serverNameSnapshot,
    Value<String?>? providerSnapshot,
    Value<String?>? characterId,
    Value<String?>? characterNameSnapshot,
    Value<String>? model,
    Value<String?>? systemPrompt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? archivedAt,
    Value<int>? rowid,
  }) {
    return ConversationsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      serverProfileId: serverProfileId ?? this.serverProfileId,
      serverNameSnapshot: serverNameSnapshot ?? this.serverNameSnapshot,
      providerSnapshot: providerSnapshot ?? this.providerSnapshot,
      characterId: characterId ?? this.characterId,
      characterNameSnapshot:
          characterNameSnapshot ?? this.characterNameSnapshot,
      model: model ?? this.model,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (serverProfileId.present) {
      map['server_profile_id'] = Variable<String>(serverProfileId.value);
    }
    if (serverNameSnapshot.present) {
      map['server_name_snapshot'] = Variable<String>(serverNameSnapshot.value);
    }
    if (providerSnapshot.present) {
      map['provider_snapshot'] = Variable<String>(providerSnapshot.value);
    }
    if (characterId.present) {
      map['character_id'] = Variable<String>(characterId.value);
    }
    if (characterNameSnapshot.present) {
      map['character_name_snapshot'] = Variable<String>(
        characterNameSnapshot.value,
      );
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (systemPrompt.present) {
      map['system_prompt'] = Variable<String>(systemPrompt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConversationsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('serverProfileId: $serverProfileId, ')
          ..write('serverNameSnapshot: $serverNameSnapshot, ')
          ..write('providerSnapshot: $providerSnapshot, ')
          ..write('characterId: $characterId, ')
          ..write('characterNameSnapshot: $characterNameSnapshot, ')
          ..write('model: $model, ')
          ..write('systemPrompt: $systemPrompt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatMessagesTable extends ChatMessages
    with TableInfo<$ChatMessagesTable, ChatMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
    'conversation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES conversations (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thinkingMeta = const VerificationMeta(
    'thinking',
  );
  @override
  late final GeneratedColumn<String> thinking = GeneratedColumn<String>(
    'thinking',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toolCallsJsonMeta = const VerificationMeta(
    'toolCallsJson',
  );
  @override
  late final GeneratedColumn<String> toolCallsJson = GeneratedColumn<String>(
    'tool_calls_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toolCallIdMeta = const VerificationMeta(
    'toolCallId',
  );
  @override
  late final GeneratedColumn<String> toolCallId = GeneratedColumn<String>(
    'tool_call_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _characterIdSnapshotMeta =
      const VerificationMeta('characterIdSnapshot');
  @override
  late final GeneratedColumn<String> characterIdSnapshot =
      GeneratedColumn<String>(
        'character_id_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _characterNameSnapshotMeta =
      const VerificationMeta('characterNameSnapshot');
  @override
  late final GeneratedColumn<String> characterNameSnapshot =
      GeneratedColumn<String>(
        'character_name_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _characterAvatarPathSnapshotMeta =
      const VerificationMeta('characterAvatarPathSnapshot');
  @override
  late final GeneratedColumn<String> characterAvatarPathSnapshot =
      GeneratedColumn<String>(
        'character_avatar_path_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    conversationId,
    role,
    content,
    thinking,
    model,
    status,
    toolCallsJson,
    toolCallId,
    characterIdSnapshot,
    characterNameSnapshot,
    characterAvatarPathSnapshot,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('thinking')) {
      context.handle(
        _thinkingMeta,
        thinking.isAcceptableOrUnknown(data['thinking']!, _thinkingMeta),
      );
    } else if (isInserting) {
      context.missing(_thinkingMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('tool_calls_json')) {
      context.handle(
        _toolCallsJsonMeta,
        toolCallsJson.isAcceptableOrUnknown(
          data['tool_calls_json']!,
          _toolCallsJsonMeta,
        ),
      );
    }
    if (data.containsKey('tool_call_id')) {
      context.handle(
        _toolCallIdMeta,
        toolCallId.isAcceptableOrUnknown(
          data['tool_call_id']!,
          _toolCallIdMeta,
        ),
      );
    }
    if (data.containsKey('character_id_snapshot')) {
      context.handle(
        _characterIdSnapshotMeta,
        characterIdSnapshot.isAcceptableOrUnknown(
          data['character_id_snapshot']!,
          _characterIdSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('character_name_snapshot')) {
      context.handle(
        _characterNameSnapshotMeta,
        characterNameSnapshot.isAcceptableOrUnknown(
          data['character_name_snapshot']!,
          _characterNameSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('character_avatar_path_snapshot')) {
      context.handle(
        _characterAvatarPathSnapshotMeta,
        characterAvatarPathSnapshot.isAcceptableOrUnknown(
          data['character_avatar_path_snapshot']!,
          _characterAvatarPathSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conversation_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      thinking: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thinking'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      toolCallsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tool_calls_json'],
      ),
      toolCallId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tool_call_id'],
      ),
      characterIdSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}character_id_snapshot'],
      ),
      characterNameSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}character_name_snapshot'],
      ),
      characterAvatarPathSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}character_avatar_path_snapshot'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ChatMessagesTable createAlias(String alias) {
    return $ChatMessagesTable(attachedDatabase, alias);
  }
}

class ChatMessage extends DataClass implements Insertable<ChatMessage> {
  final String id;
  final String conversationId;
  final String role;
  final String content;
  final String thinking;
  final String? model;
  final String status;
  final String? toolCallsJson;
  final String? toolCallId;
  final String? characterIdSnapshot;
  final String? characterNameSnapshot;
  final String? characterAvatarPathSnapshot;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.thinking,
    this.model,
    required this.status,
    this.toolCallsJson,
    this.toolCallId,
    this.characterIdSnapshot,
    this.characterNameSnapshot,
    this.characterAvatarPathSnapshot,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['conversation_id'] = Variable<String>(conversationId);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    map['thinking'] = Variable<String>(thinking);
    if (!nullToAbsent || model != null) {
      map['model'] = Variable<String>(model);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || toolCallsJson != null) {
      map['tool_calls_json'] = Variable<String>(toolCallsJson);
    }
    if (!nullToAbsent || toolCallId != null) {
      map['tool_call_id'] = Variable<String>(toolCallId);
    }
    if (!nullToAbsent || characterIdSnapshot != null) {
      map['character_id_snapshot'] = Variable<String>(characterIdSnapshot);
    }
    if (!nullToAbsent || characterNameSnapshot != null) {
      map['character_name_snapshot'] = Variable<String>(characterNameSnapshot);
    }
    if (!nullToAbsent || characterAvatarPathSnapshot != null) {
      map['character_avatar_path_snapshot'] = Variable<String>(
        characterAvatarPathSnapshot,
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      role: Value(role),
      content: Value(content),
      thinking: Value(thinking),
      model: model == null && nullToAbsent
          ? const Value.absent()
          : Value(model),
      status: Value(status),
      toolCallsJson: toolCallsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(toolCallsJson),
      toolCallId: toolCallId == null && nullToAbsent
          ? const Value.absent()
          : Value(toolCallId),
      characterIdSnapshot: characterIdSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(characterIdSnapshot),
      characterNameSnapshot: characterNameSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(characterNameSnapshot),
      characterAvatarPathSnapshot:
          characterAvatarPathSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(characterAvatarPathSnapshot),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ChatMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessage(
      id: serializer.fromJson<String>(json['id']),
      conversationId: serializer.fromJson<String>(json['conversationId']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      thinking: serializer.fromJson<String>(json['thinking']),
      model: serializer.fromJson<String?>(json['model']),
      status: serializer.fromJson<String>(json['status']),
      toolCallsJson: serializer.fromJson<String?>(json['toolCallsJson']),
      toolCallId: serializer.fromJson<String?>(json['toolCallId']),
      characterIdSnapshot: serializer.fromJson<String?>(
        json['characterIdSnapshot'],
      ),
      characterNameSnapshot: serializer.fromJson<String?>(
        json['characterNameSnapshot'],
      ),
      characterAvatarPathSnapshot: serializer.fromJson<String?>(
        json['characterAvatarPathSnapshot'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'conversationId': serializer.toJson<String>(conversationId),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'thinking': serializer.toJson<String>(thinking),
      'model': serializer.toJson<String?>(model),
      'status': serializer.toJson<String>(status),
      'toolCallsJson': serializer.toJson<String?>(toolCallsJson),
      'toolCallId': serializer.toJson<String?>(toolCallId),
      'characterIdSnapshot': serializer.toJson<String?>(characterIdSnapshot),
      'characterNameSnapshot': serializer.toJson<String?>(
        characterNameSnapshot,
      ),
      'characterAvatarPathSnapshot': serializer.toJson<String?>(
        characterAvatarPathSnapshot,
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ChatMessage copyWith({
    String? id,
    String? conversationId,
    String? role,
    String? content,
    String? thinking,
    Value<String?> model = const Value.absent(),
    String? status,
    Value<String?> toolCallsJson = const Value.absent(),
    Value<String?> toolCallId = const Value.absent(),
    Value<String?> characterIdSnapshot = const Value.absent(),
    Value<String?> characterNameSnapshot = const Value.absent(),
    Value<String?> characterAvatarPathSnapshot = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ChatMessage(
    id: id ?? this.id,
    conversationId: conversationId ?? this.conversationId,
    role: role ?? this.role,
    content: content ?? this.content,
    thinking: thinking ?? this.thinking,
    model: model.present ? model.value : this.model,
    status: status ?? this.status,
    toolCallsJson: toolCallsJson.present
        ? toolCallsJson.value
        : this.toolCallsJson,
    toolCallId: toolCallId.present ? toolCallId.value : this.toolCallId,
    characterIdSnapshot: characterIdSnapshot.present
        ? characterIdSnapshot.value
        : this.characterIdSnapshot,
    characterNameSnapshot: characterNameSnapshot.present
        ? characterNameSnapshot.value
        : this.characterNameSnapshot,
    characterAvatarPathSnapshot: characterAvatarPathSnapshot.present
        ? characterAvatarPathSnapshot.value
        : this.characterAvatarPathSnapshot,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ChatMessage copyWithCompanion(ChatMessagesCompanion data) {
    return ChatMessage(
      id: data.id.present ? data.id.value : this.id,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      thinking: data.thinking.present ? data.thinking.value : this.thinking,
      model: data.model.present ? data.model.value : this.model,
      status: data.status.present ? data.status.value : this.status,
      toolCallsJson: data.toolCallsJson.present
          ? data.toolCallsJson.value
          : this.toolCallsJson,
      toolCallId: data.toolCallId.present
          ? data.toolCallId.value
          : this.toolCallId,
      characterIdSnapshot: data.characterIdSnapshot.present
          ? data.characterIdSnapshot.value
          : this.characterIdSnapshot,
      characterNameSnapshot: data.characterNameSnapshot.present
          ? data.characterNameSnapshot.value
          : this.characterNameSnapshot,
      characterAvatarPathSnapshot: data.characterAvatarPathSnapshot.present
          ? data.characterAvatarPathSnapshot.value
          : this.characterAvatarPathSnapshot,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessage(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('thinking: $thinking, ')
          ..write('model: $model, ')
          ..write('status: $status, ')
          ..write('toolCallsJson: $toolCallsJson, ')
          ..write('toolCallId: $toolCallId, ')
          ..write('characterIdSnapshot: $characterIdSnapshot, ')
          ..write('characterNameSnapshot: $characterNameSnapshot, ')
          ..write('characterAvatarPathSnapshot: $characterAvatarPathSnapshot, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    conversationId,
    role,
    content,
    thinking,
    model,
    status,
    toolCallsJson,
    toolCallId,
    characterIdSnapshot,
    characterNameSnapshot,
    characterAvatarPathSnapshot,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessage &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.role == this.role &&
          other.content == this.content &&
          other.thinking == this.thinking &&
          other.model == this.model &&
          other.status == this.status &&
          other.toolCallsJson == this.toolCallsJson &&
          other.toolCallId == this.toolCallId &&
          other.characterIdSnapshot == this.characterIdSnapshot &&
          other.characterNameSnapshot == this.characterNameSnapshot &&
          other.characterAvatarPathSnapshot ==
              this.characterAvatarPathSnapshot &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ChatMessagesCompanion extends UpdateCompanion<ChatMessage> {
  final Value<String> id;
  final Value<String> conversationId;
  final Value<String> role;
  final Value<String> content;
  final Value<String> thinking;
  final Value<String?> model;
  final Value<String> status;
  final Value<String?> toolCallsJson;
  final Value<String?> toolCallId;
  final Value<String?> characterIdSnapshot;
  final Value<String?> characterNameSnapshot;
  final Value<String?> characterAvatarPathSnapshot;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ChatMessagesCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.thinking = const Value.absent(),
    this.model = const Value.absent(),
    this.status = const Value.absent(),
    this.toolCallsJson = const Value.absent(),
    this.toolCallId = const Value.absent(),
    this.characterIdSnapshot = const Value.absent(),
    this.characterNameSnapshot = const Value.absent(),
    this.characterAvatarPathSnapshot = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatMessagesCompanion.insert({
    required String id,
    required String conversationId,
    required String role,
    required String content,
    required String thinking,
    this.model = const Value.absent(),
    required String status,
    this.toolCallsJson = const Value.absent(),
    this.toolCallId = const Value.absent(),
    this.characterIdSnapshot = const Value.absent(),
    this.characterNameSnapshot = const Value.absent(),
    this.characterAvatarPathSnapshot = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       conversationId = Value(conversationId),
       role = Value(role),
       content = Value(content),
       thinking = Value(thinking),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ChatMessage> custom({
    Expression<String>? id,
    Expression<String>? conversationId,
    Expression<String>? role,
    Expression<String>? content,
    Expression<String>? thinking,
    Expression<String>? model,
    Expression<String>? status,
    Expression<String>? toolCallsJson,
    Expression<String>? toolCallId,
    Expression<String>? characterIdSnapshot,
    Expression<String>? characterNameSnapshot,
    Expression<String>? characterAvatarPathSnapshot,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (thinking != null) 'thinking': thinking,
      if (model != null) 'model': model,
      if (status != null) 'status': status,
      if (toolCallsJson != null) 'tool_calls_json': toolCallsJson,
      if (toolCallId != null) 'tool_call_id': toolCallId,
      if (characterIdSnapshot != null)
        'character_id_snapshot': characterIdSnapshot,
      if (characterNameSnapshot != null)
        'character_name_snapshot': characterNameSnapshot,
      if (characterAvatarPathSnapshot != null)
        'character_avatar_path_snapshot': characterAvatarPathSnapshot,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatMessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? conversationId,
    Value<String>? role,
    Value<String>? content,
    Value<String>? thinking,
    Value<String?>? model,
    Value<String>? status,
    Value<String?>? toolCallsJson,
    Value<String?>? toolCallId,
    Value<String?>? characterIdSnapshot,
    Value<String?>? characterNameSnapshot,
    Value<String?>? characterAvatarPathSnapshot,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ChatMessagesCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      thinking: thinking ?? this.thinking,
      model: model ?? this.model,
      status: status ?? this.status,
      toolCallsJson: toolCallsJson ?? this.toolCallsJson,
      toolCallId: toolCallId ?? this.toolCallId,
      characterIdSnapshot: characterIdSnapshot ?? this.characterIdSnapshot,
      characterNameSnapshot:
          characterNameSnapshot ?? this.characterNameSnapshot,
      characterAvatarPathSnapshot:
          characterAvatarPathSnapshot ?? this.characterAvatarPathSnapshot,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (thinking.present) {
      map['thinking'] = Variable<String>(thinking.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (toolCallsJson.present) {
      map['tool_calls_json'] = Variable<String>(toolCallsJson.value);
    }
    if (toolCallId.present) {
      map['tool_call_id'] = Variable<String>(toolCallId.value);
    }
    if (characterIdSnapshot.present) {
      map['character_id_snapshot'] = Variable<String>(
        characterIdSnapshot.value,
      );
    }
    if (characterNameSnapshot.present) {
      map['character_name_snapshot'] = Variable<String>(
        characterNameSnapshot.value,
      );
    }
    if (characterAvatarPathSnapshot.present) {
      map['character_avatar_path_snapshot'] = Variable<String>(
        characterAvatarPathSnapshot.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesCompanion(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('thinking: $thinking, ')
          ..write('model: $model, ')
          ..write('status: $status, ')
          ..write('toolCallsJson: $toolCallsJson, ')
          ..write('toolCallId: $toolCallId, ')
          ..write('characterIdSnapshot: $characterIdSnapshot, ')
          ..write('characterNameSnapshot: $characterNameSnapshot, ')
          ..write('characterAvatarPathSnapshot: $characterAvatarPathSnapshot, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ServerProfilesTable serverProfiles = $ServerProfilesTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $SelectedModelsTable selectedModels = $SelectedModelsTable(this);
  late final $ChatCharactersTable chatCharacters = $ChatCharactersTable(this);
  late final $ConversationsTable conversations = $ConversationsTable(this);
  late final $ChatMessagesTable chatMessages = $ChatMessagesTable(this);
  late final Index conversationsUpdatedAt = Index(
    'conversations_updated_at',
    'CREATE INDEX conversations_updated_at ON conversations (updated_at)',
  );
  late final Index chatMessagesConversationCreatedAt = Index(
    'chat_messages_conversation_created_at',
    'CREATE INDEX chat_messages_conversation_created_at ON chat_messages (conversation_id, created_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    serverProfiles,
    appSettings,
    selectedModels,
    chatCharacters,
    conversations,
    chatMessages,
    conversationsUpdatedAt,
    chatMessagesConversationCreatedAt,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'server_profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('selected_models', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'server_profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('conversations', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'chat_characters',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('conversations', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'conversations',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('chat_messages', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ServerProfilesTableCreateCompanionBuilder =
    ServerProfilesCompanion Function({
      required String id,
      required String name,
      required String provider,
      required String protocol,
      required String host,
      required int port,
      Value<String?> basePath,
      Value<String?> avatarPath,
      Value<String?> apiKeyAlias,
      Value<String> lastConnectionStatus,
      Value<DateTime?> lastConnectedAt,
      Value<DateTime?> lastCheckedAt,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ServerProfilesTableUpdateCompanionBuilder =
    ServerProfilesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> provider,
      Value<String> protocol,
      Value<String> host,
      Value<int> port,
      Value<String?> basePath,
      Value<String?> avatarPath,
      Value<String?> apiKeyAlias,
      Value<String> lastConnectionStatus,
      Value<DateTime?> lastConnectedAt,
      Value<DateTime?> lastCheckedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ServerProfilesTableReferences
    extends BaseReferences<_$AppDatabase, $ServerProfilesTable, ServerProfile> {
  $$ServerProfilesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$SelectedModelsTable, List<SelectedModel>>
  _selectedModelsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.selectedModels,
    aliasName: 'server_profiles__id__selected_models__server_profile_id',
  );

  $$SelectedModelsTableProcessedTableManager get selectedModelsRefs {
    final manager = $$SelectedModelsTableTableManager($_db, $_db.selectedModels)
        .filter(
          (f) => f.serverProfileId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(_selectedModelsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ConversationsTable, List<Conversation>>
  _conversationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.conversations,
    aliasName: 'server_profiles__id__conversations__server_profile_id',
  );

  $$ConversationsTableProcessedTableManager get conversationsRefs {
    final manager = $$ConversationsTableTableManager($_db, $_db.conversations)
        .filter(
          (f) => f.serverProfileId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(_conversationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ServerProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ServerProfilesTable> {
  $$ServerProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get protocol => $composableBuilder(
    column: $table.protocol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get host => $composableBuilder(
    column: $table.host,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get port => $composableBuilder(
    column: $table.port,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get basePath => $composableBuilder(
    column: $table.basePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get apiKeyAlias => $composableBuilder(
    column: $table.apiKeyAlias,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastConnectionStatus => $composableBuilder(
    column: $table.lastConnectionStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastConnectedAt => $composableBuilder(
    column: $table.lastConnectedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastCheckedAt => $composableBuilder(
    column: $table.lastCheckedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> selectedModelsRefs(
    Expression<bool> Function($$SelectedModelsTableFilterComposer f) f,
  ) {
    final $$SelectedModelsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.selectedModels,
      getReferencedColumn: (t) => t.serverProfileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SelectedModelsTableFilterComposer(
            $db: $db,
            $table: $db.selectedModels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> conversationsRefs(
    Expression<bool> Function($$ConversationsTableFilterComposer f) f,
  ) {
    final $$ConversationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.conversations,
      getReferencedColumn: (t) => t.serverProfileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationsTableFilterComposer(
            $db: $db,
            $table: $db.conversations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ServerProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ServerProfilesTable> {
  $$ServerProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get protocol => $composableBuilder(
    column: $table.protocol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get host => $composableBuilder(
    column: $table.host,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get port => $composableBuilder(
    column: $table.port,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get basePath => $composableBuilder(
    column: $table.basePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get apiKeyAlias => $composableBuilder(
    column: $table.apiKeyAlias,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastConnectionStatus => $composableBuilder(
    column: $table.lastConnectionStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastConnectedAt => $composableBuilder(
    column: $table.lastConnectedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastCheckedAt => $composableBuilder(
    column: $table.lastCheckedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ServerProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ServerProfilesTable> {
  $$ServerProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get protocol =>
      $composableBuilder(column: $table.protocol, builder: (column) => column);

  GeneratedColumn<String> get host =>
      $composableBuilder(column: $table.host, builder: (column) => column);

  GeneratedColumn<int> get port =>
      $composableBuilder(column: $table.port, builder: (column) => column);

  GeneratedColumn<String> get basePath =>
      $composableBuilder(column: $table.basePath, builder: (column) => column);

  GeneratedColumn<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get apiKeyAlias => $composableBuilder(
    column: $table.apiKeyAlias,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastConnectionStatus => $composableBuilder(
    column: $table.lastConnectionStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastConnectedAt => $composableBuilder(
    column: $table.lastConnectedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastCheckedAt => $composableBuilder(
    column: $table.lastCheckedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> selectedModelsRefs<T extends Object>(
    Expression<T> Function($$SelectedModelsTableAnnotationComposer a) f,
  ) {
    final $$SelectedModelsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.selectedModels,
      getReferencedColumn: (t) => t.serverProfileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SelectedModelsTableAnnotationComposer(
            $db: $db,
            $table: $db.selectedModels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> conversationsRefs<T extends Object>(
    Expression<T> Function($$ConversationsTableAnnotationComposer a) f,
  ) {
    final $$ConversationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.conversations,
      getReferencedColumn: (t) => t.serverProfileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationsTableAnnotationComposer(
            $db: $db,
            $table: $db.conversations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ServerProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ServerProfilesTable,
          ServerProfile,
          $$ServerProfilesTableFilterComposer,
          $$ServerProfilesTableOrderingComposer,
          $$ServerProfilesTableAnnotationComposer,
          $$ServerProfilesTableCreateCompanionBuilder,
          $$ServerProfilesTableUpdateCompanionBuilder,
          (ServerProfile, $$ServerProfilesTableReferences),
          ServerProfile,
          PrefetchHooks Function({
            bool selectedModelsRefs,
            bool conversationsRefs,
          })
        > {
  $$ServerProfilesTableTableManager(
    _$AppDatabase db,
    $ServerProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServerProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServerProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ServerProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> provider = const Value.absent(),
                Value<String> protocol = const Value.absent(),
                Value<String> host = const Value.absent(),
                Value<int> port = const Value.absent(),
                Value<String?> basePath = const Value.absent(),
                Value<String?> avatarPath = const Value.absent(),
                Value<String?> apiKeyAlias = const Value.absent(),
                Value<String> lastConnectionStatus = const Value.absent(),
                Value<DateTime?> lastConnectedAt = const Value.absent(),
                Value<DateTime?> lastCheckedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ServerProfilesCompanion(
                id: id,
                name: name,
                provider: provider,
                protocol: protocol,
                host: host,
                port: port,
                basePath: basePath,
                avatarPath: avatarPath,
                apiKeyAlias: apiKeyAlias,
                lastConnectionStatus: lastConnectionStatus,
                lastConnectedAt: lastConnectedAt,
                lastCheckedAt: lastCheckedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String provider,
                required String protocol,
                required String host,
                required int port,
                Value<String?> basePath = const Value.absent(),
                Value<String?> avatarPath = const Value.absent(),
                Value<String?> apiKeyAlias = const Value.absent(),
                Value<String> lastConnectionStatus = const Value.absent(),
                Value<DateTime?> lastConnectedAt = const Value.absent(),
                Value<DateTime?> lastCheckedAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ServerProfilesCompanion.insert(
                id: id,
                name: name,
                provider: provider,
                protocol: protocol,
                host: host,
                port: port,
                basePath: basePath,
                avatarPath: avatarPath,
                apiKeyAlias: apiKeyAlias,
                lastConnectionStatus: lastConnectionStatus,
                lastConnectedAt: lastConnectedAt,
                lastCheckedAt: lastCheckedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ServerProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({selectedModelsRefs = false, conversationsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (selectedModelsRefs) db.selectedModels,
                    if (conversationsRefs) db.conversations,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (selectedModelsRefs)
                        await $_getPrefetchedData<
                          ServerProfile,
                          $ServerProfilesTable,
                          SelectedModel
                        >(
                          currentTable: table,
                          referencedTable: $$ServerProfilesTableReferences
                              ._selectedModelsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ServerProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).selectedModelsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.serverProfileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (conversationsRefs)
                        await $_getPrefetchedData<
                          ServerProfile,
                          $ServerProfilesTable,
                          Conversation
                        >(
                          currentTable: table,
                          referencedTable: $$ServerProfilesTableReferences
                              ._conversationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ServerProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).conversationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.serverProfileId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ServerProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ServerProfilesTable,
      ServerProfile,
      $$ServerProfilesTableFilterComposer,
      $$ServerProfilesTableOrderingComposer,
      $$ServerProfilesTableAnnotationComposer,
      $$ServerProfilesTableCreateCompanionBuilder,
      $$ServerProfilesTableUpdateCompanionBuilder,
      (ServerProfile, $$ServerProfilesTableReferences),
      ServerProfile,
      PrefetchHooks Function({bool selectedModelsRefs, bool conversationsRefs})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      Value<String?> value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String?> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$SelectedModelsTableCreateCompanionBuilder =
    SelectedModelsCompanion Function({
      required String serverProfileId,
      required String modelId,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SelectedModelsTableUpdateCompanionBuilder =
    SelectedModelsCompanion Function({
      Value<String> serverProfileId,
      Value<String> modelId,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$SelectedModelsTableReferences
    extends BaseReferences<_$AppDatabase, $SelectedModelsTable, SelectedModel> {
  $$SelectedModelsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ServerProfilesTable _serverProfileIdTable(_$AppDatabase db) => db
      .serverProfiles
      .createAlias('selected_models__server_profile_id__server_profiles__id');

  $$ServerProfilesTableProcessedTableManager get serverProfileId {
    final $_column = $_itemColumn<String>('server_profile_id')!;

    final manager = $$ServerProfilesTableTableManager(
      $_db,
      $_db.serverProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_serverProfileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SelectedModelsTableFilterComposer
    extends Composer<_$AppDatabase, $SelectedModelsTable> {
  $$SelectedModelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ServerProfilesTableFilterComposer get serverProfileId {
    final $$ServerProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.serverProfileId,
      referencedTable: $db.serverProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServerProfilesTableFilterComposer(
            $db: $db,
            $table: $db.serverProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SelectedModelsTableOrderingComposer
    extends Composer<_$AppDatabase, $SelectedModelsTable> {
  $$SelectedModelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ServerProfilesTableOrderingComposer get serverProfileId {
    final $$ServerProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.serverProfileId,
      referencedTable: $db.serverProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServerProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.serverProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SelectedModelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SelectedModelsTable> {
  $$SelectedModelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get modelId =>
      $composableBuilder(column: $table.modelId, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ServerProfilesTableAnnotationComposer get serverProfileId {
    final $$ServerProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.serverProfileId,
      referencedTable: $db.serverProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServerProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.serverProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SelectedModelsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SelectedModelsTable,
          SelectedModel,
          $$SelectedModelsTableFilterComposer,
          $$SelectedModelsTableOrderingComposer,
          $$SelectedModelsTableAnnotationComposer,
          $$SelectedModelsTableCreateCompanionBuilder,
          $$SelectedModelsTableUpdateCompanionBuilder,
          (SelectedModel, $$SelectedModelsTableReferences),
          SelectedModel,
          PrefetchHooks Function({bool serverProfileId})
        > {
  $$SelectedModelsTableTableManager(
    _$AppDatabase db,
    $SelectedModelsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SelectedModelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SelectedModelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SelectedModelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> serverProfileId = const Value.absent(),
                Value<String> modelId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SelectedModelsCompanion(
                serverProfileId: serverProfileId,
                modelId: modelId,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String serverProfileId,
                required String modelId,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SelectedModelsCompanion.insert(
                serverProfileId: serverProfileId,
                modelId: modelId,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SelectedModelsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({serverProfileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (serverProfileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.serverProfileId,
                                referencedTable: $$SelectedModelsTableReferences
                                    ._serverProfileIdTable(db),
                                referencedColumn:
                                    $$SelectedModelsTableReferences
                                        ._serverProfileIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SelectedModelsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SelectedModelsTable,
      SelectedModel,
      $$SelectedModelsTableFilterComposer,
      $$SelectedModelsTableOrderingComposer,
      $$SelectedModelsTableAnnotationComposer,
      $$SelectedModelsTableCreateCompanionBuilder,
      $$SelectedModelsTableUpdateCompanionBuilder,
      (SelectedModel, $$SelectedModelsTableReferences),
      SelectedModel,
      PrefetchHooks Function({bool serverProfileId})
    >;
typedef $$ChatCharactersTableCreateCompanionBuilder =
    ChatCharactersCompanion Function({
      required String id,
      required String name,
      required String instructions,
      Value<String?> avatarPath,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ChatCharactersTableUpdateCompanionBuilder =
    ChatCharactersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> instructions,
      Value<String?> avatarPath,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ChatCharactersTableReferences
    extends BaseReferences<_$AppDatabase, $ChatCharactersTable, ChatCharacter> {
  $$ChatCharactersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$ConversationsTable, List<Conversation>>
  _conversationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.conversations,
    aliasName: 'chat_characters__id__conversations__character_id',
  );

  $$ConversationsTableProcessedTableManager get conversationsRefs {
    final manager = $$ConversationsTableTableManager(
      $_db,
      $_db.conversations,
    ).filter((f) => f.characterId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_conversationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ChatCharactersTableFilterComposer
    extends Composer<_$AppDatabase, $ChatCharactersTable> {
  $$ChatCharactersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instructions => $composableBuilder(
    column: $table.instructions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> conversationsRefs(
    Expression<bool> Function($$ConversationsTableFilterComposer f) f,
  ) {
    final $$ConversationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.conversations,
      getReferencedColumn: (t) => t.characterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationsTableFilterComposer(
            $db: $db,
            $table: $db.conversations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChatCharactersTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatCharactersTable> {
  $$ChatCharactersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instructions => $composableBuilder(
    column: $table.instructions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChatCharactersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatCharactersTable> {
  $$ChatCharactersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get instructions => $composableBuilder(
    column: $table.instructions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> conversationsRefs<T extends Object>(
    Expression<T> Function($$ConversationsTableAnnotationComposer a) f,
  ) {
    final $$ConversationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.conversations,
      getReferencedColumn: (t) => t.characterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationsTableAnnotationComposer(
            $db: $db,
            $table: $db.conversations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChatCharactersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatCharactersTable,
          ChatCharacter,
          $$ChatCharactersTableFilterComposer,
          $$ChatCharactersTableOrderingComposer,
          $$ChatCharactersTableAnnotationComposer,
          $$ChatCharactersTableCreateCompanionBuilder,
          $$ChatCharactersTableUpdateCompanionBuilder,
          (ChatCharacter, $$ChatCharactersTableReferences),
          ChatCharacter,
          PrefetchHooks Function({bool conversationsRefs})
        > {
  $$ChatCharactersTableTableManager(
    _$AppDatabase db,
    $ChatCharactersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatCharactersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatCharactersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatCharactersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> instructions = const Value.absent(),
                Value<String?> avatarPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatCharactersCompanion(
                id: id,
                name: name,
                instructions: instructions,
                avatarPath: avatarPath,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String instructions,
                Value<String?> avatarPath = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ChatCharactersCompanion.insert(
                id: id,
                name: name,
                instructions: instructions,
                avatarPath: avatarPath,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChatCharactersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({conversationsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (conversationsRefs) db.conversations,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (conversationsRefs)
                    await $_getPrefetchedData<
                      ChatCharacter,
                      $ChatCharactersTable,
                      Conversation
                    >(
                      currentTable: table,
                      referencedTable: $$ChatCharactersTableReferences
                          ._conversationsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ChatCharactersTableReferences(
                            db,
                            table,
                            p0,
                          ).conversationsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.characterId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ChatCharactersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatCharactersTable,
      ChatCharacter,
      $$ChatCharactersTableFilterComposer,
      $$ChatCharactersTableOrderingComposer,
      $$ChatCharactersTableAnnotationComposer,
      $$ChatCharactersTableCreateCompanionBuilder,
      $$ChatCharactersTableUpdateCompanionBuilder,
      (ChatCharacter, $$ChatCharactersTableReferences),
      ChatCharacter,
      PrefetchHooks Function({bool conversationsRefs})
    >;
typedef $$ConversationsTableCreateCompanionBuilder =
    ConversationsCompanion Function({
      required String id,
      required String title,
      Value<String?> serverProfileId,
      Value<String?> serverNameSnapshot,
      Value<String?> providerSnapshot,
      Value<String?> characterId,
      Value<String?> characterNameSnapshot,
      required String model,
      Value<String?> systemPrompt,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });
typedef $$ConversationsTableUpdateCompanionBuilder =
    ConversationsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> serverProfileId,
      Value<String?> serverNameSnapshot,
      Value<String?> providerSnapshot,
      Value<String?> characterId,
      Value<String?> characterNameSnapshot,
      Value<String> model,
      Value<String?> systemPrompt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });

final class $$ConversationsTableReferences
    extends BaseReferences<_$AppDatabase, $ConversationsTable, Conversation> {
  $$ConversationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ServerProfilesTable _serverProfileIdTable(_$AppDatabase db) => db
      .serverProfiles
      .createAlias('conversations__server_profile_id__server_profiles__id');

  $$ServerProfilesTableProcessedTableManager? get serverProfileId {
    final $_column = $_itemColumn<String>('server_profile_id');
    if ($_column == null) return null;
    final manager = $$ServerProfilesTableTableManager(
      $_db,
      $_db.serverProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_serverProfileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ChatCharactersTable _characterIdTable(_$AppDatabase db) => db
      .chatCharacters
      .createAlias('conversations__character_id__chat_characters__id');

  $$ChatCharactersTableProcessedTableManager? get characterId {
    final $_column = $_itemColumn<String>('character_id');
    if ($_column == null) return null;
    final manager = $$ChatCharactersTableTableManager(
      $_db,
      $_db.chatCharacters,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_characterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ChatMessagesTable, List<ChatMessage>>
  _chatMessagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.chatMessages,
    aliasName: 'conversations__id__chat_messages__conversation_id',
  );

  $$ChatMessagesTableProcessedTableManager get chatMessagesRefs {
    final manager = $$ChatMessagesTableTableManager(
      $_db,
      $_db.chatMessages,
    ).filter((f) => f.conversationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_chatMessagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ConversationsTableFilterComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverNameSnapshot => $composableBuilder(
    column: $table.serverNameSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerSnapshot => $composableBuilder(
    column: $table.providerSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get characterNameSnapshot => $composableBuilder(
    column: $table.characterNameSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get systemPrompt => $composableBuilder(
    column: $table.systemPrompt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ServerProfilesTableFilterComposer get serverProfileId {
    final $$ServerProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.serverProfileId,
      referencedTable: $db.serverProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServerProfilesTableFilterComposer(
            $db: $db,
            $table: $db.serverProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ChatCharactersTableFilterComposer get characterId {
    final $$ChatCharactersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.chatCharacters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatCharactersTableFilterComposer(
            $db: $db,
            $table: $db.chatCharacters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> chatMessagesRefs(
    Expression<bool> Function($$ChatMessagesTableFilterComposer f) f,
  ) {
    final $$ChatMessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatMessages,
      getReferencedColumn: (t) => t.conversationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatMessagesTableFilterComposer(
            $db: $db,
            $table: $db.chatMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ConversationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverNameSnapshot => $composableBuilder(
    column: $table.serverNameSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerSnapshot => $composableBuilder(
    column: $table.providerSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get characterNameSnapshot => $composableBuilder(
    column: $table.characterNameSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get systemPrompt => $composableBuilder(
    column: $table.systemPrompt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ServerProfilesTableOrderingComposer get serverProfileId {
    final $$ServerProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.serverProfileId,
      referencedTable: $db.serverProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServerProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.serverProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ChatCharactersTableOrderingComposer get characterId {
    final $$ChatCharactersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.chatCharacters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatCharactersTableOrderingComposer(
            $db: $db,
            $table: $db.chatCharacters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConversationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get serverNameSnapshot => $composableBuilder(
    column: $table.serverNameSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get providerSnapshot => $composableBuilder(
    column: $table.providerSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get characterNameSnapshot => $composableBuilder(
    column: $table.characterNameSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<String> get systemPrompt => $composableBuilder(
    column: $table.systemPrompt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  $$ServerProfilesTableAnnotationComposer get serverProfileId {
    final $$ServerProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.serverProfileId,
      referencedTable: $db.serverProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServerProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.serverProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ChatCharactersTableAnnotationComposer get characterId {
    final $$ChatCharactersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.chatCharacters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatCharactersTableAnnotationComposer(
            $db: $db,
            $table: $db.chatCharacters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> chatMessagesRefs<T extends Object>(
    Expression<T> Function($$ChatMessagesTableAnnotationComposer a) f,
  ) {
    final $$ChatMessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatMessages,
      getReferencedColumn: (t) => t.conversationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatMessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.chatMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ConversationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConversationsTable,
          Conversation,
          $$ConversationsTableFilterComposer,
          $$ConversationsTableOrderingComposer,
          $$ConversationsTableAnnotationComposer,
          $$ConversationsTableCreateCompanionBuilder,
          $$ConversationsTableUpdateCompanionBuilder,
          (Conversation, $$ConversationsTableReferences),
          Conversation,
          PrefetchHooks Function({
            bool serverProfileId,
            bool characterId,
            bool chatMessagesRefs,
          })
        > {
  $$ConversationsTableTableManager(_$AppDatabase db, $ConversationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConversationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConversationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConversationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> serverProfileId = const Value.absent(),
                Value<String?> serverNameSnapshot = const Value.absent(),
                Value<String?> providerSnapshot = const Value.absent(),
                Value<String?> characterId = const Value.absent(),
                Value<String?> characterNameSnapshot = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<String?> systemPrompt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConversationsCompanion(
                id: id,
                title: title,
                serverProfileId: serverProfileId,
                serverNameSnapshot: serverNameSnapshot,
                providerSnapshot: providerSnapshot,
                characterId: characterId,
                characterNameSnapshot: characterNameSnapshot,
                model: model,
                systemPrompt: systemPrompt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> serverProfileId = const Value.absent(),
                Value<String?> serverNameSnapshot = const Value.absent(),
                Value<String?> providerSnapshot = const Value.absent(),
                Value<String?> characterId = const Value.absent(),
                Value<String?> characterNameSnapshot = const Value.absent(),
                required String model,
                Value<String?> systemPrompt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConversationsCompanion.insert(
                id: id,
                title: title,
                serverProfileId: serverProfileId,
                serverNameSnapshot: serverNameSnapshot,
                providerSnapshot: providerSnapshot,
                characterId: characterId,
                characterNameSnapshot: characterNameSnapshot,
                model: model,
                systemPrompt: systemPrompt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ConversationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                serverProfileId = false,
                characterId = false,
                chatMessagesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (chatMessagesRefs) db.chatMessages,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (serverProfileId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.serverProfileId,
                                    referencedTable:
                                        $$ConversationsTableReferences
                                            ._serverProfileIdTable(db),
                                    referencedColumn:
                                        $$ConversationsTableReferences
                                            ._serverProfileIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (characterId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.characterId,
                                    referencedTable:
                                        $$ConversationsTableReferences
                                            ._characterIdTable(db),
                                    referencedColumn:
                                        $$ConversationsTableReferences
                                            ._characterIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (chatMessagesRefs)
                        await $_getPrefetchedData<
                          Conversation,
                          $ConversationsTable,
                          ChatMessage
                        >(
                          currentTable: table,
                          referencedTable: $$ConversationsTableReferences
                              ._chatMessagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ConversationsTableReferences(
                                db,
                                table,
                                p0,
                              ).chatMessagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.conversationId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ConversationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConversationsTable,
      Conversation,
      $$ConversationsTableFilterComposer,
      $$ConversationsTableOrderingComposer,
      $$ConversationsTableAnnotationComposer,
      $$ConversationsTableCreateCompanionBuilder,
      $$ConversationsTableUpdateCompanionBuilder,
      (Conversation, $$ConversationsTableReferences),
      Conversation,
      PrefetchHooks Function({
        bool serverProfileId,
        bool characterId,
        bool chatMessagesRefs,
      })
    >;
typedef $$ChatMessagesTableCreateCompanionBuilder =
    ChatMessagesCompanion Function({
      required String id,
      required String conversationId,
      required String role,
      required String content,
      required String thinking,
      Value<String?> model,
      required String status,
      Value<String?> toolCallsJson,
      Value<String?> toolCallId,
      Value<String?> characterIdSnapshot,
      Value<String?> characterNameSnapshot,
      Value<String?> characterAvatarPathSnapshot,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ChatMessagesTableUpdateCompanionBuilder =
    ChatMessagesCompanion Function({
      Value<String> id,
      Value<String> conversationId,
      Value<String> role,
      Value<String> content,
      Value<String> thinking,
      Value<String?> model,
      Value<String> status,
      Value<String?> toolCallsJson,
      Value<String?> toolCallId,
      Value<String?> characterIdSnapshot,
      Value<String?> characterNameSnapshot,
      Value<String?> characterAvatarPathSnapshot,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ChatMessagesTableReferences
    extends BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessage> {
  $$ChatMessagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ConversationsTable _conversationIdTable(_$AppDatabase db) => db
      .conversations
      .createAlias('chat_messages__conversation_id__conversations__id');

  $$ConversationsTableProcessedTableManager get conversationId {
    final $_column = $_itemColumn<String>('conversation_id')!;

    final manager = $$ConversationsTableTableManager(
      $_db,
      $_db.conversations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_conversationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ChatMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thinking => $composableBuilder(
    column: $table.thinking,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toolCallsJson => $composableBuilder(
    column: $table.toolCallsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toolCallId => $composableBuilder(
    column: $table.toolCallId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get characterIdSnapshot => $composableBuilder(
    column: $table.characterIdSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get characterNameSnapshot => $composableBuilder(
    column: $table.characterNameSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get characterAvatarPathSnapshot => $composableBuilder(
    column: $table.characterAvatarPathSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ConversationsTableFilterComposer get conversationId {
    final $$ConversationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conversationId,
      referencedTable: $db.conversations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationsTableFilterComposer(
            $db: $db,
            $table: $db.conversations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thinking => $composableBuilder(
    column: $table.thinking,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toolCallsJson => $composableBuilder(
    column: $table.toolCallsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toolCallId => $composableBuilder(
    column: $table.toolCallId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get characterIdSnapshot => $composableBuilder(
    column: $table.characterIdSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get characterNameSnapshot => $composableBuilder(
    column: $table.characterNameSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get characterAvatarPathSnapshot => $composableBuilder(
    column: $table.characterAvatarPathSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ConversationsTableOrderingComposer get conversationId {
    final $$ConversationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conversationId,
      referencedTable: $db.conversations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationsTableOrderingComposer(
            $db: $db,
            $table: $db.conversations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get thinking =>
      $composableBuilder(column: $table.thinking, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get toolCallsJson => $composableBuilder(
    column: $table.toolCallsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get toolCallId => $composableBuilder(
    column: $table.toolCallId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get characterIdSnapshot => $composableBuilder(
    column: $table.characterIdSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get characterNameSnapshot => $composableBuilder(
    column: $table.characterNameSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get characterAvatarPathSnapshot => $composableBuilder(
    column: $table.characterAvatarPathSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ConversationsTableAnnotationComposer get conversationId {
    final $$ConversationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conversationId,
      referencedTable: $db.conversations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationsTableAnnotationComposer(
            $db: $db,
            $table: $db.conversations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatMessagesTable,
          ChatMessage,
          $$ChatMessagesTableFilterComposer,
          $$ChatMessagesTableOrderingComposer,
          $$ChatMessagesTableAnnotationComposer,
          $$ChatMessagesTableCreateCompanionBuilder,
          $$ChatMessagesTableUpdateCompanionBuilder,
          (ChatMessage, $$ChatMessagesTableReferences),
          ChatMessage,
          PrefetchHooks Function({bool conversationId})
        > {
  $$ChatMessagesTableTableManager(_$AppDatabase db, $ChatMessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> conversationId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> thinking = const Value.absent(),
                Value<String?> model = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> toolCallsJson = const Value.absent(),
                Value<String?> toolCallId = const Value.absent(),
                Value<String?> characterIdSnapshot = const Value.absent(),
                Value<String?> characterNameSnapshot = const Value.absent(),
                Value<String?> characterAvatarPathSnapshot =
                    const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatMessagesCompanion(
                id: id,
                conversationId: conversationId,
                role: role,
                content: content,
                thinking: thinking,
                model: model,
                status: status,
                toolCallsJson: toolCallsJson,
                toolCallId: toolCallId,
                characterIdSnapshot: characterIdSnapshot,
                characterNameSnapshot: characterNameSnapshot,
                characterAvatarPathSnapshot: characterAvatarPathSnapshot,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String conversationId,
                required String role,
                required String content,
                required String thinking,
                Value<String?> model = const Value.absent(),
                required String status,
                Value<String?> toolCallsJson = const Value.absent(),
                Value<String?> toolCallId = const Value.absent(),
                Value<String?> characterIdSnapshot = const Value.absent(),
                Value<String?> characterNameSnapshot = const Value.absent(),
                Value<String?> characterAvatarPathSnapshot =
                    const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ChatMessagesCompanion.insert(
                id: id,
                conversationId: conversationId,
                role: role,
                content: content,
                thinking: thinking,
                model: model,
                status: status,
                toolCallsJson: toolCallsJson,
                toolCallId: toolCallId,
                characterIdSnapshot: characterIdSnapshot,
                characterNameSnapshot: characterNameSnapshot,
                characterAvatarPathSnapshot: characterAvatarPathSnapshot,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChatMessagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({conversationId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (conversationId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.conversationId,
                                referencedTable: $$ChatMessagesTableReferences
                                    ._conversationIdTable(db),
                                referencedColumn: $$ChatMessagesTableReferences
                                    ._conversationIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ChatMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatMessagesTable,
      ChatMessage,
      $$ChatMessagesTableFilterComposer,
      $$ChatMessagesTableOrderingComposer,
      $$ChatMessagesTableAnnotationComposer,
      $$ChatMessagesTableCreateCompanionBuilder,
      $$ChatMessagesTableUpdateCompanionBuilder,
      (ChatMessage, $$ChatMessagesTableReferences),
      ChatMessage,
      PrefetchHooks Function({bool conversationId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ServerProfilesTableTableManager get serverProfiles =>
      $$ServerProfilesTableTableManager(_db, _db.serverProfiles);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$SelectedModelsTableTableManager get selectedModels =>
      $$SelectedModelsTableTableManager(_db, _db.selectedModels);
  $$ChatCharactersTableTableManager get chatCharacters =>
      $$ChatCharactersTableTableManager(_db, _db.chatCharacters);
  $$ConversationsTableTableManager get conversations =>
      $$ConversationsTableTableManager(_db, _db.conversations);
  $$ChatMessagesTableTableManager get chatMessages =>
      $$ChatMessagesTableTableManager(_db, _db.chatMessages);
}
