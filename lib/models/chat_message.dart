class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Converts an API record (which contains both q and a) into a list of ChatMessage
  static List<ChatMessage> listFromApiRecord(Map<String, dynamic> json) {
    final List<ChatMessage> messages = [];
    final String id = json['id'].toString();
    final String? createdTimeStr = json['created_time'];
    final DateTime time =
        DateTime.tryParse(createdTimeStr ?? '') ?? DateTime.now();

    // User question
    if (json['q'] != null && (json['q'] as String).isNotEmpty) {
      messages.add(
        ChatMessage(
          id: '${id}_q',
          content: json['q'] as String,
          isUser: true,
          timestamp: time,
        ),
      );
    }

    // AI answer
    if (json['a'] != null && (json['a'] as String).isNotEmpty) {
      messages.add(
        ChatMessage(
          id: '${id}_a',
          content: json['a'] as String,
          isUser: false,
          timestamp: time.add(const Duration(milliseconds: 100)),
        ),
      );
    }

    return messages;
  }
}
