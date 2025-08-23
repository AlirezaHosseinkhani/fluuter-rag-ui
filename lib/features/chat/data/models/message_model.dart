import '../../domain/entities/message.dart';

class MessageModel extends Message {
  const MessageModel({
    required super.id,
    required super.content,
    required super.isUser,
    required super.timestamp,
    super.feedback,
    super.question,
    super.sessionId,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      content: json['content'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
      feedback: json['feedback'] != null
          ? FeedbackType.values.firstWhere(
              (e) => e.toString() == 'FeedbackType.${json['feedback']}'
      )
          : null,
      question: json['question'],
      sessionId: json['sessionId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'feedback': feedback?.toString().split('.').last,
      'question': question,
      'sessionId': sessionId,
    };
  }

  factory MessageModel.fromEntity(Message message) {
    return MessageModel(
      id: message.id,
      content: message.content,
      isUser: message.isUser,
      timestamp: message.timestamp,
      feedback: message.feedback,
      question: message.question,
      sessionId: message.sessionId,
    );
  }
}