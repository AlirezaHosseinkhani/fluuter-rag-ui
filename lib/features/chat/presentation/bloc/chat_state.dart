import 'package:equatable/equatable.dart';
import '../../domain/entities/message.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<Message> messages;
  final bool isTyping;
  final bool waitingForFeedback;
  final String sessionId;

  const ChatLoaded({
    required this.messages,
    this.isTyping = false,
    this.waitingForFeedback = false,
    required this.sessionId,
  });

  ChatLoaded copyWith({
    List<Message>? messages,
    bool? isTyping,
    bool? waitingForFeedback,
    String? sessionId,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      waitingForFeedback: waitingForFeedback ?? this.waitingForFeedback,
      sessionId: sessionId ?? this.sessionId,
    );
  }

  @override
  List<Object?> get props => [messages, isTyping, waitingForFeedback, sessionId];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object> get props => [message];
}