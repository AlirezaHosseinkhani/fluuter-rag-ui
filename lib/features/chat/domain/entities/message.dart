import 'package:equatable/equatable.dart';

enum FeedbackType { like, dislike }

class Message extends Equatable {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final FeedbackType? feedback;
  final String? question;
  final String? sessionId;

  const Message({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.feedback,
    this.question,
    this.sessionId,
  });

  Message copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    FeedbackType? feedback,
    String? question,
    String? sessionId,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      feedback: feedback ?? this.feedback,
      question: question ?? this.question,
      sessionId: sessionId ?? this.sessionId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    content,
    isUser,
    timestamp,
    feedback,
    question,
    sessionId,
  ];
}