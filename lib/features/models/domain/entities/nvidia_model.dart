class NvidiaModel {
  const NvidiaModel({
    required this.id,
    required this.object,
    required this.created,
    required this.ownedBy,
    this.permission,
    this.root,
    this.parent,
  });

  factory NvidiaModel.fromJson(Map<String, dynamic> json) {
    return NvidiaModel(
      id: json['id'] as String? ?? '',
      object: json['object'] as String? ?? 'model',
      created: json['created'] as int? ?? 0,
      ownedBy: json['owned_by'] as String? ?? 'nvidia',
      permission: json['permission'] as List<Object?>?,
      root: json['root'] as String?,
      parent: json['parent'] as String?,
    );
  }

  final String id;
  final String object;
  final int created;
  final String ownedBy;
  final List<Object?>? permission;
  final String? root;
  final String? parent;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'object': object,
      'created': created,
      'owned_by': ownedBy,
      'permission': permission,
      'root': root,
      'parent': parent,
    };
  }

  @override
  String toString() => 'NvidiaModel(id: $id, object: $object)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NvidiaModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
