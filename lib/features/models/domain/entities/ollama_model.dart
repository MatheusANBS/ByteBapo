class OllamaModel {
  const OllamaModel({
    required this.name,
    required this.model,
    this.modifiedAt,
    this.size,
    this.digest,
    this.detailsJson,
  });

  factory OllamaModel.fromJson(Map<String, dynamic> json) {
    return OllamaModel(
      name: json['name'] as String? ?? json['model'] as String? ?? '',
      model: json['model'] as String? ?? json['name'] as String? ?? '',
      modifiedAt: json['modified_at'] == null
          ? null
          : DateTime.tryParse(json['modified_at'] as String),
      size: json['size'] as int?,
      digest: json['digest'] as String?,
      detailsJson: json['details']?.toString(),
    );
  }

  final String name;
  final String model;
  final DateTime? modifiedAt;
  final int? size;
  final String? digest;
  final String? detailsJson;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'model': model,
      'modified_at': modifiedAt?.toIso8601String(),
      'size': size,
      'digest': digest,
      'details': detailsJson,
    };
  }
}
