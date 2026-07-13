import '../../../servers/domain/entities/server_profile.dart';

class AvailableModel {
  const AvailableModel({
    required this.id,
    required this.displayName,
    required this.serverId,
    required this.provider,
    this.sizeBytes,
  });

  final String id;
  final String displayName;
  final String serverId;
  final ApiProvider provider;
  final int? sizeBytes;

  String get identity => '$serverId:$id';
}
