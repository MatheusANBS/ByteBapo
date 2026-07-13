class Conversation {
  const Conversation({
    required this.id,
    required this.title,
    required this.serverProfileId,
    required this.model,
    required this.createdAt,
    required this.updatedAt,
    this.characterId,
    this.serverNameSnapshot,
    this.providerSnapshot,
    this.characterNameSnapshot,
    this.systemPrompt,
    this.archivedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      title: json['title'] as String,
      serverProfileId: json['serverProfileId'] as String?,
      serverNameSnapshot: json['serverNameSnapshot'] as String?,
      providerSnapshot: json['providerSnapshot'] as String?,
      model: json['model'] as String,
      characterId: json['characterId'] as String?,
      characterNameSnapshot: json['characterNameSnapshot'] as String?,
      systemPrompt: json['systemPrompt'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      archivedAt: json['archivedAt'] == null
          ? null
          : DateTime.parse(json['archivedAt'] as String),
    );
  }

  final String id;
  final String title;
  final String? serverProfileId;
  final String? serverNameSnapshot;
  final String? providerSnapshot;
  final String model;
  final String? characterId;
  final String? characterNameSnapshot;
  final String? systemPrompt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'serverProfileId': serverProfileId,
      'serverNameSnapshot': serverNameSnapshot,
      'providerSnapshot': providerSnapshot,
      'model': model,
      'characterId': characterId,
      'characterNameSnapshot': characterNameSnapshot,
      'systemPrompt': systemPrompt,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'archivedAt': archivedAt?.toIso8601String(),
    };
  }
}
