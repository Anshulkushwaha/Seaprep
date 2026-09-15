enum ChatSender { user, ai }

class ChatMessageModel {
  final String id;
  final String text;
  final ChatSender sender;
  final DateTime timestamp;
  final bool isStreaming;

  ChatMessageModel({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.isStreaming = false,
  });

  ChatMessageModel copyWith({
    String? id,
    String? text,
    ChatSender? sender,
    DateTime? timestamp,
    bool? isStreaming,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      text: text ?? this.text,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'sender': sender.name,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      ChatMessageModel(
        id: json['id'] as String,
        text: json['text'] as String,
        sender: json['sender'] == 'user' ? ChatSender.user : ChatSender.ai,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}
