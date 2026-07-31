import 'package:flutter/foundation.dart';

/// Role for an AI chat message.
enum AiChatRole {
  user,
  assistant;

  String toShortString() => name;
}

/// Message exchanged with the AI Assistant chat.
@immutable
class AiChatMessage {
  /// Unique message ID.
  final String id;

  /// Role of the speaker ('user' or 'assistant').
  final AiChatRole role;

  /// Text content of the message.
  final String content;

  /// Creates an immutable [AiChatMessage].
  const AiChatMessage({
    required this.id,
    required this.role,
    required this.content,
  });

  /// Deserializes from JSON map.
  factory AiChatMessage.fromJson(Map<String, dynamic> json) {
    return AiChatMessage(
      id:
          json['id'] as String? ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      role: json['role'] == 'user' ? AiChatRole.user : AiChatRole.assistant,
      content: json['content'] as String? ?? '',
    );
  }

  /// Serializes to JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'role': role.toShortString(),
    'content': content,
  };
}
