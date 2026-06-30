class ChatCharacter {
  const ChatCharacter({
    required this.id,
    required this.name,
    required this.instructions,
    required this.createdAt,
    required this.updatedAt,
    this.imagePath,
  });

  factory ChatCharacter.create({
    required String id,
    required String name,
    required String instructions,
    String? imagePath,
  }) {
    final now = DateTime.now().toUtc();
    return ChatCharacter(
      id: id,
      name: name.trim(),
      instructions: instructions.trim(),
      imagePath: _blankToNull(imagePath),
      createdAt: now,
      updatedAt: now,
    );
  }

  factory ChatCharacter.fromJson(Map<String, dynamic> json) {
    return ChatCharacter(
      id: json['id'] as String,
      name: json['name'] as String,
      instructions: json['instructions'] as String? ?? '',
      imagePath: json['imagePath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  final String id;
  final String name;
  final String instructions;
  final String? imagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatCharacter copyWith({
    String? name,
    String? instructions,
    String? imagePath,
  }) {
    return ChatCharacter(
      id: id,
      name: (name ?? this.name).trim(),
      instructions: (instructions ?? this.instructions).trim(),
      imagePath: imagePath == null ? this.imagePath : _blankToNull(imagePath),
      createdAt: createdAt,
      updatedAt: DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'instructions': instructions,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}
