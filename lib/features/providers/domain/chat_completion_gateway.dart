import '../../chat/domain/entities/chat_message.dart';
import '../../chat/domain/entities/generation_options.dart';
import '../../servers/domain/entities/server_profile.dart';

abstract interface class ChatCompletionGateway {
  Stream<ChatChunk> streamChat({
    required ServerProfile server,
    required String model,
    required List<ChatMessage> messages,
    GenerationOptions options = const GenerationOptions(),
  });
}

enum ChatChunkKind { thinking, content, toolCall }

class ChatChunk {
  const ChatChunk({required this.kind, required this.text, this.toolCall});

  final ChatChunkKind kind;
  final String text;
  final ToolCallDelta? toolCall;
}

class ToolCallDelta {
  const ToolCallDelta({
    required this.index,
    this.id,
    this.name,
    this.arguments,
  });

  final int index;
  final String? id;
  final String? name;
  final String? arguments;
}
