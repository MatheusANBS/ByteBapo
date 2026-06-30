enum ThinkingMode {
  modelDefault(null, 'Padrao'),
  disabled(false, 'Off'),
  enabled(true, 'On'),
  low('low', 'Low'),
  medium('medium', 'Medium'),
  high('high', 'High'),
  max('max', 'Max');

  const ThinkingMode(this.ollamaValue, this.label);

  final Object? ollamaValue;
  final String label;

  static ThinkingMode fromName(String? name) {
    return ThinkingMode.values.firstWhere(
      (mode) => mode.name == name,
      orElse: () => ThinkingMode.modelDefault,
    );
  }
}

class GenerationOptions {
  const GenerationOptions({
    this.temperature,
    this.topP,
    this.numCtx,
    this.seed,
    this.thinking = ThinkingMode.modelDefault,
    this.stream = true,
  });

  factory GenerationOptions.fromJson(Map<String, dynamic> json) {
    return GenerationOptions(
      temperature: (json['temperature'] as num?)?.toDouble(),
      topP: (json['topP'] as num?)?.toDouble(),
      numCtx: json['numCtx'] as int?,
      seed: json['seed'] as int?,
      thinking: ThinkingMode.fromName(json['thinking'] as String?),
      stream: json['stream'] as bool? ?? true,
    );
  }

  final double? temperature;
  final double? topP;
  final int? numCtx;
  final int? seed;
  final ThinkingMode thinking;
  final bool stream;

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'topP': topP,
      'numCtx': numCtx,
      'seed': seed,
      'thinking': thinking.name,
      'stream': stream,
    };
  }

  Map<String, dynamic> toOllamaOptionsJson() {
    return {
      if (temperature != null) 'temperature': temperature,
      if (topP != null) 'top_p': topP,
      if (numCtx != null) 'num_ctx': numCtx,
      if (seed != null) 'seed': seed,
    };
  }
}
